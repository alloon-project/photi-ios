//
//  ChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Combine
import Core
import Entity
import UseCase

protocol ChallengeCoordinatable: AnyObject {
  @MainActor func attachChallengeReport(challengeId: Int)
  @MainActor func attachChallengeEdit(model: ModifyPresentationModel, challengeId: Int)
  func didTapBackButton()
  func didTapConfirmButtonAtAlert()
  func authenticatedFailed()
  func leaveChallenge(challengeId: Int)
  func didTapShareButton(challengeId: Int, inviteCode: String?, challengeName: String)
}

protocol ChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeCoordinatable? { get set }
}

enum DropDownMenu: String {
  case report = "챌린지 신고하기"
  case edit = "챌린지 수정하기"
  case leave = "챌린지 탈퇴하기"
}

final class ChallengeViewModel: ChallengeViewModelType {
  private let useCase: ChallengeUseCase
  private var cancellables = Set<AnyCancellable>()

  let challengeId: Int
  var challengeDetail: ChallengeDetail?
  private(set) var challengeName: String = ""

  weak var coordinator: ChallengeCoordinatable?

  private let challengeModelSubject = CurrentValueSubject<ChallengeTitlePresentationModel, Never>(.default)
  private let memberCountSubject = CurrentValueSubject<Int, Never>(0)
  private let dropDownMenusSubject = CurrentValueSubject<[DropDownMenu], Never>([])
  private let challengeNotFoundSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let viewDidLoad: AnyPublisher<Void, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapConfirmButtonAtAlert: AnyPublisher<Void, Never>
    let didTapLeaveButton: AnyPublisher<Void, Never>
    let didTapReportButton: AnyPublisher<Void, Never>
    let didTapEditButton: AnyPublisher<Void, Never>
    let didTapShareButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let challengeInfo: AnyPublisher<ChallengeTitlePresentationModel, Never>
    let memberCount: AnyPublisher<Int, Never>
    let dropDownMenus: AnyPublisher<[DropDownMenu], Never>
    let challengeNotFound: AnyPublisher<Void, Never>
    let networnUnstable: AnyPublisher<Void, Never>
  }

  // MARK: - Initializers
  init(useCase: ChallengeUseCase, challengeId: Int) {
    self.useCase = useCase
    self.challengeId = challengeId
  }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)

    input.didTapReportButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachChallengeReport(challengeId: owner.challengeId) }
      }
      .store(in: &cancellables)

    input.didTapLeaveButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.leaveChallenge() }
      }
      .store(in: &cancellables)

    input.didTapEditButton
      .sinkOnMain(with: self) { owner, _ in
        guard let challengeDetail = owner.challengeDetail else { return }
        let viewPresentaionModel = owner.mapToEditPresentaionModel(challengeDetail)
        Task { await
          owner.coordinator?.attachChallengeEdit(
            model: viewPresentaionModel,
            challengeId: owner.challengeId
          )
        }
      }
      .store(in: &cancellables)

    input.didTapConfirmButtonAtAlert
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapConfirmButtonAtAlert()
      }
      .store(in: &cancellables)

    input.didTapShareButton
      .sinkOnMain(with: self) { owner, _ in
        owner.shareChallenge()
      }
      .store(in: &cancellables)

    return Output(
      challengeInfo: challengeModelSubject.eraseToAnyPublisher(),
      memberCount: memberCountSubject.eraseToAnyPublisher(),
      dropDownMenus: dropDownMenusSubject.eraseToAnyPublisher(),
      challengeNotFound: challengeNotFoundSubject.eraseToAnyPublisher(),
      networnUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Internel Methods
extension ChallengeViewModel {
  func fetchChallenge() async -> ChallengeDetail? {
    do {
      let challenge = try await useCase.fetchChallengeDetail(id: challengeId)
      let model = mapToPresentationModel(challenge)
      challengeDetail = challenge
      challengeModelSubject.send(model)
      memberCountSubject.send(challenge.memberCount)
      challengeName = challenge.name

      configureDropDownMenus(creator: challenge.creator)

      return challenge
    } catch {
      requestFailed(with: error)
      return nil
    }
  }

  func shareChallenge() {
    guard
      let challengeDetail = self.challengeDetail,
      let isPublic = challengeDetail.isPublic
    else { return }

    if isPublic { // 전체 공개일경우 바로 공유하기
      coordinator?.didTapShareButton(challengeId: self.challengeId, inviteCode: nil, challengeName: self.challengeName)
    } else { // 친구 공개일경우 초대코드 조회해서 공유하기
      fetchChallengeInviteCode()
    }
  }
}

// MARK: - API Methods
private extension ChallengeViewModel {
  func leaveChallenge() async {
    do {
      try await useCase.leaveChallenge(id: challengeId)
      coordinator?.leaveChallenge(challengeId: challengeId)
    } catch {
      requestFailed(with: error)
    }
  }

  func fetchChallengeInviteCode() {
    Task {
      do {
        let invitation = try await useCase.fetchInvitationCode(id: challengeId)
        await MainActor.run {
          coordinator?.didTapShareButton(
            challengeId: self.challengeId,
            inviteCode: invitation.invitationCode,
            challengeName: invitation.name
          )
        }
      } catch {
        requestFailed(with: error)
      }
    }
  }

  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableSubject.send(()) }

    switch error {
    case .authenticationFailed:
      coordinator?.authenticatedFailed()
    case let .challengeFailed(reason) where reason == .challengeNotFound:
      challengeNotFoundSubject.send(())
    default: networkUnstableSubject.send(())
    }
  }
}

// MARK: - Private Methods
private extension ChallengeViewModel {
  func configureDropDownMenus(creator: String) {
    if creator == ServiceConfiguration.shared.userName {
      dropDownMenusSubject.send([.edit, .leave])
    } else {
      dropDownMenusSubject.send([.report, .leave])
    }
  }

  func mapToPresentationModel(_ challenge: ChallengeDetail) -> ChallengeTitlePresentationModel {
    return .init(
      title: challenge.name,
      hashTags: challenge.hashTags,
      imageURL: challenge.imageUrl
    )
  }

  func mapToEditPresentaionModel(_ challengeDetail: ChallengeDetail) -> ModifyPresentationModel {
    return ModifyPresentationModel(
      title: challengeDetail.name,
      hashtags: challengeDetail.hashTags,
      verificationTime: challengeDetail.proveTime.toString("HH : mm"),
      goal: challengeDetail.goal,
      imageUrlString: challengeDetail.imageUrl?.absoluteString ?? "",
      rules: challengeDetail.rules ?? [],
      deadLine: challengeDetail.endDate.toString("yyyy. MM. dd")
    )
  }
}

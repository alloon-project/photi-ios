//
//  ChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
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
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeCoordinatable? { get set }
}

enum DropDownMenu: String {
  case report = "챌린지 신고하기"
  case edit = "챌린지 수정하기"
  case leave = "챌린지 탈퇴하기"
}

final class ChallengeViewModel: ChallengeViewModelType {
  private let useCase: ChallengeUseCase
  
  let disposeBag = DisposeBag()
  let challengeId: Int
  var challengeDetail: ChallengeDetail?
  private(set) var challengeName: String = ""
  
  weak var coordinator: ChallengeCoordinatable?
  
  private let challengeModelRelay = BehaviorRelay<ChallengeTitlePresentationModel>(value: .default)
  private let memberCount = BehaviorRelay<Int>(value: 0)
  private let dropDownMenusRelay = BehaviorRelay<[DropDownMenu]>(value: [])
  private let challengeNotFoundRelay = PublishRelay<Void>()
  private let networkUnstable = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: Signal<Void>
    let didTapConfirmButtonAtAlert: Signal<Void>
    let didTapLeaveButton: Signal<Void>
    let didTapReportButton: Signal<Void>
    let didTapEditButton: Signal<Void>
    let didTapShareButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let challengeInfo: Driver<ChallengeTitlePresentationModel>
    let memberCount: Driver<Int>
    let dropDownMenus: Driver<[DropDownMenu]>
    let challengeNotFound: Signal<Void>
    let networnUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: ChallengeUseCase, challengeId: Int) {
    self.useCase = useCase
    self.challengeId = challengeId
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapReportButton
      .emit(with: self) { owner, _ in
        Task { await owner.coordinator?.attachChallengeReport(challengeId: owner.challengeId) }
      }
      .disposed(by: disposeBag)
    
    input.didTapLeaveButton
      .emit(with: self) { owner, _ in
        Task { await owner.leaveChallenge() }
      }
      .disposed(by: disposeBag)
    
    input.didTapEditButton
      .emit(with: self) { owner, _ in
        guard let challengeDetail = owner.challengeDetail else { return }
        let viewPresentaionModel = owner.mapToEditPresentaionModel(challengeDetail)
        Task { await
          owner.coordinator?.attachChallengeEdit(
            model: viewPresentaionModel,
            challengeId: owner.challengeId
          )
        }
      }
      .disposed(by: disposeBag)
    
    input.didTapConfirmButtonAtAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapConfirmButtonAtAlert()
      }
      .disposed(by: disposeBag)
    
    input.didTapShareButton
      .emit(with: self) { owner, _ in
        owner.shareChallenge()
      }
      .disposed(by: disposeBag)
    
    return Output(
      challengeInfo: challengeModelRelay.asDriver(),
      memberCount: memberCount.asDriver(),
      dropDownMenus: dropDownMenusRelay.asDriver(),
      challengeNotFound: challengeNotFoundRelay.asSignal(),
      networnUnstable: networkUnstable.asSignal()
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
      challengeModelRelay.accept(model)
      memberCount.accept(challenge.memberCount)
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
    guard let error = error as? APIError else { return networkUnstable.accept(()) }
    
    switch error {
    case .authenticationFailed:
      coordinator?.authenticatedFailed()
    case let .challengeFailed(reason) where reason == .challengeNotFound:
      challengeNotFoundRelay.accept(())
    default: networkUnstable.accept(())
    }
  }
}

// MARK: - Private Methods
private extension ChallengeViewModel {
  func configureDropDownMenus(creator: String) {
    if creator == ServiceConfiguration.shared.userName {
      dropDownMenusRelay.accept([.edit, .leave])
    } else {
      dropDownMenusRelay.accept([.report, .leave])
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

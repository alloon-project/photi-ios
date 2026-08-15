//
//  ChallengeModifyViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine
import CoreUI
import Entity
import UseCase

protocol ChallengeModifyCoordinatable: AnyObject {
  @MainActor func attachModifyName()
  @MainActor func attachModifyGoal()
  @MainActor func attachModifyCover()
  @MainActor func attachModifyHashtag()
  @MainActor func attachModifyRule()
  func didTapBackButton()
  func didTapAlert()
  func didModifiedChallenge()
}

protocol ChallengeModifyViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeModifyCoordinatable? { get set }
}

final class ChallengeModifyViewModel: ChallengeModifyViewModelType {
  weak var coordinator: ChallengeModifyCoordinatable?
  private var draft: ChallengeModifyDraft
  private var cancellables = Set<AnyCancellable>()
  private let challengeId: Int
  private let useCase: OrganizeUseCase

  private let stateSubject: CurrentValueSubject<ModifyPresentationModel, Never>
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let emptyFileErrorSubject = PassthroughSubject<String, Never>()
  private let imageTypeErrorSubject = PassthroughSubject<String, Never>()
  private let notPartyManagerSubject = PassthroughSubject<String, Never>()
  private let fileTooLargeErrorSubject = PassthroughSubject<String, Never>()
  private let notChallengeMemberSubject = PassthroughSubject<String, Never>()
  private let notExistChallengeSubject = PassthroughSubject<String, Never>()

  // MARK: - Input
  struct Input {
    // 동작
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapChallengeName: AnyPublisher<Void, Never>
    let didTapChallengeHashtag: AnyPublisher<Void, Never>
    let didTapChallengeGoal: AnyPublisher<Void, Never>
    let didTapChallengeCover: AnyPublisher<Void, Never>
    let didTapChallengeRule: AnyPublisher<Void, Never>
    let didTapModifyButton: AnyPublisher<Void, Never>
    let didTapConfirmButtonAtAlert: AnyPublisher<Void, Never>
    // 값
    let titleText: AnyPublisher<String, Never>
    let hashtags: AnyPublisher<[String], Never>
    let proveTime: AnyPublisher<String, Never>
    let goal: AnyPublisher<String, Never>
    let image: AnyPublisher<UIImageWrapper, Never>
    let rules: AnyPublisher<[String], Never>
    let endDate: AnyPublisher<String, Never>
  }

  // MARK: - Output
  struct Output {
    let presentationModel: AnyPublisher<ModifyPresentationModel, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let imageTypeError: AnyPublisher<String, Never>
    let notPartyManager: AnyPublisher<String, Never>
    let fileTooLargeError: AnyPublisher<String, Never>
    let notChallengeMember: AnyPublisher<String, Never>
    let notExistChallenge: AnyPublisher<String, Never>
  }

  // MARK: - Initializers
  init(
    useCase: OrganizeUseCase,
    presentationMdoel: ModifyPresentationModel,
    challengeId: Int
  ) {
    self.useCase = useCase
    self.challengeId = challengeId
    self.stateSubject = .init(presentationMdoel)

    draft = .init(
      name: presentationMdoel.title,
      hashtags: presentationMdoel.hashtags,
      goal: presentationMdoel.goal,
      verificationTime: presentationMdoel.verificationTime,
      deadline: presentationMdoel.deadLine,
      rules: presentationMdoel.rules,
      existingImageURL: presentationMdoel.imageUrlString
    )

    self.useCase.setChallengeId(id: challengeId)
  }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)

    input.didTapChallengeName
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyName() }
      }.store(in: &cancellables)

    input.didTapChallengeHashtag
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyHashtag() }
      }.store(in: &cancellables)

    input.didTapChallengeGoal
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyGoal() }
      }.store(in: &cancellables)

    input.didTapChallengeCover
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyCover() }
      }.store(in: &cancellables)

    input.didTapChallengeRule
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyRule() }
      }.store(in: &cancellables)

    input.didTapModifyButton
      .sinkOnMain(with: self) { owner, _ in
        owner.useCase.setChallengeId(id: owner.challengeId)
        Task { await owner.modifyChallenge() }
      }.store(in: &cancellables)

    input.didTapConfirmButtonAtAlert
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapAlert()
      }.store(in: &cancellables)

    transformData(input: input)

    return Output(
      presentationModel: stateSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      imageTypeError: imageTypeErrorSubject.eraseToAnyPublisher(),
      notPartyManager: notPartyManagerSubject.eraseToAnyPublisher(),
      fileTooLargeError: fileTooLargeErrorSubject.eraseToAnyPublisher(),
      notChallengeMember: notChallengeMemberSubject.eraseToAnyPublisher(),
      notExistChallenge: notExistChallengeSubject.eraseToAnyPublisher()
    )
  }

  func transformData(input: Input) {
    input.titleText
      .sinkOnMain(with: self) { owner, title in
        owner.draft.name = title
      }.store(in: &cancellables)

    input.hashtags
      .sinkOnMain(with: self) { owner, hashtags in
        owner.draft.hashtags = hashtags
      }.store(in: &cancellables)

    input.goal
      .sinkOnMain(with: self) { owner, goal in
        owner.draft.goal = goal
      }.store(in: &cancellables)

    input.proveTime
      .sinkOnMain(with: self) { owner, proveTime in
        owner.draft.verificationTime = proveTime
      }.store(in: &cancellables)

    input.image
      .dropFirst()
      .sinkOnMain(with: self) { owner, image in
        owner.draft.newImage = image
      }.store(in: &cancellables)

    input.rules
      .sinkOnMain(with: self) { owner, rules in
        owner.draft.rules = rules
      }.store(in: &cancellables)

    input.endDate
      .sinkOnMain(with: self) { owner, endDate in
        owner.draft.deadline = endDate
      }.store(in: &cancellables)
  }
}

// MARK: - Private Methods
private extension ChallengeModifyViewModel {
  @MainActor func modifyChallenge() async {
    guard let imageChange = makeImageChange(from: draft) else { return }

    do {
      try await useCase.modifyChallenge(
        id: challengeId,
        payload: modifyPayload(from: draft),
        imageChange: imageChange
      )
      coordinator?.didModifiedChallenge()
    } catch {
      requestFailed(with: error)
    }
  }

  func modifyPayload(from draft: ChallengeModifyDraft) -> ChallengeModifyPayload {
    return ChallengeModifyPayload(
      name: draft.name,
      goal: draft.goal,
      imageURL: draft.existingImageURL,
      proveTime: draft.verificationTime,
      endDate: draft.deadline,
      rules: draft.rules,
      hashtags: draft.hashtags
    )
  }

  func makeImageChange(from draft: ChallengeModifyDraft) -> ImageChange? {
    guard let newImage = draft.newImage else { return .keep }

    guard let (data, type) = newImage.imageToData(maxMB: 8) else {
      let message = "파일 사이즈는 8MB 이하만 가능합니다."
      fileTooLargeErrorSubject.send(message)
      return nil
    }

    return .replace(data: data, type: type)
  }

  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }

    switch error {
    case .organazieFailed(.notChallengeMemeber):
      let message = "존재하지 않는 챌린지 파티원입니다."
      notChallengeMemberSubject.send(message)
    case .organazieFailed(.challengeNotFound):
      let message = "존재하지 않는 챌린지입니다."
      notExistChallengeSubject.send(message)
    case .organazieFailed(.fileSizeExceed):
      let message = "파일 사이즈는 8MB 이하만 가능합니다."
      fileTooLargeErrorSubject.send(message)
    case .organazieFailed(.imageTypeUnsurported):
      let message = "이미지는 '.jpeg', '.jpg', '.png', '.gif' 타입만 가능합니다."
      imageTypeErrorSubject.send(message)
    case .organazieFailed(.forbidden):
      let message = "챌린지 파티장 권한이없습니다."
      notPartyManagerSubject.send(message)
    default:
      networkUnstableSubject.send(())
    }
  }
}

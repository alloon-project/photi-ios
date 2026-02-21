//
//  ChallengeModifyViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
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
  private let disposeBag = DisposeBag()
  private let challengeId: Int
  private let useCase: OrganizeUseCase
  
  private let stateRelay: BehaviorRelay<ModifyPresentationModel>
  private let networkUnstableRelay = PublishRelay<Void>()
  private let emptyFileErrorRelay = PublishRelay<String>()
  private let imageTypeErrorRelay = PublishRelay<String>()
  private let fileTooLargeErrorRelay = PublishRelay<String>()
  private let notChallengeMemberRelay = PublishRelay<String>()

  // MARK: - Input
  struct Input {
    // 동작
    let didTapBackButton: ControlEvent<Void>
    let didTapChallengeName: Signal<Void>
    let didTapChallengeHashtag: Signal<Void>
    let didTapChallengeGoal: Signal<Void>
    let didTapChallengeCover: Signal<Void>
    let didTapChallengeRule: Signal<Void>
    let didTapModifyButton: ControlEvent<Void>
    let didTapConfirmButtonAtAlert: Signal<Void>
    // 값
    let titleText: Signal<String>
    let hashtags: Signal<[String]>
    let proveTime: Signal<String>
    let goal: Signal<String>
    let image: Signal<UIImageWrapper>
    let rules: Signal<[String]>
    let endDate: Signal<String>
  }
  
  // MARK: - Output
  struct Output {
    let presentationModel: Driver<ModifyPresentationModel>
    let networkUnstable: Signal<Void>
    let imageTypeError: Signal<String>
    let fileTooLargeError: Signal<String>
    let notChallengeMember: Signal<String>
  }
  
  // MARK: - Initializers
  init(
    useCase: OrganizeUseCase,
    presentationMdoel: ModifyPresentationModel,
    challengeId: Int
  ) {
    self.useCase = useCase
    self.challengeId = challengeId
    self.stateRelay = .init(value: presentationMdoel)
    
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
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapChallengeName
      .emit(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyName() }
      }.disposed(by: disposeBag)
    
    input.didTapChallengeHashtag
      .emit(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyHashtag() }
      }.disposed(by: disposeBag)
    
    input.didTapChallengeGoal
      .emit(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyGoal() }
      }.disposed(by: disposeBag)
    
    input.didTapChallengeCover
      .emit(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyCover() }
      }.disposed(by: disposeBag)
    
    input.didTapChallengeRule
      .emit(with: self) { owner, _ in
        Task { await owner.coordinator?.attachModifyRule() }
      }.disposed(by: disposeBag)
    
    input.didTapModifyButton
      .bind(with: self) { owner, _ in
        owner.useCase.setChallengeId(id: owner.challengeId)
        Task { await owner.modifyChallenge() }
      }.disposed(by: disposeBag)
    
    input.didTapConfirmButtonAtAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapAlert()
      }.disposed(by: disposeBag)
    
    transformData(input: input)
    
    return Output(
      presentationModel: stateRelay.asDriver(),
      networkUnstable: networkUnstableRelay.asSignal(),
      imageTypeError: imageTypeErrorRelay.asSignal(),
      fileTooLargeError: fileTooLargeErrorRelay.asSignal(),
      notChallengeMember: notChallengeMemberRelay.asSignal()
    )
  }
  
  func transformData(input: Input) {
    input.titleText
      .emit(with: self) { owner, title in
        owner.draft.name = title
      }.disposed(by: disposeBag)
    
    input.hashtags
      .emit(with: self) { owner, hashtags in
        owner.draft.hashtags = hashtags
      }.disposed(by: disposeBag)
    
    input.goal
      .emit(with: self) { owner, goal in
        owner.draft.goal = goal
      }.disposed(by: disposeBag)
    
    input.proveTime
      .emit(with: self) { owner, proveTime in
        owner.draft.verificationTime = proveTime
      }.disposed(by: disposeBag)
    
    input.image
      .skip(1)
      .emit(with: self) { owner, image in
        owner.draft.newImage = image
      }.disposed(by: disposeBag)
    
    input.rules
      .emit(with: self) { owner, rules in
        owner.draft.rules = rules
      }.disposed(by: disposeBag)
    
    input.endDate
      .emit(with: self) { owner, endDate in
        owner.draft.deadline = endDate
      }.disposed(by: disposeBag)
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
      fileTooLargeErrorRelay.accept(message)
      return nil
    }

    return .replace(data: data, type: type)
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableRelay.accept(())
    }
    
    switch error {
      case let .organazieFailed(reason) where reason == .notChallengeMemeber:
        let message = "존재하지 않는 챌린지 파티원입니다."
        notChallengeMemberRelay.accept(message)
      case let .organazieFailed(reason) where reason == .fileSizeExceed:
        let message = "파일 사이즈는 8MB 이하만 가능합니다."
        fileTooLargeErrorRelay.accept(message)
      case let .organazieFailed(reason) where reason == .imageTypeUnsurported:
        let message = "이미지는 '.jpeg', '.jpg', '.png', '.gif' 타입만 가능합니다."
        imageTypeErrorRelay.accept(message)
      default:
        networkUnstableRelay.accept(())
    }
  }
}

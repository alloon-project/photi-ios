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
import Core
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
  private let disposeBag = DisposeBag()
  private let challengeId: Int
  private let useCase: OrganizeUseCase
  
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
    let titleText: Signal<String?>
    let hashtags: Signal<[String]?>
    let proveTime: Signal<String?>
    let goal: Signal<String?>
    let image: Signal<UIImageWrapper?>
    let rules: Signal<[String]?>
    let endDate: Signal<String?>
  }
  
  // MARK: - Output
  struct Output {
    let networkUnstable: Signal<Void>
    let imageTypeError: Signal<String>
    let fileTooLargeError: Signal<String>
    let notChallengeMember: Signal<String>
  }
  
  // MARK: - Initializers
  init(
    useCase: OrganizeUseCase,
    challengeId: Int
  ) {
    self.useCase = useCase
    self.challengeId = challengeId
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
        owner.modifyChallenge()
      }.disposed(by: disposeBag)
    
    input.didTapConfirmButtonAtAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapAlert()
      }.disposed(by: disposeBag)
    
    transformData(input: input)
    
    return Output(
      networkUnstable: networkUnstableRelay.asSignal(),
      imageTypeError: imageTypeErrorRelay.asSignal(),
      fileTooLargeError: fileTooLargeErrorRelay.asSignal(),
      notChallengeMember: notChallengeMemberRelay.asSignal()
    )
  }
  
  func transformData(input: Input) {
    input.titleText.compactMap { $0 }
      .emit(with: self) { owner, title in
        owner.useCase.configureChallengePayload(.name(title))
      }.disposed(by: disposeBag)
    
    input.hashtags.compactMap { $0 }
      .emit(with: self) { owner, hashtags in
        owner.useCase.configureChallengePayload(.hashtags(hashtags))
      }.disposed(by: disposeBag)
    
    input.goal.compactMap { $0 }
      .emit(with: self) { owner, goal in
        owner.useCase.configureChallengePayload(.goal(goal))
      }.disposed(by: disposeBag)
    
    input.proveTime.compactMap { $0 }
      .emit(with: self) { owner, proveTime in
        owner.useCase.configureChallengePayload(.proveTime(proveTime))
      }.disposed(by: disposeBag)
    
    input.image.compactMap { $0 }
      .emit(with: self) { owner, image in
        guard let (data, type) = owner.imageToData(image, maxMB: 8) else {
          let message = "파일 사이즈는 8MB 이하만 가능합니다."
          owner.fileTooLargeErrorRelay.accept(message)
          return
        }
        owner.useCase.configureChallengePayload(.image(data))
        owner.useCase.configureChallengePayload(.imageType(type))
      }.disposed(by: disposeBag)
    
    input.rules.compactMap { $0 }
      .emit(with: self) { owner, rules in
        owner.useCase.configureChallengePayload(.rules(rules))
      }.disposed(by: disposeBag)
    
    input.endDate.compactMap { $0 }
      .emit(with: self) { owner, endDate in
        owner.useCase.configureChallengePayload(.endDate(endDate))
      }.disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension ChallengeModifyViewModel {
  func modifyChallenge() {
    useCase.modifyChallenge()
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        owner.coordinator?.didModifiedChallenge()
      } onFailure: { owner, error in
        print(error)
        owner.requestFailed(with: error)
      }.disposed(by: disposeBag)
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
  
  func imageToData(_ image: UIImageWrapper, maxMB: Int) -> (image: Data, type: String)? {
    let maxSizeBytes = maxMB * 1024 * 1024
    
    if let data = image.image.pngData(), data.count <= maxSizeBytes {
      return (data, "png")
    } else if let data = image.image.converToJPEG(maxSizeMB: 8) {
      return (data, "jpeg")
    }
    return nil
  }
}

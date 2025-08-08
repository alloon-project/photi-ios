//
//  ChallengePreviewViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core
import Entity
import UseCase

protocol ChallengePreviewCoordinatable: AnyObject {
  func didFinishOrganizeChallenge(challengeId: Int)
  func didTapBackButtonAtPreview()
}

protocol ChallengePreviewViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengePreviewCoordinatable? { get set }
}

final class ChallengePreviewViewModel: ChallengePreviewViewModelType, @unchecked Sendable {
  weak var coordinator: ChallengePreviewCoordinatable?
  private let disposeBag = DisposeBag()
  
  private let useCase: OrganizeUseCase
  private let networkUnstableRelay = PublishRelay<Void>()
  private let emptyFileErrorRelay = PublishRelay<String>()
  private let isLoadingRelay = PublishRelay<Bool>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapOrganizeButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isLoading: Signal<Bool>
    let networkUnstable: Signal<Void>
    let emptyFileError: Signal<String>
  }
  
  // MARK: - Initializers
  init(useCase: OrganizeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtPreview()
      }
      .disposed(by: disposeBag)
    
    input.didTapOrganizeButton
      .throttle(.seconds(5), latest: false, scheduler: MainScheduler.instance)
      .bind(with: self) { owner, _ in
        Task { await owner.organizeChallenge() }
      }
      .disposed(by: disposeBag)
    
    return Output(
      isLoading: isLoadingRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal(),
      emptyFileError: emptyFileErrorRelay.asSignal()
      )
  }
}

// MARK: - Private Methods
private extension ChallengePreviewViewModel {}

// MARK: - API Methods
private extension ChallengePreviewViewModel {
  @MainActor func organizeChallenge() async {
    isLoadingRelay.accept(true)
    
    do {
      let challenge = try await useCase.organizeChallenge().value
      isLoadingRelay.accept(false)
      coordinator?.didFinishOrganizeChallenge(challengeId: challenge.id)
    } catch {
      requestFailed(with: error)
      isLoadingRelay.accept(false)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableRelay.accept(())
    }
    
    switch error {
      case let .organazieFailed(reason) where reason == .emptyFileInvalid:
        let message = "비어있는 파일은 저장할 수 없습니다."
        emptyFileErrorRelay.accept(message)
      default:
        networkUnstableRelay.accept(())
    }
  }
}

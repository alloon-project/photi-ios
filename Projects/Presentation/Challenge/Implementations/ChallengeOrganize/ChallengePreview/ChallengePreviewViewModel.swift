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
  func didFinishOrganizeChallenge()
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
  
  private let useCase: ChallengeUseCase
  private let networkUnstableRelay = PublishRelay<Void>()
  private let emptyFileErrorRelay = PublishRelay<String>()
  private let imageTypeErrorRelay = PublishRelay<String>()
  private let fileTooLargeErrorRelay = PublishRelay<String>()
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapOrganizeButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let networkUnstable: Signal<Void>
    let emptyFileError: Signal<String>
    let imageTypeError: Signal<String>
    let fileTooLargeError: Signal<String>
  }
  
  // MARK: - Initializers
  init(useCase: ChallengeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtPreview()
      }
      .disposed(by: disposeBag)
    
    input.didTapOrganizeButton
      .bind(with: self) { owner, _ in
        owner.organizeChallenge()
      }
      .disposed(by: disposeBag)
    
    return Output(
      networkUnstable: networkUnstableRelay.asSignal(),
      emptyFileError: emptyFileErrorRelay.asSignal(),
      imageTypeError: imageTypeErrorRelay.asSignal(),
      fileTooLargeError: fileTooLargeErrorRelay.asSignal())
  }
}

// MARK: - Private Methods
private extension ChallengePreviewViewModel {}

// MARK: - API Methods
private extension ChallengePreviewViewModel {
  func organizeChallenge() {
    useCase.organizeChallenge()
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        owner.coordinator?.didFinishOrganizeChallenge()
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
      case let .organazieFailed(reason) where reason == .emptyFileInvalid:
        let message = "비어있는 파일은 저장할 수 없습니다."
        emptyFileErrorRelay.accept(message)
      case let .challengeFailed(reason) where reason == .invalidFileFormat:
        let message = "이미지는 '.jpeg', '.jpg', '.png', '.gif' 타입만 가능합니다."
        imageTypeErrorRelay.accept(message)
      case let .challengeFailed(reason) where reason == .fileTooLarge:
        let message = "파일 사이즈는 8MB 이하만 가능합니다."
        fileTooLargeErrorRelay.accept(message)
      default:
        networkUnstableRelay.accept(())
    }
  }
}

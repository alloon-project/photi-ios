//
//  ChallengeCoverViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core
import Entity
import UseCase

protocol ChallengeCoverCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeCover()
  func didFinishedChallengeCover(coverImage: UIImageWrapper)
}

protocol ChallengeCoverViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeCoverCoordinatable? { get set }
}

final class ChallengeCoverViewModel: ChallengeCoverViewModelType {
  let disposeBag = DisposeBag()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase

  weak var coordinator: ChallengeCoverCoordinatable?
  
  private let sampleImagesRelay = PublishRelay<[String]>()
  private let requestFailedRelay = PublishRelay<Void>()
  private let imageSizeErrorRelay = PublishRelay<Void>()

  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: ControlEvent<Void>
    let challengeCoverImage: Observable<UIImageWrapper>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let sampleImages: Signal<[String]>
    let requestFailed: Signal<Void>
    let imageSizeError: Signal<Void>
  }
  
  // MARK: - Initializers
  init(
    mode: ChallengeOrganizeMode,
    useCase: OrganizeUseCase
  ) {
    self.mode = mode
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .emit(with: self) { owner, _ in
        owner.fetchCoverImages()
      }.disposed(by: disposeBag)
    
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeCover()
      }
      .disposed(by: disposeBag)
  
    input.didTapNextButton
      .withLatestFrom(input.challengeCoverImage)
      .bind(with: self) { owner, image in
        guard let (data, type) = owner.imageToData(image, maxMB: 8) else {
          owner.imageSizeErrorRelay.accept(())
          return
        }
        owner.coordinator?.didFinishedChallengeCover(coverImage: image)
        Task {
          await owner.useCase.configureChallengePayload(.image, value: data)
          await owner.useCase.configureChallengePayload(.imageType, value: type)
        }
      }
      .disposed(by: disposeBag)
    
    return Output(
      sampleImages: sampleImagesRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal(),
      imageSizeError: imageSizeErrorRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension ChallengeCoverViewModel {
  func fetchCoverImages() {
    useCase.fetchChallengeSampleImages()
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, images in
        owner.sampleImagesRelay.accept(images)
      } onFailure: { owner, error in
        owner.fetchImagesFailed(with: error)
      }.disposed(by: disposeBag)
  }
  
  func fetchImagesFailed(with error: Error) {
    guard let error = error as? APIError else { return }
    
    switch error {
      default:
        requestFailedRelay.accept(())
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

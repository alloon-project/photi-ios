//
//  ChallengeCoverViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

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
  private let useCase: OrganizeUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChallengeCoverCoordinatable?
  
  private let sampleImagesRelay = PublishRelay<[String]>()
  private let requestFailedRelay = PublishRelay<Void>()

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
  }
  
  // MARK: - Initializers
  init(useCase: OrganizeUseCase) {
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
        owner.coordinator?.didFinishedChallengeCover(coverImage: image)
      }
      .disposed(by: disposeBag)
    
    return Output(
      sampleImages: sampleImagesRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
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
}

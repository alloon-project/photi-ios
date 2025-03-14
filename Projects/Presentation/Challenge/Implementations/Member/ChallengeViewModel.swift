//
//  ChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol ChallengeCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapConfirmButtonAtAlert()
  func didTapLoginButtonAtAlert()
}

protocol ChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeCoordinatable? { get set }
}

final class ChallengeViewModel: ChallengeViewModelType {
  private let useCase: ChallengeUseCase
  
  let disposeBag = DisposeBag()
  let challengeId: Int
  private(set) var challengeName: String = ""
  
  weak var coordinator: ChallengeCoordinatable?
  
  private let challengeModelRelay = BehaviorRelay<ChallengeTitlePresentationModel>(value: .default)
  private let challengeNotFoundRelay = PublishRelay<Void>()
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: Signal<Void>
    let didTapConfirmButtonAtAlert: Signal<Void>
    let didTapLoginButtonAtAlert: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let challengeInfo: Driver<ChallengeTitlePresentationModel>
    let challengeNotFound: Signal<Void>
    let requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: ChallengeUseCase, challengeId: Int) {
    self.useCase = useCase
    self.challengeId = challengeId
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .emit(with: self) { owner, _ in
        owner.fetchChallenge()
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapLoginButtonAtAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapLoginButtonAtAlert()
      }
      .disposed(by: disposeBag)
    
    return Output(
      challengeInfo: challengeModelRelay.asDriver(),
      challengeNotFound: challengeNotFoundRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension ChallengeViewModel {
  func fetchChallenge() {
    useCase.fetchChallengeDetail(id: challengeId)
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, challenge in
        let model = owner.mapToPresentatoinModel(challenge)
        owner.challengeModelRelay.accept(model)
        owner.challengeName = challenge.name
      }
      .disposed(by: disposeBag)
  }
  
  func mapToPresentatoinModel(_ challenge: ChallengeDetail) -> ChallengeTitlePresentationModel {
    return .init(
      title: challenge.name,
      hashTags: challenge.hashTags,
      imageURL: challenge.imageUrl
    )
  }
}

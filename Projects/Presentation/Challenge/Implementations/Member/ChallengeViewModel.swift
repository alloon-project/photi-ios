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
  func authenticatedFailed()
  func leaveChallenge(challengeId: Int)
  func attachChallengeReport()
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
  private let memberCount = BehaviorRelay<Int>(value: 0)
  private let challengeNotFoundRelay = PublishRelay<Void>()
  private let networkUnstable = PublishRelay<Void>()
  private let loginTriggerRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: Signal<Void>
    let didTapConfirmButtonAtAlert: Signal<Void>
    let didTapLoginButtonAtAlert: Signal<Void>
    let didTapLeaveButton: Signal<Void>
    let didTapReportButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let challengeInfo: Driver<ChallengeTitlePresentationModel>
    let memberCount: Driver<Int>
    let challengeNotFound: Signal<Void>
    let networnUnstable: Signal<Void>
    let loginTrigger: Signal<Void>
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
        owner.coordinator?.attachLogIn()
      }
      .disposed(by: disposeBag)
    
    input.didTapReportButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachChallengeReport()
      }
      .disposed(by: disposeBag)
    
    input.didTapLeaveButton
      .emit(with: self) { owner, _ in
        owner.leaveChallenge()
      }
      .disposed(by: disposeBag)
    
    input.didTapConfirmButtonAtAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapConfirmButtonAtAlert()
      }
      .disposed(by: disposeBag)
    
    return Output(
      challengeInfo: challengeModelRelay.asDriver(),
      memberCount: memberCount.asDriver(),
      challengeNotFound: challengeNotFoundRelay.asSignal(),
      networnUnstable: networkUnstable.asSignal(),
      loginTrigger: loginTriggerRelay.asSignal()
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
        owner.memberCount.accept(challenge.memberCount)
        owner.challengeName = challenge.name
      } onFailure: { owner, error in
        owner.requestFailed(with: error)
      }
      .disposed(by: disposeBag)
  }
  
  func leaveChallenge() {
    useCase.leaveChallenge(id: challengeId)
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        owner.coordinator?.leaveChallenge(challengeId: owner.challengeId)
      } onFailure: { owner, error in
        owner.requestFailed(with: error)
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
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstable.accept(()) }
    
    switch error {
      case .authenticationFailed:
        loginTriggerRelay.accept(())
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        challengeNotFoundRelay.accept(())
      default: networkUnstable.accept(())
    }
  }
}

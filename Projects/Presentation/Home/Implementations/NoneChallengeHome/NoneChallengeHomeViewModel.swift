//
//  NoneChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol NoneChallengeHomeCoordinatable: AnyObject {
  func attachNoneMemberChallenge(challengeId: Int)
}

protocol NoneChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: NoneChallengeHomeCoordinatable? { get set }
}

final class NoneChallengeHomeViewModel: NoneChallengeHomeViewModelType {
  private let useCase: HomeUseCase
  let disposeBag = DisposeBag()
  
  weak var coordinator: NoneChallengeHomeCoordinatable?
  
  private let challengesRelay = PublishRelay<[ChallengePresentationModel]>()
  private let requestFailedRelay = PublishRelay<Void>()

  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let requestJoinChallenge: Signal<Int>
  }
  
  // MARK: - Output
  struct Output {
    let challenges: Signal<[ChallengePresentationModel]>
    let requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: HomeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .emit(with: self) { owner, _ in
        owner.fetchPopularChallenge()
      }
      .disposed(by: disposeBag)
    
    input.requestJoinChallenge
      .emit(with: self) { owner, id in
        owner.coordinator?.attachNoneMemberChallenge(challengeId: id)
      }
      .disposed(by: disposeBag)
    
    return Output(
      challenges: challengesRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension NoneChallengeHomeViewModel {
  func fetchPopularChallenge() {
    useCase.fetchPopularChallenge()
      .subscribe(
        with: self,
        onSuccess: { owner, challenges in
          let models = challenges.map { owner.mapToChallengePresentationModel($0) }
          
          owner.challengesRelay.accept(models)
        },
        onFailure: { owner, _ in
          owner.requestFailedRelay.accept(())
        }
      )
      .disposed(by: disposeBag)
  }
  
  func mapToChallengePresentationModel(_ challenge: ChallengeDetail) -> ChallengePresentationModel {
    let proveTime = challenge.proveTime.toString("HH:mm")
    let endDate = challenge.endDate.toString("yyyy.MM.dd")
    
    return .init(
      id: challenge.id,
      name: challenge.name,
      imageURL: challenge.imageUrl,
      goal: challenge.goal,
      proveTime: proveTime,
      endDate: endDate,
      numberOfPersons: challenge.memberCount,
      hashTags: challenge.hashTags,
      memberImageURLs: challenge.memberImages
    )
  }
}

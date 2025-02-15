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

protocol NoneChallengeHomeCoordinatable: AnyObject { }

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
    let viewWillAppear: Signal<Void>
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
    input.viewWillAppear
      .emit(with: self) { owner, _ in
        owner.fetchPopularChallenge()
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
        onFailure: { owner, err in
          print(err)
          owner.requestFailedRelay.accept(())
        }
      )
      .disposed(by: disposeBag)
  }
  
  func mapToChallengePresentationModel(_ challenge: Challenge) -> ChallengePresentationModel {
    let proveTime = challenge.proveTime.toString("HH:mm")
    let endDate = challenge.endDate.toString("yyyy.MM.dd")
    
    return .init(
      name: challenge.name,
      imageURL: challenge.imageURL,
      goal: challenge.goal,
      proveTime: proveTime,
      endDate: endDate,
      numberOfPersons: 0,
      hashTags: challenge.hashTags
    )
  }
}

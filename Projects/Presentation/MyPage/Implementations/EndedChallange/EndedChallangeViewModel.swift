//
//  EndedChallengeViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol EndedChallengeCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallengeDetail()
  func detachChallengeDetail()
}

protocol EndedChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EndedChallengeCoordinatable? { get set }
}

final class EndedChallengeViewModel: EndedChallengeViewModelType {
  private let useCase: EndedChallengeUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: EndedChallengeCoordinatable?
  
  private let maxSize: Int = 10
  private let userEndedChallengeHistoryRelay = BehaviorRelay<[EndedChallengeCardCellPresentationModel]>(value: [])
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let isVisible: Observable<Bool>
  }
  
  // MARK: - Output
  struct Output {
    let endedChallenges: Driver<[EndedChallengeCardCellPresentationModel]>
    let requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: EndedChallengeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)

    input.isVisible
      .bind(with: self) { [weak self] onwer, _ in
        guard let self = self else { return }
        onwer.fetchEndedChallenges(page: 0, size: self.maxSize)
      }.disposed(by: disposeBag)
    
    return Output(
      endedChallenges: userEndedChallengeHistoryRelay.asDriver(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private
private extension EndedChallengeViewModel {
  func fetchEndedChallenges(page: Int, size: Int) {
    useCase.endedChallenges(page: page, size: size)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { onwer, endedChallengeList in
          let models = endedChallengeList.map { onwer.mapToEndedPresentationModel($0) }
          
          onwer.userEndedChallengeHistoryRelay.accept(models)
        },
        onFailure: { onwer, error in
          print(error)
          onwer.requestFailedRelay.accept(())
        }
      )
      .disposed(by: disposeBag)
  }
  
  func mapToEndedPresentationModel(_ challenge: EndedChallenge) -> EndedChallengeCardCellPresentationModel {
    let endDate = challenge.endDate.toString("yyyy.MM.dd")
    
    return .init(
      challengeImageUrl: challenge.imageUrl,
      challengeTitle: challenge.name,
      endedDate: endDate,
      challengeId: challenge.id,
      currentMemberCnt: challenge.currentMemberCnt,
      challengeParticipantImageUrls: challenge.memberImages
    )
  }
}

//
//  FeedHistoryViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol FeedHistoryCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallengeDetail()
  func detachChallengeDetail()
}

protocol FeedHistoryViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: FeedHistoryCoordinatable? { get set }
}

final class FeedHistoryViewModel: FeedHistoryViewModelType {
  private let useCase: FeedUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: FeedHistoryCoordinatable?
  
  private let maxSize: Int = 10
  private let userFeedHistoryRelay = BehaviorRelay<[FeedHistoryCellPresentationModel]>(value: [])
  private let isLastDataRelay = BehaviorRelay(value: false)
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let isVisible: Observable<Bool>
    let isNeedMoreData: Observable<Int>
  }
  
  // MARK: - Output
  struct Output {
    let feedHistory: Driver<[FeedHistoryCellPresentationModel]>
    let isLastData: Signal<Bool>
    let requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: FeedUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.isVisible
      .bind(with: self) { owner, isVisible in
        if isVisible {
          owner.fetchFeedHistory(page: 0, size: owner.maxSize)
        }
      }.disposed(by: disposeBag)
    
    input.isNeedMoreData
      .bind(with: self) { owner, currentCount in
        owner.fetchFeedHistory(page: currentCount / owner.maxSize, size: owner.maxSize)
      }.disposed(by: disposeBag)
    
    return Output(
      feedHistory: userFeedHistoryRelay.asDriver(),
      isLastData: isLastDataRelay.asSignal(onErrorJustReturn: false),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension FeedHistoryViewModel {
  func fetchFeedHistory(page: Int, size: Int) {
    useCase.fetchFeeds(page: page, size: size)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, feedHistoryList in
          let models = feedHistoryList.content.map { owner.mapToFeedPresentationModel($0) }
          owner.userFeedHistoryRelay.accept(models)
        },
        onFailure: { owner, error in
          owner.requestFailedRelay.accept(())
        }
      ).disposed(by: disposeBag)
  }
  
  func mapToFeedPresentationModel(_ feedInfo: FeedInfo) -> FeedHistoryCellPresentationModel {
    let date = feedInfo.provedDate.toString("yyyy. MM. MM")
    return .init(
      challengeImageUrl: feedInfo.imageUrl,
      challengeTitle: feedInfo.name,
      provedDate: date,
      challengeId: feedInfo.challengeId
    )
  }
}

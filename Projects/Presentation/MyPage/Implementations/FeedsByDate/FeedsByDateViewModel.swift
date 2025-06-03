//
//  FeedsByDateViewModel.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core
import Entity
import UseCase

protocol FeedsByDateCoordinatable: AnyObject {
  func didTapBackButton()
}

protocol FeedsByDateViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedsByDateCoordinatable? { get set }
}

final class FeedsByDateViewModel: FeedsByDateViewModelType {
  weak var coordinator: FeedsByDateCoordinatable?
  private let disposeBag = DisposeBag()
  private let useCase: MyPageUseCase
  let date: Date
  
  private let feedsRelay = BehaviorRelay<[FeedsByDatePresentationModel]>(value: [])
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let feeds: Driver<[FeedsByDatePresentationModel]>
  }
  
  // MARK: - Initializers
  init(date: Date, useCase: MyPageUseCase) {
    self.date = date
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.loadFeedsByDate() }
      }
      .disposed(by: disposeBag)
    
    return Output(feeds: feedsRelay.asDriver())
  }
}

// MARK: - API Methods
private extension FeedsByDateViewModel {
  func loadFeedsByDate() async {
    let date = date.convertTimezone(from: .current, to: .kst).toString("YYYY-MM-dd")
    
    do {
      let feeds = try await useCase.loadFeeds(byDate: date)
      let models = feeds.map { mapToFeedsByDatePresentationModel($0) }
      
      feedsRelay.accept(models)
    } catch {
      // TODO: 에러 구현
      print(error)
    }
  }
}

// MARK: - Private Methods
private extension FeedsByDateViewModel {
  func mapToFeedsByDatePresentationModel(_ feed: FeedSummary) -> FeedsByDatePresentationModel {
    let provedTime = feed.proveTime.convertTimezone(from: .current, to: .kst)
      .toString("HH:mm")
    return .init(
      challengeId: feed.challengeId,
      feedId: feed.feedId,
      feedImageViewUrl: feed.imageUrl,
      title: feed.name,
      provedTime: provedTime
    )
  }
}

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
  func authenticateFailed()
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
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let feeds: Driver<[FeedsByDatePresentationModel]>
    let networkUnstable: Signal<Void>
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
    
    return Output(
      feeds: feedsRelay.asDriver(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
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
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    if case .authenticationFailed = error {
      coordinator?.authenticateFailed()
    } else {
      networkUnstableRelay.accept(())
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

//
//  MyPageViewModel.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Entity
import UseCase

protocol MyPageCoordinatable: AnyObject {
  func attachSetting()
  func attachEndedChallenge()
  func attachFeedHistory(count: Int)
  func authenticatedFailed()
}

protocol MyPageViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: MyPageCoordinatable? { get set }
}

final class MyPageViewModel: MyPageViewModelType {
  private let useCase: MyPageUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: MyPageCoordinatable?
  private let username = BehaviorRelay(value: "")
  private let profileImageURL = BehaviorRelay<URL?>(value: nil)
  private let calendarStartDate = BehaviorRelay<Date>(value: Date())
  private let verifiedChallengeDates = BehaviorRelay<[Date]>(value: [])
  private let feedHistoryCount = BehaviorRelay(value: 0)
  private let endedChallengeCount = BehaviorRelay(value: 0)
  
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapSettingButton: ControlEvent<Void>
    let didTapAuthCountBox: ControlEvent<Void>
    let didTapEndedChallengeBox: ControlEvent<Void>
    let didBecomeVisible: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let username: Driver<String>
    let profileImageURL: Driver<URL?>
    let feedsCount: Driver<Int>
    let endedChallengeCount: Driver<Int>
    let calendarStartDate: Driver<Date>
    let verifiedChallengeDates: Driver<[Date]>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapSettingButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachSetting()
      }.disposed(by: disposeBag)
    
    input.didTapAuthCountBox
      .withLatestFrom(feedHistoryCount)
      .filter { $0 > 0 }
      .bind(with: self) { owner, count in
        owner.coordinator?.attachFeedHistory(count: count)
      }
      .disposed(by: disposeBag)
    
    input.didTapEndedChallengeBox
      .withLatestFrom(endedChallengeCount)
      .filter { $0 > 0 }
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachEndedChallenge()
      }
      .disposed(by: disposeBag)
    
    input.didBecomeVisible
      .emit(with: self) { owner, _ in
        owner.loadData()
      }
      .disposed(by: disposeBag)
    
    return Output(
      username: username.asDriver(),
      profileImageURL: profileImageURL.asDriver(),
      feedsCount: feedHistoryCount.asDriver(),
      endedChallengeCount: endedChallengeCount.asDriver(),
      calendarStartDate: calendarStartDate.asDriver(),
      verifiedChallengeDates: verifiedChallengeDates.asDriver()
    )
  }
}

// MARK: - Private
private extension MyPageViewModel {
  func loadData() {
    Task { await loadUserInformation() }
    Task { await loadVerifiedChallengeDates() }
  }
  
  func loadUserInformation() async {
    do {
      let summary = try await useCase.loadMyPageSummry().value
      username.accept(summary.userName)
      calendarStartDate.accept(summary.registerDate)
      profileImageURL.accept(summary.imageUrl)
      feedHistoryCount.accept(summary.feedCount)
      endedChallengeCount.accept(summary.endedChallengeCount)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func loadVerifiedChallengeDates() async {
    do {
      let dates = try await useCase.loadVerifiedChallengeDates().value
      verifiedChallengeDates.accept(dates)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.accept(())
    }
  }
}

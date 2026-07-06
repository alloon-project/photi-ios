//
//  MyPageViewModel.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import CoreUI
import Foundation
import Entity
import UseCase

protocol MyPageCoordinatable: AnyObject {
  @MainActor func attachSetting()
  @MainActor func attachEndedChallenge(count: Int)
  @MainActor func attachFeedHistory(count: Int)
  @MainActor func attachFeedsBy(date: Date)
  func authenticatedFailed()
}

protocol MyPageViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var cancellables: Set<AnyCancellable> { get set }
  var coordinator: MyPageCoordinatable? { get set }
}

final class MyPageViewModel: MyPageViewModelType {
  private let useCase: MyPageUseCase
  
  private var cancellables = Set<AnyCancellable>()
  
  weak var coordinator: MyPageCoordinatable?
  private let username = CurrentValueSubject<String, Never>("")
  private let profileImageURL = CurrentValueSubject<URL?, Never>(nil)
  private let calendarStartDate = CurrentValueSubject<Date, Never>(Date())
  private let verifiedChallengeDates = CurrentValueSubject<[Date], Never>([])
  private let feedHistoryCount = CurrentValueSubject<Int, Never>(0)
  private let endedChallengeCount = CurrentValueSubject<Int, Never>(0)
  private let todayRelay = CurrentValueSubject<Date, Never>(Date())
  
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapSettingButton: AnyPublisher<Void, Never>
    let didTapAuthCountBox: AnyPublisher<Void, Never>
    let didTapEndedChallengeBox: AnyPublisher<Void, Never>
    let didBecomeVisible: AnyPublisher<Void, Never>
    let didTapDate: AnyPublisher<Date, Never>
  }
  
  // MARK: - Output
  struct Output {
    let username: AnyPublisher<String, Never>
    let profileImageURL: AnyPublisher<URL?, Never>
    let feedsCount: AnyPublisher<Int, Never>
    let endedChallengeCount: AnyPublisher<Int, Never>
    let calendarStartDate: AnyPublisher<Date, Never>
    let verifiedChallengeDates: AnyPublisher<[Date], Never>
    let today: AnyPublisher<Date, Never>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapSettingButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachSetting() }
      }.store(in: &cancellables)
    
    input.didTapAuthCountBox
      .withLatestFrom(feedHistoryCount)
      .filter { $0 > 0 }
      .sinkOnMain(with: self) { owner, count in
        Task { await owner.coordinator?.attachFeedHistory(count: count) }
      }
      .store(in: &cancellables)
    
    input.didTapEndedChallengeBox
      .withLatestFrom(endedChallengeCount)
      .filter { $0 > 0 }
      .sinkOnMain(with: self) { owner, count in
        Task { await owner.coordinator?.attachEndedChallenge(count: count) }
      }
      .store(in: &cancellables)
    
    input.didTapDate
      .sinkOnMain(with: self) { owner, date in
        guard owner.verifiedChallengeDates.value.contains(date) else { return }
        Task { await owner.coordinator?.attachFeedsBy(date: date) }
      }
      .store(in: &cancellables)
    
    input.didBecomeVisible
      .sinkOnMain(with: self) { owner, _ in
        owner.loadData()
      }
      .store(in: &cancellables)
    
    return Output(
      username: username.eraseToAnyPublisher(),
      profileImageURL: profileImageURL.eraseToAnyPublisher(),
      feedsCount: feedHistoryCount.eraseToAnyPublisher(),
      endedChallengeCount: endedChallengeCount.eraseToAnyPublisher(),
      calendarStartDate: calendarStartDate.eraseToAnyPublisher(),
      verifiedChallengeDates: verifiedChallengeDates.eraseToAnyPublisher(),
      today: todayRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension MyPageViewModel {
  func loadData() {
    Task { await loadUserInformation() }
    Task { await loadVerifiedChallengeDates() }
    todayRelay.send(todayDate())
  }
  
  func loadUserInformation() async {
    do {
      let summary = try await useCase.loadMyPageSummry()
      username.send(summary.userName)
      calendarStartDate.send(summary.registerDate)
      profileImageURL.send(summary.imageUrl)
      feedHistoryCount.send(summary.feedCount)
      endedChallengeCount.send(summary.endedChallengeCount)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func loadVerifiedChallengeDates() async {
    do {
      let dates = try await useCase.loadVerifiedChallengeDates()
      verifiedChallengeDates.send(dates)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.send(()) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.send(())
    }
  }
}

// MARK: - Private Methods
private extension MyPageViewModel {
  func todayDate() -> Date {
    return Calendar.current.startOfDay(for: Date())
  }
}

//
//  FeedViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Combine
import CoreUI
import Entity
import UseCase

protocol FeedCoordinatable: AnyObject {
  @MainActor func attachFeedDetail(challengeId: Int, feedId: Int)
  func didChangeContentOffset(_ offset: Double)
  func authenticatedFailed()
  func networkUnstable()
  func challengeNotFound()
}

protocol FeedViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedCoordinatable? { get set }
}

enum ProgressType: Equatable {
  case ended
  case `default`(percent: Double)
}

enum ProveMemberType {
  case ended
  case `default`(count: Int)
}

final class FeedViewModel: FeedViewModelType {
  weak var coordinator: FeedCoordinatable?
  private var cancellables = Set<AnyCancellable>()
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  private let modelMapper = FeedPresentatoinModelMapper()

  private var isEnded = false
  private var alignMode: FeedsAlignMode = .recent
  private var proveTime = ""
  private var currentPage = 0
  private var totalMemberCount = 0
  private var isProve: Bool = true
  private var isLastFeedPage: Bool = false
  private var isFetching: Bool = false {
    didSet {
      guard currentPage != 0 else { return }
      isFetching ? startFetchingSubject.send(()) : stopFetchingSubject.send(())
    }
  }

  private let isUploadSuccessSubject = PassthroughSubject<Bool, Never>()
  private let proofSubject = CurrentValueSubject<ProveType, Never>(.didNotProve(""))
  private let proveTimeSubject = CurrentValueSubject<String, Never>("")
  private let proveMemberCountSubject = CurrentValueSubject<ProveMemberType, Never>(.default(count: 0))
  private let provePercentSubject = CurrentValueSubject<ProgressType, Never>(.default(percent: 0))
  private let feedsSubject = CurrentValueSubject<FeedsType, Never>(.initialPage([]))
  private let proveFeedSubject = CurrentValueSubject<[FeedPresentationModel], Never>([])
  private let startFetchingSubject = PassthroughSubject<Void, Never>()
  private let stopFetchingSubject = PassthroughSubject<Void, Never>()
  private let alreadyVerifyFeedSubject = PassthroughSubject<Void, Never>()
  private let fileTooLargeSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let requestData: AnyPublisher<Void, Never>
    let reloadData: AnyPublisher<Void, Never>
    let didTapFeed: AnyPublisher<Int, Never>
    let contentOffset: AnyPublisher<Double, Never>
    let uploadImage: AnyPublisher<UIImageWrapper, Never>
    let requestFeeds: AnyPublisher<Void, Never>
    let feedsAlign: AnyPublisher<FeedsAlignMode, Never>
    let didTapIsLikeButton: AnyPublisher<(Bool, Int), Never>
  }

  // MARK: - Output
  struct Output {
    let isUploadSuccess: AnyPublisher<Bool, Never>
    let proveMemberCount: AnyPublisher<ProveMemberType, Never>
    let provePercent: AnyPublisher<ProgressType, Never>
    let proofRelay: AnyPublisher<ProveType, Never>
    let proveFeed: AnyPublisher<[FeedPresentationModel], Never>
    let feeds: AnyPublisher<FeedsType, Never>
    let startFetching: AnyPublisher<Void, Never>
    let stopFetching: AnyPublisher<Void, Never>
    let alreadyVerifyFeed: AnyPublisher<Void, Never>
    let fileTooLarge: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
    bind()
  }

  func transform(input: Input) -> Output {
    fetchBind(input: input)

    input.didTapFeed
      .sinkOnMain(with: self) { owner, feedId in
        Task { await owner.coordinator?.attachFeedDetail(challengeId: owner.challengeId, feedId: feedId) }
      }
      .store(in: &cancellables)

    input.contentOffset
      .sinkOnMain(with: self) { owner, offset in
        owner.coordinator?.didChangeContentOffset(offset)
      }
      .store(in: &cancellables)

    input.uploadImage
      .sinkOnMain(with: self) { owner, image in
        owner.upload(image: image)
      }
      .store(in: &cancellables)

    return Output(
      isUploadSuccess: isUploadSuccessSubject.eraseToAnyPublisher(),
      proveMemberCount: proveMemberCountSubject.eraseToAnyPublisher(),
      provePercent: provePercentSubject.eraseToAnyPublisher(),
      proofRelay: proofSubject.eraseToAnyPublisher(),
      proveFeed: proveFeedSubject.eraseToAnyPublisher(),
      feeds: feedsSubject.eraseToAnyPublisher(),
      startFetching: startFetchingSubject.eraseToAnyPublisher(),
      stopFetching: stopFetchingSubject.eraseToAnyPublisher(),
      alreadyVerifyFeed: alreadyVerifyFeedSubject.eraseToAnyPublisher(),
      fileTooLarge: fileTooLargeSubject.eraseToAnyPublisher()
    )
  }

  func fetchBind(input: Input) {
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        owner.fetchData()
      }
      .store(in: &cancellables)

    input.reloadData
      .sinkOnMain(with: self) { owner, _ in
        owner.currentPage = 0
        owner.isLastFeedPage = false
        owner.fetchData()
      }
      .store(in: &cancellables)

    input.requestFeeds
      .sinkOnMain(with: self) { owner, _ in
        guard !owner.isLastFeedPage else { return }

        Task { await owner.fetchFeeds() }
      }
      .store(in: &cancellables)

    input.feedsAlign
      .sinkOnMain(with: self) { owner, align in
        guard align != owner.alignMode else { return }
        owner.alignMode = align
        owner.currentPage = 0
        owner.isLastFeedPage = false
        Task { await owner.fetchFeeds() }
      }
      .store(in: &cancellables)

    input.didTapIsLikeButton
      .sinkOnMain(with: self) { owner, result in
        owner.update(isLike: result.0, feedId: result.1)
      }
      .store(in: &cancellables)
  }
}

// MARK: - Internal Methods
extension FeedViewModel {
  func updateIsProveIfNeeded() {
    Task {
      do {
        let isProve = try await useCase.isProve(challengeId: challengeId)

        guard isProve != self.isProve else { return }
        self.isProve = isProve
        isProve ? proofSubject.send(.didProve) : proofSubject.send(.didNotProve(proveTime))
      } catch { }
    }
  }
}

// MARK: - Fetch Methods
private extension FeedViewModel {
  func fetchData() {
    Task {
      await fetchFeeds()
      await fetchChallengeInfo()
      await fetchProveMemberCount()
    }
    
    fetchIsProof()
  }
  
  func fetchChallengeInfo() async {
    do {
      let challenge = try await useCase.fetchChallengeDetail(id: challengeId)
      let proveType = proveMemberCountSubject.value
      totalMemberCount = challenge.memberCount

      isEnded = Date() > challenge.endDate
      if isEnded {
        provePercentSubject.send(.ended)
      } else if case let .default(count) = proveType {
        updateProvePercent(total: totalMemberCount, prove: count)
      }

      let proveTime = challenge.proveTime.toString("HH:mm")
      proveTimeSubject.send(proveTime)
    } catch {
      await requestFailed(with: error)
    }
  }

  func fetchProveMemberCount() async {
    let count = try? await useCase.challengeProveMemberCount(challengeId: challengeId)

    guard let count else { return }

    if isEnded {
      proveMemberCountSubject.send(.ended)
      provePercentSubject.send(.ended)
    } else {
      proveMemberCountSubject.send(.default(count: count))
      updateProvePercent(total: totalMemberCount, prove: count)
    }
  }

  @MainActor func fetchFeeds() async {
    guard !isFetching else { return }
    isFetching = true
    defer {
      isFetching = false
      currentPage += 1
    }
    do {
      let result = try await useCase.fetchFeeds(
        id: challengeId,
        page: currentPage,
        size: 15,
        orderType: alignMode.toOrderType
      )

      switch result {
        case let .defaults(feeds):
          let items = convertToFeedsType(from: feeds)
          feedsSubject.send(items)

        case let .lastPage(feeds):
          isLastFeedPage = true
          let items = convertToFeedsType(from: feeds)
          feedsSubject.send(items)
      }
    } catch {
      requestFailed(with: error)
    }
  }

  func fetchIsProof() {
    Task {
      isProve = (try? await useCase.isProve(challengeId: challengeId)) ?? false
      if isProve { proofSubject.send(.didProve) }
    }
  }
}

// MARK: - Upload Methods
private extension FeedViewModel {
  func upload(image: UIImageWrapper) {
    Task {
      do {
        guard let (imageData, type) = image.imageToData(maxMB: 8)
        else {
          throw APIError.challengeFailed(reason: .fileTooLarge)
        }
        let feed = try await useCase.uploadChallengeFeedProof(id: challengeId, imageData: imageData, type: type)
        let model = modelMapper.mapToFeedPresentationModels([feed])
        isUploadSuccessSubject.send(true)
        proveFeedSubject.send(model)
        await fetchProveMemberCount()
      } catch {
        isUploadSuccessSubject.send(false)
        await requestFailed(with: error)
      }
    }
  }

  func update(isLike: Bool, feedId: Int) {
    Task {
      try? await useCase.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    }
  }
}

// MARK: - Private Methods
private extension FeedViewModel {
  func bind() {
    proveTimeSubject
      .dropFirst()
      .sink { [weak self] time in
        guard let self else { return }
        self.proveTime = time
        guard !self.isProve else { return }
        self.proofSubject.send(.didNotProve(time))
      }
      .store(in: &cancellables)
  }

  func updateProvePercent(total: Int, prove: Int) {
    guard total != 0 else { return provePercentSubject.send(.default(percent: 0)) }
    let percent = Double(prove) / Double(total)
    provePercentSubject.send(.default(percent: percent))
  }

  func convertToFeedsType(from feeds: [[Feed]]) -> FeedsType {
    let models = feeds.flatMap { modelMapper.mapToFeedPresentationModels($0) }

    guard !models.isEmpty else { return .empty }

    return currentPage == 0 ? .initialPage(models) : .default(models)
  }

  @MainActor func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      coordinator?.networkUnstable(); return
    }

    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .challengeFailed(reason) where reason == .alreadyUploadFeed:
        alreadyVerifyFeedSubject.send(())
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        coordinator?.challengeNotFound()
      case let .challengeFailed(reason) where reason == .fileTooLarge:
        fileTooLargeSubject.send(())
      default:
        coordinator?.networkUnstable()
    }
  }
}

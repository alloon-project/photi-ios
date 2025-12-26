//
//  FeedViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
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
  private let disposeBag = DisposeBag()
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
      isFetching ? startFetchingRelay.accept(()) : stopFetchingRelay.accept(())
    }
  }
  
  private let isUploadSuccessRelay = PublishRelay<Bool>()
  private let proofRelay = BehaviorRelay<ProveType>(value: .didNotProve(""))
  private let proveTimeRelay = BehaviorRelay<String>(value: "")
  private let proveMemberCountRelay = BehaviorRelay<ProveMemberType>(value: .default(count: 0))
  private let provePercentRelay = BehaviorRelay<ProgressType>(value: .default(percent: 0))
  private let feedsRelay = BehaviorRelay<FeedsType>(value: .initialPage([]))
  private let proveFeedRelay = BehaviorRelay<[FeedPresentationModel]>(value: [])
  private let startFetchingRelay = PublishRelay<Void>()
  private let stopFetchingRelay = PublishRelay<Void>()
  private let alreadyVerifyFeedRelay = PublishRelay<Void>()
  private let fileTooLargeRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
    let reloadData: Signal<Void>
    let didTapFeed: Signal<Int>
    let contentOffset: Signal<Double>
    let uploadImage: Signal<UIImageWrapper>
    let requestFeeds: Signal<Void>
    let feedsAlign: Driver<FeedsAlignMode>
    let didTapIsLikeButton: Signal<(Bool, Int)>
  }
  
  // MARK: - Output
  struct Output {
    let isUploadSuccess: Signal<Bool>
    let proveMemberCount: Driver<ProveMemberType>
    let provePercent: Driver<ProgressType>
    let proofRelay: Driver<ProveType>
    let proveFeed: Driver<[FeedPresentationModel]>
    let feeds: Driver<FeedsType>
    let startFetching: Signal<Void>
    let stopFetching: Signal<Void>
    let alreadyVerifyFeed: Signal<Void>
    let fileTooLarge: Signal<Void>
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
      .emit(with: self) { owner, feedId in
        Task { await owner.coordinator?.attachFeedDetail(challengeId: owner.challengeId, feedId: feedId) }
      }
      .disposed(by: disposeBag)
    
    input.contentOffset
      .emit(with: self) { owner, offset in
        owner.coordinator?.didChangeContentOffset(offset)
      }
      .disposed(by: disposeBag)
    
    input.uploadImage
      .emit(with: self) { owner, image in
        owner.upload(image: image)
      }
      .disposed(by: disposeBag)
    
    return Output(
      isUploadSuccess: isUploadSuccessRelay.asSignal(),
      proveMemberCount: proveMemberCountRelay.asDriver(),
      provePercent: provePercentRelay.asDriver(),
      proofRelay: proofRelay.asDriver(),
      proveFeed: proveFeedRelay.asDriver(),
      feeds: feedsRelay.asDriver(),
      startFetching: startFetchingRelay.asSignal(),
      stopFetching: stopFetchingRelay.asSignal(),
      alreadyVerifyFeed: alreadyVerifyFeedRelay.asSignal(),
      fileTooLarge: fileTooLargeRelay.asSignal()
    )
  }
  
  func fetchBind(input: Input) {
    input.requestData
      .emit(with: self) { owner, _ in
        owner.fetchData()
      }
      .disposed(by: disposeBag)
    
    input.reloadData
      .emit(with: self) { owner, _ in
        owner.currentPage = 0
        owner.isLastFeedPage = false
        owner.fetchData()
      }
      .disposed(by: disposeBag)
    
    input.requestFeeds
      .emit(with: self) { owner, _ in
        guard !owner.isLastFeedPage else { return }
        
        Task { await owner.fetchFeeds() }
      }
      .disposed(by: disposeBag)
    
    input.feedsAlign
      .drive(with: self) { owner, align in
        guard align != owner.alignMode else { return }
        owner.alignMode = align
        owner.currentPage = 0
        owner.isLastFeedPage = false
        Task { await owner.fetchFeeds() }
      }
      .disposed(by: disposeBag)
    
    input.didTapIsLikeButton
      .emit(with: self) { owner, result in
        owner.update(isLike: result.0, feedId: result.1)
      }
      .disposed(by: disposeBag)
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
        isProve ? proofRelay.accept(.didProve) : proofRelay.accept(.didNotProve(proveTime))
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
      let proveType = proveMemberCountRelay.value
      totalMemberCount = challenge.memberCount
      
      isEnded = Date() > challenge.endDate
      if isEnded {
        provePercentRelay.accept(.ended)
      } else if case let .default(count) = proveType {
        updateProvePercent(total: totalMemberCount, prove: count)
      }
      
      let proveTime = challenge.proveTime.toString("HH:mm")
      proveTimeRelay.accept(proveTime)
    } catch {
      await requestFailed(with: error)
    }
  }
  
  func fetchProveMemberCount() async {
    let count = try? await useCase.challengeProveMemberCount(challengeId: challengeId)
    
    guard let count else { return }

    if isEnded {
      proveMemberCountRelay.accept(.ended)
      provePercentRelay.accept(.ended)
    } else {
      proveMemberCountRelay.accept(.default(count: count))
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
          feedsRelay.accept(items)
          
        case let .lastPage(feeds):
          isLastFeedPage = true
          let items = convertToFeedsType(from: feeds)
          feedsRelay.accept(items)
      }
    } catch {
      requestFailed(with: error)
    }
  }
  
  func fetchIsProof() {
    Task {
      isProve = (try? await useCase.isProve(challengeId: challengeId)) ?? false
      if isProve { proofRelay.accept(.didProve) }
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
        isUploadSuccessRelay.accept(true)
        proveFeedRelay.accept(model)
        await fetchProveMemberCount()
      } catch {
        isUploadSuccessRelay.accept(false)
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
    proveTimeRelay
      .skip(1)
      .subscribe(with: self) { owner, time in
        owner.proveTime = time
        guard !owner.isProve else { return }
        owner.proofRelay.accept(.didNotProve(time))
      }
      .disposed(by: disposeBag)
  }
  
  func updateProvePercent(total: Int, prove: Int) {
    guard total != 0 else { return provePercentRelay.accept(.default(percent: 0)) }
    let percent = Double(prove) / Double(total)
    provePercentRelay.accept(.default(percent: percent))
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
        alreadyVerifyFeedRelay.accept(())
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        coordinator?.challengeNotFound()
      case let .challengeFailed(reason) where reason == .fileTooLarge:
        fileTooLargeRelay.accept(())
      default:
        coordinator?.networkUnstable()
    }
  }
}

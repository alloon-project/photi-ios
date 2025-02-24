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
import Entity
import UseCase

protocol FeedCoordinatable: AnyObject {
  func attachFeedDetail(for feedID: String)
  func didChangeContentOffset(_ offset: Double)
}

protocol FeedViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedCoordinatable? { get set }
}

final class FeedViewModel: FeedViewModelType {
  weak var coordinator: FeedCoordinatable?
  private let disposeBag = DisposeBag()
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  
  private var alignMode: FeedsAlignMode = .recent
  private var currentPage = 0
  private var totalMemberCount = 0
  private var isProof: Bool = false
  private var isLastFeedPage: Bool = false
  private var isFetching: Bool = false {
    didSet {
      guard currentPage != 0 else { return }
      isFetching ? startFetchingRelay.accept(()) : stopFetchingRelay.accept(())
    }
  }
  
  private let isUploadSuccessRelay = PublishRelay<Bool>()
  private let proofRelay = BehaviorRelay<ProveType>(value: .didNotProof(""))
  private let proveTimeRelay = BehaviorRelay<String>(value: "")
  private let proveMemberCountRelay = BehaviorRelay<Int>(value: 0)
  private let provePercentRelay = BehaviorRelay<Double>(value: 0)
  private let feedsRelay = BehaviorRelay<FeedsType>(value: .initialPage([]))
  private let startFetchingRelay = PublishRelay<Void>()
  private let stopFetchingRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapFeed: Signal<String>
    let contentOffset: Signal<Double>
    let uploadImage: Signal<Data>
    let requestFeeds: Signal<Void>
    let feedsAlign: Driver<FeedsAlignMode>
  }
  
  // MARK: - Output
  struct Output {
    let isUploadSuccess: Signal<Bool>
    let proveMemberCount: Driver<Int>
    let provePercent: Driver<Double>
    let proofRelay: Driver<ProveType>
    let feeds: Driver<FeedsType>
    let startFetching: Signal<Void>
    let stopFetching: Signal<Void>
  }
  
  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
    proveTimeRelay
      .skip(1)
      .subscribe(with: self) { owner, time in
        guard !owner.isProof else { return }
        owner.proofRelay.accept(.didNotProof(time))
      }
      .disposed(by: disposeBag)
  }

  func transform(input: Input) -> Output {
    fetchBind(input: input)
   
    input.didTapFeed
      .emit(with: self) {owner, _ in
        owner.coordinator?.attachFeedDetail(for: "0")
      }
      .disposed(by: disposeBag)
    
    input.contentOffset
      .emit(with: self) {owner, offset in
        owner.coordinator?.didChangeContentOffset(offset)
      }
      .disposed(by: disposeBag)
    
    input.uploadImage
      .emit(with: self) { owner, imageData in
        // TODO: - 서버로 전송
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          if imageData.count % 2 == 0 {
            owner.isUploadSuccessRelay.accept(true)
          } else {
            owner.isUploadSuccessRelay.accept(false)
          }
        }
      }
      .disposed(by: disposeBag)
    
    return Output(
      isUploadSuccess: isUploadSuccessRelay.asSignal(),
      proveMemberCount: proveMemberCountRelay.asDriver(),
      provePercent: provePercentRelay.asDriver(),
      proofRelay: proofRelay.asDriver(),
      feeds: feedsRelay.asDriver(),
      startFetching: startFetchingRelay.asSignal(),
      stopFetching: stopFetchingRelay.asSignal()
    )
  }
  
  func fetchBind(input: Input) {
    input.viewDidLoad
      .emit(with: self) { owner, _ in
        Task { await owner.fetchFeeds() }
        owner.fetchChallengeInfo()
        owner.bindMemberCount()
        owner.fetchIsProof()
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
  }
}

// MARK: - Private Methods
private extension FeedViewModel {
  func fetchChallengeInfo() {
    useCase.fetchChallengeDetail(id: challengeId)
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, challenge in
        owner.totalMemberCount = challenge.memberCount
        let proveTime = challenge.proveTime.toString("HH:mm")
        owner.proveTimeRelay.accept(proveTime)
      }
      .disposed(by: disposeBag)
  }
  
  func fetchIsProof() {
    Task {
      isProof = await useCase.isProof()
      if isProof { proofRelay.accept(.didProof) }
    }
  }
  
  func bindMemberCount() {
    useCase.challengeProveMemberCount
      .subscribe(with: self) { owner, count in
        owner.proveMemberCountRelay.accept(count)
        
        guard owner.totalMemberCount != 0 else {
          return owner.provePercentRelay.accept(0)
        }
        
        let percent = Double(count / owner.totalMemberCount)
        owner.provePercentRelay.accept(percent)
      }
      .disposed(by: disposeBag)
  }
  
  func fetchFeeds() async {
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
          let models = feeds.flatMap { mapToPresentationModels($0) }
          let feedsType: FeedsType = currentPage == 0 ? .initialPage(models) : .default(models)
          feedsRelay.accept(feedsType)

        case let .lastPage(feeds):
          let models = feeds.flatMap { mapToPresentationModels($0) }
          isLastFeedPage = true
          feedsRelay.accept(.default(models))
      }
    } catch {
      // TODO: 에러 연결
      print(error)
    }
  }
  
  func mapToPresentationModels(_ feeds: [Feed]) -> [FeedPresentationModel] {
    return feeds.map { feed in
      return .init(
        id: feed.id,
        imageURL: feed.imageURL,
        userName: feed.author,
        updateTime: mapToUpdateTimeString(feed.updateTime),
        isLike: feed.isLike
      )
    }
  }
  
  func mapToUpdateTimeString(_ date: Date) -> String {
    let current = Date()

    guard current.year == date.year else {
      return "\(abs(current.year - date.year))년 전"
    }
    
    guard current.month == date.month else {
      return "\(abs(current.month - date.month))년 전"
    }
    
    guard current.day == date.day else {
      return "\(abs(current.day - date.day))일 전"
    }
    
    guard current.hour == date.hour else {
      return "\(abs(current.hour - date.hour))시간 전"
    }
    
    guard current.minute != date.minute else {
      return "방금"
    }
    
    let temp = abs(current.minute - date.minute)
    switch temp {
      case 0...10: return "\(temp)분 전"
      default: return "\(temp / 10)분 전"
    }
  }
}

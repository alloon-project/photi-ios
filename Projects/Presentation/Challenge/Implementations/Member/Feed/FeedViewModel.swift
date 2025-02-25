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
import Core
import Entity
import UseCase

protocol FeedCoordinatable: AnyObject {
  func attachFeedDetail(for feedID: String)
  func didChangeContentOffset(_ offset: Double)
  func requestLogin()
  func didTapConfirmButtonAtAlert()
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
  private var isProve: Bool = false
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
  private let proveMemberCountRelay = BehaviorRelay<Int>(value: 0)
  private let provePercentRelay = BehaviorRelay<Double>(value: 0)
  private let feedsRelay = BehaviorRelay<FeedsType>(value: .initialPage([]))
  private let startFetchingRelay = PublishRelay<Void>()
  private let stopFetchingRelay = PublishRelay<Void>()
  private let loginTriggerRelay = PublishRelay<Void>()
  private let alreadyVerifyFeedRelay = PublishRelay<Void>()
  private let challengeNotFoundRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  private let fileTooLargeRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapConfirmButtonAtAlert: Signal<Void>
    let didTapLoginButton: Signal<Void>
    let requestData: Signal<Void>
    let reloadData: Signal<Void>
    let didTapFeed: Signal<String>
    let contentOffset: Signal<Double>
    let uploadImage: Signal<UIImageWrapper>
    let requestFeeds: Signal<Void>
    let feedsAlign: Driver<FeedsAlignMode>
    let didTapIsLikeButton: Signal<(Bool, Int)>
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
    let loginTrigger: Signal<Void>
    let alreadyVerifyFeed: Signal<Void>
    let challengeNotFound: Signal<Void>
    let networkUnstable: Signal<Void>
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
    
    input.didTapConfirmButtonAtAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapConfirmButtonAtAlert()
      }
      .disposed(by: disposeBag)
    
    input.didTapLoginButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.requestLogin()
      }
      .disposed(by: disposeBag)
   
    input.didTapFeed
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachFeedDetail(for: "0")
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
      feeds: feedsRelay.asDriver(),
      startFetching: startFetchingRelay.asSignal(),
      stopFetching: stopFetchingRelay.asSignal(),
      loginTrigger: loginTriggerRelay.asSignal(),
      alreadyVerifyFeed: alreadyVerifyFeedRelay.asSignal(),
      challengeNotFound: challengeNotFoundRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal(),
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

// MARK: - Fetch Methods
private extension FeedViewModel {
  func fetchData() {
    Task { await fetchFeeds() }
    fetchChallengeInfo()
    fetchIsProof()
  }
  
  func fetchChallengeInfo() {
    useCase.fetchChallengeDetail(id: challengeId)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, challenge in
          owner.totalMemberCount = challenge.memberCount
          let proveTime = challenge.proveTime.toString("HH:mm")
          owner.proveTimeRelay.accept(proveTime)
        },
        onFailure: { owner, error in
          owner.requestFailed(with: error)
        }
      )
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
          sleep(2)
          feedsRelay.accept(feedsType)

        case let .lastPage(feeds):
          let models = feeds.flatMap { mapToPresentationModels($0) }
          isLastFeedPage = true
          sleep(2)
          feedsRelay.accept(.default(models))
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

  func upload(image: UIImageWrapper) {
    var dataType: String
    var imageData: Data
    let maxSizeBytes = 8 * 1024 * 1024
    
    if let data = image.image.pngData(), data.count <= maxSizeBytes {
      imageData = data
      dataType = "png"
    } else if let data = image.image.converToJPEG(maxSizeMB: 8) {
      imageData = data
      dataType = "jpeg"
    } else {
      fileTooLargeRelay.accept(())
      return isUploadSuccessRelay.accept(false)
    }
      
    Task {
      do {
        try await useCase.uploadChallengeFeedProof(id: challengeId, image: imageData, imageType: dataType)
        isUploadSuccessRelay.accept(true)
      } catch {
        isUploadSuccessRelay.accept(false)
        requestFailed(with: error)
      }
    }
  }
  
  func update(isLike: Bool, feedId: Int) {
    Task {
      try? await useCase.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableRelay.accept(())
    }
    
    switch error {
      case .authenticationFailed:
        loginTriggerRelay.accept(())
      case let .challengeFailed(reason) where reason == .alreadyUploadFeed:
        alreadyVerifyFeedRelay.accept(())
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        challengeNotFoundRelay.accept(())
      default:
        networkUnstableRelay.accept(())
    }
  }
}

// MARK: - Private Methods
private extension FeedViewModel {
  func bind() {
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
    
    proveTimeRelay
      .skip(1)
      .subscribe(with: self) { owner, time in
        guard !owner.isProve else { return }
        owner.proofRelay.accept(.didNotProve(time))
      }
      .disposed(by: disposeBag)
  }
  
  func mapToPresentationModels(_ feeds: [Feed]) -> [FeedPresentationModel] {
    return feeds.map { feed in
      let convertDate = feed.updateTime.convertTimezone(from: .kst)
      return .init(
        id: feed.id,
        imageURL: feed.imageURL,
        userName: feed.author,
        updateTime: mapToUpdateTimeString(convertDate),
        updateGroup: mapToUpdateGroup(convertDate),
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
  
  func mapToUpdateGroup(_ date: Date) -> String {
    let current = Date()

    guard current.year == date.year else {
      return "\(abs(current.year - date.year))년 전"
    }
    
    guard current.month == date.month else {
      return "\(abs(current.month - date.month))년 전"
    }
    
    let temp = abs(current.day - date.day)
    return temp == 0 ? "오늘" : "\(temp)일 전"
  }
}

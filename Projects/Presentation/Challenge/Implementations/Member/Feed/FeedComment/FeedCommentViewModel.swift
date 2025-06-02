//
//  FeedDetailViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core
import Entity
import UseCase

protocol FeedCommentCoordinatable: AnyObject {
  func requestDismiss()
  func deleteFeed(id: Int)
  func authenticatedFailed()
  func requestReport(id: Int)
  func networkUnstable(reason: String?)
  func updateLikeState(feedId: Int, isLiked: Bool)
}

protocol FeedCommentViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedCommentCoordinatable? { get set }
}

final class FeedCommentViewModel: FeedCommentViewModelType {
  weak var coordinator: FeedCommentCoordinatable?
  private let modelMapper = FeedPresentatoinModelMapper()
  private let disposeBag = DisposeBag()
  private let useCase: FeedUseCase
  private let challengeId: Int
  private let feedId: Int
  
  private var isFetching: Bool = false
  private var isLastPage: Bool = false
  private var currentPage: Int = 0
  
  private let authorRelay = BehaviorRelay<AuthorPresentationModel>(value: .default)
  private let updateTimeRelay = BehaviorRelay<String>(value: "")
  private let dropDownOptionsRelay = BehaviorRelay<[String]>(value: [])
  private let likeCountRelay = BehaviorRelay<Int>(value: 0)
  private let isLikeRelay = BehaviorRelay<Bool>(value: false)
  private let feedImageURLRelay = BehaviorRelay<URL?>(value: nil)
  private let commentsRelay = BehaviorRelay<FeedCommentType>(value: .initialPage([]))
  private let stopLoadingAnimation = PublishRelay<Void>()
  private let deleteCommentRelay = PublishRelay<Int>()
  private let commentRelay = PublishRelay<FeedCommentPresentationModel>()
  private let uploadCommentSuccessRelay = PublishRelay<(String, Int)>()
  private let uploadCommentFailedRelay = PublishRelay<String>()
  
  // MARK: - Input
  struct Input {
    let didTapBackground: Signal<Void>
    let requestComments: Signal<Void>
    let requestData: Signal<Void>
    let didTapLikeButton: Signal<Bool>
    let didTapShareButton: Signal<Void>
    let didTapDeleteButton: Signal<Void>
    let didTapReportButton: Signal<Void>
    let requestDeleteComment: Signal<Int>
    let requestUploadComment: Signal<String>
  }
  
  // MARK: - Output
  struct Output {
    let feedImageURL: Driver<URL?>
    let updateTime: Driver<String>
    let isEditable: Driver<Bool>
    let author: Driver<AuthorPresentationModel>
    let likeCount: Driver<Int>
    let isLike: Driver<Bool>
    let comments: Driver<FeedCommentType>
    let dropDownOptions: Driver<[String]>
    let stopLoadingAnimation: Signal<Void>
    let deleteComment: Signal<Int>
    let comment: Signal<FeedCommentPresentationModel>
    let uploadCommentSuccess: Signal<(String, Int)>
    let uploadCommentFailed: Signal<String>
  }
  
  // MARK: - Initializers
  init(
    useCase: FeedUseCase,
    challengeId: Int,
    feedID: Int
  ) {
    self.useCase = useCase
    self.challengeId = challengeId
    self.feedId = feedID
  }
  
  func transform(input: Input) -> Output {
    bindRequest(input: input)
    
    input.didTapBackground
      .emit(with: self) { owner, _ in
        owner.coordinator?.requestDismiss()
      }
      .disposed(by: disposeBag)
    
    input.didTapLikeButton
      .debounce(.milliseconds(500))
      .emit(with: self) { owner, isLike in
        Task { await owner.updateLikeState(isLike: isLike) }
      }
      .disposed(by: disposeBag)
    
    input.didTapReportButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.requestReport(id: owner.feedId)
      }
      .disposed(by: disposeBag)
    
    let isEditable = authorRelay.map { $0.name == ServiceConfiguration.shared.userName }
    
    return Output(
      feedImageURL: feedImageURLRelay.asDriver(),
      updateTime: updateTimeRelay.asDriver(),
      isEditable: isEditable.asDriver(onErrorJustReturn: false),
      author: authorRelay.asDriver(),
      likeCount: likeCountRelay.asDriver(),
      isLike: isLikeRelay.asDriver(),
      comments: commentsRelay.asDriver(),
      dropDownOptions: dropDownOptionsRelay.asDriver(),
      stopLoadingAnimation: stopLoadingAnimation.asSignal(),
      deleteComment: deleteCommentRelay.asSignal(),
      comment: commentRelay.asSignal(),
      uploadCommentSuccess: uploadCommentSuccessRelay.asSignal(),
      uploadCommentFailed: uploadCommentFailedRelay.asSignal()
    )
  }
  
  func bindRequest(input: Input) {
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.fetchData() }
      }
      .disposed(by: disposeBag)
    
    input.requestComments
      .emit(with: self) { owner, _ in
        guard !owner.isLastPage else { return owner.stopLoadingAnimation.accept(()) }
        Task {
          await owner.fetchFeedComments()
          owner.stopLoadingAnimation.accept(())
        }
      }
      .disposed(by: disposeBag)
    
    input.requestUploadComment
      .emit(with: self) { owner, comment in
        let model = owner.modelMapper.feedCommentPresentationModel(comment)
        owner.commentRelay.accept(model)
        Task { await owner.uploadComment(modelId: model.id, comment: comment) }
      }
      .disposed(by: disposeBag)
    
    input.requestDeleteComment
      .emit(with: self) { owner, id in
        Task { await owner.deleteFeedComment(commentId: id) }
      }
      .disposed(by: disposeBag)
    
    input.didTapDeleteButton
      .emit(with: self) { owner, _ in
        Task { await owner.deleteFeed() }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Fetch Method
private extension FeedCommentViewModel {
  func fetchData() async {
    do {
      try await fetchFeedWithThrowing()
      try await fetchFeedCommentsWithThrowing()
    } catch {
      await requestFailed(with: error, reasonWhenNetworkUnstable: nil)
    }
  }
  
  func fetchFeed() async {
    do {
      try await fetchFeedWithThrowing()
    } catch {
      await requestFailed(with: error, reasonWhenNetworkUnstable: nil)
    }
  }
  
  func fetchFeedWithThrowing() async throws {
    let result = try await useCase.fetchFeed(challengeId: challengeId, feedId: feedId)
    let updateTime = modelMapper.mapToUpdateTimeString(result.updateTime)
    let author = modelMapper.mapToAuthorPresentaionModel(author: result.author, url: result.authorImageURL)
    
    let options = author.name == ServiceConfiguration.shared.userName ? ["공유하기", "피드 삭제하기"] : ["신고하기"]
    dropDownOptionsRelay.accept(options)
    
    feedImageURLRelay.accept(result.imageURL)
    authorRelay.accept(author)
    updateTimeRelay.accept(updateTime)
    likeCountRelay.accept(result.likeCount)
    isLikeRelay.accept(result.isLike)
  }
  
  func fetchFeedComments() async {
    do {
      try await fetchFeedCommentsWithThrowing()
    } catch {
      await requestFailed(with: error, reasonWhenNetworkUnstable: nil)
    }
  }
  
  func fetchFeedCommentsWithThrowing() async throws {
    guard !isFetching else { return stopLoadingAnimation.accept(()) }
    isFetching = true
    defer {
      isFetching = false
      currentPage += 1
    }
    
    let result = try await useCase.fetchFeedComments(
      feedId: feedId,
      page: currentPage,
      size: 10
    )
    
    switch result {
      case let .defaults(comments):
        let models = modelMapper.mapToFeedCommentPresentationModels(comments)
        let page: FeedCommentType = currentPage == 0 ? .initialPage(models) : .default(models)
        commentsRelay.accept(page)
      case let .lastPage(comments):
        let models = modelMapper.mapToFeedCommentPresentationModels(comments)
        let page: FeedCommentType = currentPage == 0 ? .initialPage(models) : .default(models)
        isLastPage = true
        commentsRelay.accept(page)
    }
  }
}

// MARK: - Private Methods
private extension FeedCommentViewModel {
  @MainActor
  func updateLikeState(isLike: Bool) async {
    guard isLikeRelay.value != isLike else { return }
    let count = likeCountRelay.value
    let adder = isLike ? 1 : -1
    likeCountRelay.accept(count + adder)
    isLikeRelay.accept(isLike)
    
    do {
      try await useCase.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
      coordinator?.updateLikeState(feedId: feedId, isLiked: isLike)
    } catch { }
  }
  
  @MainActor
  func uploadComment(modelId: String, comment: String) async {
    do {
      let commentId = try await useCase.uploadFeedComment(challengeId: challengeId, feedId: feedId, comment: comment)
      uploadCommentSuccessRelay.accept((modelId, commentId))
    } catch {
      let message = "코멘트 등록에 실패했어요.\n잠시후 다시 시도해주세요."
      uploadCommentFailedRelay.accept(modelId)
      requestFailed(with: error, reasonWhenNetworkUnstable: message)
    }
  }
  
  @MainActor
  func deleteFeedComment(commentId: Int) async {
    do {
      try await useCase.deleteFeedComment(challengeId: challengeId, feedId: feedId, commentId: commentId)
      deleteCommentRelay.accept(commentId)
    } catch {
      let message = "코멘트 삭제에 실패했어요.\n잠시후 다시 시도해주세요."
      requestFailed(with: error, reasonWhenNetworkUnstable: message)
    }
  }
  
  @MainActor
  func deleteFeed() async {
    do {
      try await useCase.deleteFeed(challengeId: challengeId, feedId: feedId).value
      coordinator?.deleteFeed(id: feedId)
    } catch {
      let message = "피드 삭제에 실패했어요.\n잠시후 다시 시도해주세요."
      requestFailed(with: error, reasonWhenNetworkUnstable: message)
    }
  }
  
  @MainActor
  func requestFailed(with error: Error, reasonWhenNetworkUnstable: String?) {
    guard let error = error as? APIError else {
      coordinator?.networkUnstable(reason: reasonWhenNetworkUnstable); return
    }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      default:
        coordinator?.networkUnstable(reason: reasonWhenNetworkUnstable)
    }
  }
}

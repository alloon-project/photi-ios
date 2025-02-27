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
import UseCase

protocol FeedCommentCoordinatable: AnyObject {
  func requestDismiss()
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
  private let likeCountRelay = BehaviorRelay<Int>(value: 0)
  private let isLikeRelay = BehaviorRelay<Bool>(value: false)
  private let feedImageURLRelay = BehaviorRelay<URL?>(value: nil)
  private let commentsRelay = BehaviorRelay<FeedCommentType>(value: .initialPage([]))
  private let stopLoadingAnimation = PublishRelay<Void>()

  // MARK: - Input
  struct Input {
    let didTapBackground: Signal<Void>
    let requestComments: Signal<Void>
    let requestData: Signal<Void>
    let didTapLikeButton: Signal<Bool>
  }
  
  // MARK: - Output
  struct Output {
    let feedImageURL: Driver<URL?>
    let updateTime: Driver<String>
    let author: Driver<AuthorPresentationModel>
    let likeCount: Driver<Int>
    let isLike: Driver<Bool>
    let comments: Driver<FeedCommentType>
    let stopLoadingAnimation: Signal<Void>
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
    input.didTapBackground
      .emit(with: self) { owner, _ in
        owner.coordinator?.requestDismiss()
      }
      .disposed(by: disposeBag)
    
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.fetchFeed() }
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
    input.didTapLikeButton
      .debounce(.milliseconds(500))
      .emit(with: self) { owner, isLike in
        owner.updateLikeState(isLike: isLike)
      }
      .disposed(by: disposeBag)
    
    return Output(
      feedImageURL: feedImageURLRelay.asDriver(),
      updateTime: updateTimeRelay.asDriver(),
      author: authorRelay.asDriver(),
      likeCount: likeCountRelay.asDriver(),
      isLike: isLikeRelay.asDriver(),
      comments: commentsRelay.asDriver(),
      stopLoadingAnimation: stopLoadingAnimation.asSignal()
    )
  }
}

// MARK: - Fetch Method
private extension FeedCommentViewModel {
  func fetchFeed() async {
    do {
      let result = try await useCase.fetchFeed(challengeId: challengeId, feedId: feedId)
      let updateTime = modelMapper.mapToUpdateTimeString(result.updateTime)
      let author = modelMapper.mapToAuthorPresentaionModel(author: result.author, url: result.authorImageURL)
      
      feedImageURLRelay.accept(result.imageURL)
      authorRelay.accept(author)
      updateTimeRelay.accept(updateTime)
      likeCountRelay.accept(result.likeCount)
      isLikeRelay.accept(result.isLike)
    } catch {
      // TODO: 에러 구현 예정
      print(error)
    }
  }
}

// MARK: - Update Methods
private extension FeedCommentViewModel {
  func updateLikeState(isLike: Bool) {
    Task {
      guard isLikeRelay.value != isLike else { return }
      let count = likeCountRelay.value
      let adder = isLike ? 1 : -1
      likeCountRelay.accept(count + adder)
      isLikeRelay.accept(isLike)
      
      await useCase.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    }
  }
  
  func fetchFeedComments() async {
    guard !isFetching else { return stopLoadingAnimation.accept(()) }
    isFetching = true
    defer {
      isFetching = false
      currentPage += 1
    }
    do {
      let result = try await useCase.fetchFeedComments(
        feedId: feedId,
        page: currentPage,
        size: 10
      )
      
      switch result {
        case let .default(comments):
          let models = modelMapper.mapToFeedCommentPresentationModels(comments)
          let page: FeedCommentType = currentPage == 0 ? .initialPage(models) : .default(models)
          commentsRelay.accept(page)
        case let .lastPage(comments):
          let models = modelMapper.mapToFeedCommentPresentationModels(comments)
          let page: FeedCommentType = currentPage == 0 ? .initialPage(models) : .default(models)
          isLastPage = true
          commentsRelay.accept(page)
      }
    } catch {
      stopLoadingAnimation.accept(())
      print(error) // login이동
    }
  }
}

//
//  FeedDetailViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Combine
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
  private var cancellables = Set<AnyCancellable>()
  private let useCase: FeedUseCase
  private let challengeName: String
  private let challengeId: Int
  private let feedId: Int

  private var isFetching: Bool = false
  private var isLastPage: Bool = false
  private var currentPage: Int = 0

  private let authorSubject = CurrentValueSubject<AuthorPresentationModel, Never>(.default)
  private let updateTimeSubject = CurrentValueSubject<String, Never>("")
  private let dropDownOptionsSubject = CurrentValueSubject<[String], Never>([])
  private let likeCountSubject = CurrentValueSubject<Int, Never>(0)
  private let isLikeSubject = CurrentValueSubject<Bool, Never>(false)
  private let feedImageURLSubject = CurrentValueSubject<URL?, Never>(nil)
  private let commentsSubject = CurrentValueSubject<FeedCommentType, Never>(.initialPage([]))
  private let stopLoadingAnimationSubject = PassthroughSubject<Void, Never>()
  private let deleteCommentSubject = PassthroughSubject<Int, Never>()
  private let commentSubject = PassthroughSubject<FeedCommentPresentationModel, Never>()
  private let uploadCommentSuccessSubject = PassthroughSubject<(String, Int), Never>()
  private let uploadCommentFailedSubject = PassthroughSubject<String, Never>()
  private let instagramStoryInformationSubject: CurrentValueSubject<(URL?, String), Never> = .init((nil, ""))

  // MARK: - Input
  struct Input {
    let didTapBackground: AnyPublisher<Void, Never>
    let requestComments: AnyPublisher<Void, Never>
    let requestData: AnyPublisher<Void, Never>
    let didTapLikeButton: AnyPublisher<Bool, Never>
    let didTapDeleteButton: AnyPublisher<Void, Never>
    let didTapReportButton: AnyPublisher<Void, Never>
    let requestDeleteComment: AnyPublisher<Int, Never>
    let requestUploadComment: AnyPublisher<String, Never>
  }

  // MARK: - Output
  struct Output {
    let feedImageURL: AnyPublisher<URL?, Never>
    let instagramStoryInformation: AnyPublisher<(URL?, String), Never>
    let updateTime: AnyPublisher<String, Never>
    let isEditable: AnyPublisher<Bool, Never>
    let author: AnyPublisher<AuthorPresentationModel, Never>
    let likeCount: AnyPublisher<Int, Never>
    let isLike: AnyPublisher<Bool, Never>
    let comments: AnyPublisher<FeedCommentType, Never>
    let dropDownOptions: AnyPublisher<[String], Never>
    let stopLoadingAnimation: AnyPublisher<Void, Never>
    let deleteComment: AnyPublisher<Int, Never>
    let comment: AnyPublisher<FeedCommentPresentationModel, Never>
    let uploadCommentSuccess: AnyPublisher<(String, Int), Never>
    let uploadCommentFailed: AnyPublisher<String, Never>
  }

  // MARK: - Initializers
  init(
    useCase: FeedUseCase,
    challengeName: String,
    challengeId: Int,
    feedID: Int
  ) {
    self.useCase = useCase
    self.challengeName = challengeName
    self.challengeId = challengeId
    self.feedId = feedID
  }

  func transform(input: Input) -> Output {
    bindRequest(input: input)

    input.didTapBackground
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.requestDismiss()
      }
      .store(in: &cancellables)

    input.didTapLikeButton
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      .sinkOnMain(with: self) { owner, isLike in
        Task { await owner.updateLikeState(isLike: isLike) }
      }
      .store(in: &cancellables)

    input.didTapReportButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.requestReport(id: owner.feedId)
      }
      .store(in: &cancellables)

    let isEditable = authorSubject.map { $0.name == ServiceConfiguration.shared.userName }

    return Output(
      feedImageURL: feedImageURLSubject.eraseToAnyPublisher(),
      instagramStoryInformation: instagramStoryInformationSubject.eraseToAnyPublisher(),
      updateTime: updateTimeSubject.eraseToAnyPublisher(),
      isEditable: isEditable.eraseToAnyPublisher(),
      author: authorSubject.eraseToAnyPublisher(),
      likeCount: likeCountSubject.eraseToAnyPublisher(),
      isLike: isLikeSubject.eraseToAnyPublisher(),
      comments: commentsSubject.eraseToAnyPublisher(),
      dropDownOptions: dropDownOptionsSubject.eraseToAnyPublisher(),
      stopLoadingAnimation: stopLoadingAnimationSubject.eraseToAnyPublisher(),
      deleteComment: deleteCommentSubject.eraseToAnyPublisher(),
      comment: commentSubject.eraseToAnyPublisher(),
      uploadCommentSuccess: uploadCommentSuccessSubject.eraseToAnyPublisher(),
      uploadCommentFailed: uploadCommentFailedSubject.eraseToAnyPublisher()
    )
  }

  func bindRequest(input: Input) {
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchData() }
      }
      .store(in: &cancellables)

    input.requestComments
      .sinkOnMain(with: self) { owner, _ in
        guard !owner.isLastPage else { return owner.stopLoadingAnimationSubject.send(()) }
        Task {
          await owner.fetchFeedComments()
          owner.stopLoadingAnimationSubject.send(())
        }
      }
      .store(in: &cancellables)

    input.requestUploadComment
      .sinkOnMain(with: self) { owner, comment in
        let model = owner.modelMapper.feedCommentPresentationModel(comment)
        owner.commentSubject.send(model)
        Task { await owner.uploadComment(modelId: model.id, comment: comment) }
      }
      .store(in: &cancellables)

    input.requestDeleteComment
      .sinkOnMain(with: self) { owner, id in
        Task { await owner.deleteFeedComment(commentId: id) }
      }
      .store(in: &cancellables)

    input.didTapDeleteButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.deleteFeed() }
      }
      .store(in: &cancellables)
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
    dropDownOptionsSubject.send(options)

    feedImageURLSubject.send(result.imageURL)
    authorSubject.send(author)
    updateTimeSubject.send(updateTime)
    likeCountSubject.send(result.likeCount)
    isLikeSubject.send(result.isLike)
    instagramStoryInformationSubject.send((result.imageURL, challengeName))
  }

  func fetchFeedComments() async {
    do {
      try await fetchFeedCommentsWithThrowing()
    } catch {
      await requestFailed(with: error, reasonWhenNetworkUnstable: nil)
    }
  }

  func fetchFeedCommentsWithThrowing() async throws {
    guard !isFetching else { return stopLoadingAnimationSubject.send(()) }
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
        commentsSubject.send(page)
      case let .lastPage(comments):
        let models = modelMapper.mapToFeedCommentPresentationModels(comments)
        let page: FeedCommentType = currentPage == 0 ? .initialPage(models) : .default(models)
        isLastPage = true
        commentsSubject.send(page)
    }
  }
}

// MARK: - Private Methods
private extension FeedCommentViewModel {
  @MainActor
  func updateLikeState(isLike: Bool) async {
    guard isLikeSubject.value != isLike else { return }
    let count = likeCountSubject.value
    let adder = isLike ? 1 : -1
    likeCountSubject.send(count + adder)
    isLikeSubject.send(isLike)

    do {
      try await useCase.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
      coordinator?.updateLikeState(feedId: feedId, isLiked: isLike)
    } catch { }
  }

  @MainActor
  func uploadComment(modelId: String, comment: String) async {
    do {
      let commentId = try await useCase.uploadFeedComment(challengeId: challengeId, feedId: feedId, comment: comment)
      uploadCommentSuccessSubject.send((modelId, commentId))
    } catch {
      let message = "코멘트 등록에 실패했어요.\n잠시후 다시 시도해주세요."
      uploadCommentFailedSubject.send(modelId)
      requestFailed(with: error, reasonWhenNetworkUnstable: message)
    }
  }

  @MainActor
  func deleteFeedComment(commentId: Int) async {
    do {
      try await useCase.deleteFeedComment(challengeId: challengeId, feedId: feedId, commentId: commentId)
      deleteCommentSubject.send(commentId)
    } catch {
      let message = "코멘트 삭제에 실패했어요.\n잠시후 다시 시도해주세요."
      requestFailed(with: error, reasonWhenNetworkUnstable: message)
    }
  }

  @MainActor
  func deleteFeed() async {
    do {
      try await useCase.deleteFeed(challengeId: challengeId, feedId: feedId)
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

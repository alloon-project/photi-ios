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
  
  private let authorRelay = BehaviorRelay<AuthorPresentationModel>(value: .default)
  private let updateTimeRelay = BehaviorRelay<String>(value: "")
  private let likeCountRelay = BehaviorRelay<Int>(value: 0)
  private let isLikeRelay = BehaviorRelay<Bool>(value: false)
  private let feedImageURLRelay = BehaviorRelay<URL?>(value: nil)

  // MARK: - Input
  struct Input {
    let didTapBackground: Signal<Void>
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let feedImageURL: Driver<URL?>
    let updateTime: Driver<String>
    let author: Driver<AuthorPresentationModel>
    let likeCount: Driver<Int>
    let isLike: Driver<Bool>
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
    
    return Output(
      feedImageURL: feedImageURLRelay.asDriver(),
      updateTime: updateTimeRelay.asDriver(),
      author: authorRelay.asDriver(),
      likeCount: likeCountRelay.asDriver(),
      isLike: isLikeRelay.asDriver()
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

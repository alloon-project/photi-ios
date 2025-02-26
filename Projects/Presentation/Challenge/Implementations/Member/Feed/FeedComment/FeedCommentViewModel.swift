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

  // MARK: - Input
  struct Input {
    var didTapBackground: Signal<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
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
    
    return Output()
  }
}

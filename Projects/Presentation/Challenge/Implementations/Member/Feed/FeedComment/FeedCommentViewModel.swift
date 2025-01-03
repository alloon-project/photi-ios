//
//  FeedDetailViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift

protocol FeedCommentCoordinatable: AnyObject { }

protocol FeedCommentViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedCommentCoordinatable? { get set }
}

final class FeedCommentViewModel: FeedCommentViewModelType {
  weak var coordinator: FeedCommentCoordinatable?
  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(feedID: String) { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}

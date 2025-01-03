//
//  FeedViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift

enum FeedAlignMode: String, CaseIterable {
  case recent = "최신순"
  case popular = "인기순"
}

protocol FeedCoordinatable: AnyObject {

protocol FeedViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedCoordinatable? { get set }
}

final class FeedViewModel: FeedViewModelType {
  weak var coordinator: FeedCoordinatable?
  private let disposeBag = DisposeBag()
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}

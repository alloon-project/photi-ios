//
//  ChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol ChallengeHomeCoordinatable: AnyObject { }

protocol ChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeHomeCoordinatable? { get set }
}

final class ChallengeHomeViewModel: ChallengeHomeViewModelType {
  weak var coordinator: ChallengeHomeCoordinatable?
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

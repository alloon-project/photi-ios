//
//  ChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import UseCase

protocol ChallengeHomeCoordinatable: AnyObject { }

protocol ChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeHomeCoordinatable? { get set }
}

final class ChallengeHomeViewModel: ChallengeHomeViewModelType {
  weak var coordinator: ChallengeHomeCoordinatable?
  private let disposeBag = DisposeBag()
  private let useCase: HomeUseCase

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(useCase: HomeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}

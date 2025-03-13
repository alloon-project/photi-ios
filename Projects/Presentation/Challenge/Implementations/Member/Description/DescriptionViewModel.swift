//
//  DescriptionViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import UseCase

protocol DescriptionCoordinatable: AnyObject { }

protocol DescriptionViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: DescriptionCoordinatable? { get set }
}

final class DescriptionViewModel: DescriptionViewModelType {
  weak var coordinator: DescriptionCoordinatable?
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
    self.descriptionObservable = description.compactMap { $0 }
  }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}

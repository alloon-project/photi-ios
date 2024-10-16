//
//  NoneChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol NoneChallengeHomeCoordinatable: AnyObject { }

protocol NoneChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: NoneChallengeHomeCoordinatable? { get set }
}

final class NoneChallengeHomeViewModel: NoneChallengeHomeViewModelType, NoneChallengeHomeViewModelable {
  private let useCase: HomeUseCase
  let disposeBag = DisposeBag()
  
  weak var coordinator: NoneChallengeHomeCoordinatable?
  
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

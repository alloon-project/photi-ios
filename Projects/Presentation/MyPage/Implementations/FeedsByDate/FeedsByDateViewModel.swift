//
//  FeedsByDateViewModel.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import UseCase

protocol FeedsByDateCoordinatable: AnyObject {
  func didTapBackButton()
}

protocol FeedsByDateViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedsByDateCoordinatable? { get set }
}

final class FeedsByDateViewModel: FeedsByDateViewModelType {
  weak var coordinator: FeedsByDateCoordinatable?
  private let disposeBag = DisposeBag()
  private let useCase: MyPageUseCase
  let date: Date

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(date: Date, useCase: MyPageUseCase) {
    self.date = date
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
  }
}
  }
}

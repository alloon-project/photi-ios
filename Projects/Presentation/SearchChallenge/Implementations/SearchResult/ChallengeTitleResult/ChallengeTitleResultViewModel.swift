//
//  ChallengeTitleResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol ChallengeTitleResultCoordinatable: AnyObject { }

protocol ChallengeTitleResultViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeTitleResultCoordinatable? { get set }
}

final class ChallengeTitleResultViewModel: ChallengeTitleResultViewModelType {
  weak var coordinator: ChallengeTitleResultCoordinatable?
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

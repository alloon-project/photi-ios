//
//  DescriptionViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol DescriptionCoordinatable: AnyObject { }

protocol DescriptionViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: DescriptionCoordinatable? { get set }
}

final class DescriptionViewModel: DescriptionViewModelType {
  weak var coordinator: DescriptionCoordinatable?
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

//
//  HomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UseCase

protocol HomeCoordinatable: AnyObject { }

protocol HomeViewModelType: AnyObject, HomeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: HomeCoordinatable? { get set }
}

final class HomeViewModel: HomeViewModelType {
  private let useCase: HomeUseCase
  let disposeBag = DisposeBag()
  
  weak var coordinator: HomeCoordinatable?
  
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

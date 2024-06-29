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

protocol HomeCoordinatable: AnyObject { }

protocol HomeViewModelType: AnyObject, HomeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: HomeCoordinatable? { get set }
}

final class HomeViewModel: HomeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: HomeCoordinatable?
  
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

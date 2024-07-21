//
//  SearchChallengeViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol SearchChallengeCoordinatable: AnyObject { }

protocol SearchChallengeViewModelType: AnyObject, SearchChallengeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: SearchChallengeCoordinatable? { get set }
}

final class SearchChallengeViewModel: SearchChallengeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: SearchChallengeCoordinatable?
  
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

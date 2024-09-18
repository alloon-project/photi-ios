//
//  NoneMemberHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol NoneMemberHomeCoordinatable: AnyObject { }

protocol NoneMemberHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: NoneMemberHomeCoordinatable? { get set }
}

final class NoneMemberHomeViewModel: NoneMemberHomeViewModelType, NoneMemberHomeViewModelable {
  let disposeBag = DisposeBag()
  
  weak var coordinator: NoneMemberHomeCoordinatable?
  
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

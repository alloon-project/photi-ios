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

protocol NoneMemberHomeCoordinatable: AnyObject {
  func didTapLogInButton()
}

protocol NoneMemberHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: NoneMemberHomeCoordinatable? { get set }
}

final class NoneMemberHomeViewModel: NoneMemberHomeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: NoneMemberHomeCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapLogInButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  @discardableResult
  func transform(input: Input) -> Output {
    input.didTapLogInButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapLogInButton()
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}

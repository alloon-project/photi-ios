//
//  EndedChallengeViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol EndedChallengeCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallengeDetail()
  func detachChallengeDetail()
}

protocol EndedChallengeViewModelType: AnyObject, EndedChallengeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EndedChallengeCoordinatable? { get set }
}

final class EndedChallengeViewModel: EndedChallengeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EndedChallengeCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)

    return Output()
  }
}

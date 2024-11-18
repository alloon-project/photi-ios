//
//  ProofChallengeViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ProofChallengeCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallengeDetail()
  func detachChallengeDetail()
}

protocol ProofChallengeViewModelType: AnyObject, ProofChallengeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ProofChallengeCoordinatable? { get set }
}

final class ProofChallengeViewModel: ProofChallengeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ProofChallengeCoordinatable?
  
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

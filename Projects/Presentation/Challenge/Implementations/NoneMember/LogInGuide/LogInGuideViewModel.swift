//
//  LogInGuideViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/31/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol LogInGuideCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapLogInButton()
}

protocol LogInGuideViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: LogInGuideCoordinatable? { get set }
}

final class LogInGuideViewModel: LogInGuideViewModelType {
  weak var coordinator: LogInGuideCoordinatable?
  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapLogInButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapLogInButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapLogInButton()
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}

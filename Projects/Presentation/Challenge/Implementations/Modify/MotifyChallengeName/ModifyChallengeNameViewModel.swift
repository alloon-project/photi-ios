//
//  ModifyChallengeNameViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 5/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ModifyChallengeNameCoordinatable: AnyObject {
  func didTapBackButtonAtModifyChallengeName()
  func modifiedChallengeName(name: String)
}

protocol ModifyChallengeNameViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ModifyChallengeNameCoordinatable? { get set }
}

final class ModifyChallengeNameViewModel: ModifyChallengeNameViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ModifyChallengeNameCoordinatable?
    
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var modifyChallengeName: ControlProperty<String>
    var didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtModifyChallengeName()
      }
      .disposed(by: disposeBag)
  
    input.didTapNextButton
      .withLatestFrom(input.modifyChallengeName)
      .bind(with: self) { owner, name in
        owner.coordinator?.modifiedChallengeName(name: name)
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}

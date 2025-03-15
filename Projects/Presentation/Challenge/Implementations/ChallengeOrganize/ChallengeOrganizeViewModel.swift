//
//  ChallengeOrganizeViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ChallengeOrganizeCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallengeName()
}

protocol ChallengeOrganizeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeOrganizeCoordinatable? { get set }
}

final class ChallengeOrganizeViewModel: ChallengeOrganizeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChallengeOrganizeCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapOrganizeButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    // 단순 동작 bind
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    
    input.didTapOrganizeButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachChallengeName()
      }.disposed(by: disposeBag)
    
   
    // Output 반환
    return Output()
  }
}

//
//  ChallengeStartViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ChallengeStartCoordinatable: AnyObject {
  func didTapBackButton()
  func didFisishChallengeStart()
}

protocol ChallengeStartViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeStartCoordinatable? { get set }
}

final class ChallengeStartViewModel: ChallengeStartViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChallengeStartCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapStartButton: ControlEvent<Void>
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
    
    
    input.didTapStartButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didFisishChallengeStart()
      }.disposed(by: disposeBag)
    
   
    // Output 반환
    return Output()
  }
}

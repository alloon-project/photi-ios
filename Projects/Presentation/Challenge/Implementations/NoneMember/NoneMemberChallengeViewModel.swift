//
//  NoneMemberChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import RxCocoa

protocol NoneMemberChallengeCoordinatable: AnyObject {
  func didJoinChallenge()
  func didTapBackButton()
}

protocol NoneMemberChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: NoneMemberChallengeCoordinatable? { get set }
}

final class NoneMemberChallengeViewModel: NoneMemberChallengeViewModelType {
  weak var coordinator: NoneMemberChallengeCoordinatable?
  private let disposeBag = DisposeBag()
  
  private let isLockChallengeRelay = BehaviorRelay<Bool>(value: true)
  private let displayUnlockViewRelay = PublishRelay<Void>()
  private let verifyCodeResultRelay = PublishRelay<Bool>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapJoinButton: ControlEvent<Void>
    let invitationCode: Driver<String>
    let didFinishVerify: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isLockChallenge: Driver<Bool>
    let displayUnlockView: Signal<Void>
    let verifyCodeResult: Signal<Bool>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapJoinButton
      .withLatestFrom(isLockChallengeRelay)
      .bind(with: self) { owner, isLock in
        if isLock {
          owner.displayUnlockViewRelay.accept(())
        } else {
          owner.coordinator?.didJoinChallenge()
        }
      }
      .disposed(by: disposeBag)
    
    input.invitationCode
      .drive(with: self) { owner, code in
        owner.requestVerify(invitationCode: code)
      }
      .disposed(by: disposeBag)
    
    return Output(
      isLockChallenge: isLockChallengeRelay.asDriver(),
      displayUnlockView: displayUnlockViewRelay.asSignal(),
      verifyCodeResult: verifyCodeResultRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension NoneMemberChallengeViewModel {
  func requestVerify(invitationCode: String) {
    // TODO: - API 연동 후 수정 예정
    verifyCodeResultRelay.accept(true)
  }
}

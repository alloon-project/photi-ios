//
//  MyPageViewModel.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol MyPageCoordinatable: AnyObject {
  func attachSetting()
  func detachSetting()
  func attachEndedChallenge()
  func detachEndedChallenge()
  func attachProofChallenge()
  func detachProofChallenge()
}

protocol MyPageViewModelType: AnyObject, MyPageViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: MyPageCoordinatable? { get set }
}

final class MyPageViewModel: MyPageViewModelType {
  private let useCase: MyPageUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: MyPageCoordinatable?
  
  private let userChallengeHistoryRelay = PublishRelay<UserChallengeHistory>()
  
  // MARK: - Input
  struct Input {
    let didTapSettingButton: ControlEvent<Void>
    let didTapAuthCountBox: ControlEvent<Void>
    let didTapEndedChallengeBox: ControlEvent<Void>
    let isVisible: Observable<Bool>
  }
  
  // MARK: - Output
  struct Output {
    let userChallengeHistory: Signal<UserChallengeHistory>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapSettingButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.attachSetting()
      }.disposed(by: disposeBag)
    
    input.didTapAuthCountBox
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.attachProofChallenge()
      }.disposed(by: disposeBag)
    
    input.didTapEndedChallengeBox
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.attachEndedChallenge()
      }.disposed(by: disposeBag)
    
    input.isVisible
      .bind(with: self) { onwer, _ in
        onwer.userChallengeHistory()
      }.disposed(by: disposeBag)
    
    return Output(
      userChallengeHistory: userChallengeHistoryRelay.asSignal()
    )
  }
}

// MARK: - Private
private extension MyPageViewModel {
  func userChallengeHistory() {
    useCase.userChallengeHistory()
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { onwer, userChallengeHistory in
          onwer.userChallengeHistoryRelay.accept(userChallengeHistory)
        }
      )
      .disposed(by: disposeBag)
  }
}

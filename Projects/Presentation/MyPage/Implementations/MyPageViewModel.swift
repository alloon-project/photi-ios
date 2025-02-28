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
  func attachFeedHistory(count: Int)
  func detachFeedHistory()
}

protocol MyPageViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: MyPageCoordinatable? { get set }
}

final class MyPageViewModel: MyPageViewModelType {
  private let useCase: MyPageUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: MyPageCoordinatable?
  private let FeedHistoryCount = BehaviorRelay(value: 0)
  private let endedChallengeCount = BehaviorRelay(value: 0)
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
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachSetting()
      }.disposed(by: disposeBag)
    
    input.didTapAuthCountBox
      .withLatestFrom(FeedHistoryCount)
      .filter { $0 > 0 } 
      .bind(with: self) { owner, count in
        owner.coordinator?.attachFeedHistory(count: count)
      }.disposed(by: disposeBag)
    
    input.didTapEndedChallengeBox
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachEndedChallenge()
      }.disposed(by: disposeBag)
    
    input.isVisible
      .bind(with: self) { owner, _ in
        owner.userChallengeHistory()
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
        onSuccess: { owner, userChallengeHistory in
          owner.userChallengeHistoryRelay.accept(userChallengeHistory)
          owner.endedChallengeCount.accept(userChallengeHistory.endedChallengeCnt)
          owner.FeedHistoryCount.accept(userChallengeHistory.feedCnt)
        }
      )
      .disposed(by: disposeBag)
  }
}

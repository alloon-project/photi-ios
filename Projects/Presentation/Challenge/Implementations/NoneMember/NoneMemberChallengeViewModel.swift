//
//  NoneMemberChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import UseCase

protocol NoneMemberChallengeCoordinatable: AnyObject {
  func didJoinChallenge(challengeName: String, challengeID: Int)
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

  private let challengeId: Int
  private let useCase: ChallengeUseCase

  private var challengeName = ""
  
  private let isLockChallengeRelay = BehaviorRelay<Bool>(value: true)
  private let displayUnlockViewRelay = PublishRelay<Void>()
  private let verifyCodeResultRelay = PublishRelay<Bool>()
  private let requestFailedRelay = PublishRelay<Void>()
  private let challengeNotFoundRelay = PublishRelay<Void>()
  
  private let challengeRelay = BehaviorRelay<ChallengeDetail?>(value: nil)
  private let challengeObservable: Observable<ChallengeDetail>

  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
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
    let challengeTitle: Driver<String>
    let hashTags: Driver<[String]>
    let verificationTime: Driver<String>
    let goal: Driver<String>
    let challengeImageURL: Driver<URL?>
    let memberCount: Driver<Int>
    let rules: Driver<[String]>
    let deadLine: Driver<String>
    let memberThumbnailURLs: Driver<[URL]>
    let challengeNotFound: Signal<Void>
    let requestFailed: Signal<Void>
  }

  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
    self.challengeObservable = challengeRelay.compactMap { $0 }
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .emit(with: self) { owner, _ in
        owner.fetchChallenge()
      }
      .disposed(by: disposeBag)
    
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
          owner.coordinator?.didJoinChallenge(challengeName: owner.challengeName, challengeID: owner.challengeId)
        }
      }
      .disposed(by: disposeBag)
    
    input.didFinishVerify
      .emit(with: self) { owner, _ in
        owner.coordinator?.didJoinChallenge(challengeName: owner.challengeName, challengeID: owner.challengeId)
      }
      .disposed(by: disposeBag)
    
    input.invitationCode
      .drive(with: self) { owner, code in
        owner.requestVerify(invitationCode: code)
      }
      .disposed(by: disposeBag)
    
    let verificatoinTimeObservable = challengeObservable.map { $0.proveTime.toString("HH : mm") }
    let deadLineObservable = challengeObservable.map { $0.endDate.toString("yyyy.MM.dd") }
    
    return Output(
      isLockChallenge: isLockChallengeRelay.asDriver(),
      displayUnlockView: displayUnlockViewRelay.asSignal(),
      verifyCodeResult: verifyCodeResultRelay.asSignal(),
      challengeTitle: challengeObservable.map(\.name).asDriver(onErrorJustReturn: ""),
      hashTags: challengeObservable.map(\.hashTags).asDriver(onErrorJustReturn: []),
      verificationTime: verificatoinTimeObservable.asDriver(onErrorJustReturn: ""),
      goal: challengeObservable.map(\.goal).asDriver(onErrorJustReturn: ""),
      challengeImageURL: challengeObservable.map(\.imageUrl).asDriver(onErrorJustReturn: nil),
      memberCount: challengeObservable.map(\.memberCount).asDriver(onErrorJustReturn: 0),
      rules: challengeObservable.compactMap(\.rules).asDriver(onErrorJustReturn: []),
      deadLine: deadLineObservable.asDriver(onErrorJustReturn: ""),
      memberThumbnailURLs: challengeObservable.map(\.memberImages).asDriver(onErrorJustReturn: []),
      challengeNotFound: challengeNotFoundRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension NoneMemberChallengeViewModel {
  func fetchChallenge() {
    useCase.fetchChallengeDetail(id: challengeId)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, challenge in
          owner.challengeRelay.accept(challenge)
        },
        onFailure: { owner, error in
          owner.fetchChallengeFailed(with: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func fetchChallengeFailed(with error: Error) {
    guard let error = error as? APIError else { return }
    
    switch error {
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        challengeNotFoundRelay.accept(())
      default:
        requestFailedRelay.accept(())
    }
  }
  
  func requestVerify(invitationCode: String) {
    // TODO: - API 연동 후 수정 예정
    verifyCodeResultRelay.accept(true)
  }
}

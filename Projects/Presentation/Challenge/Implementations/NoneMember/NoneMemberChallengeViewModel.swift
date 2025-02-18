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
  func attachEnterChallengeGoal(challengeName: String, challengeID: Int)
  func didTapBackButton()
  func attachLogInGuide()
}

protocol NoneMemberChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: NoneMemberChallengeCoordinatable? { get set }
}

final class NoneMemberChallengeViewModel: NoneMemberChallengeViewModelType, @unchecked Sendable {
  weak var coordinator: NoneMemberChallengeCoordinatable?
  private let disposeBag = DisposeBag()

  let challengeId: Int
  private let useCase: ChallengeUseCase

  private var challengeName = ""
  private var isPrivateChallenge: Bool = true
  
  private let displayUnlockViewRelay = PublishRelay<Void>()
  private let verifyCodeResultRelay = PublishRelay<Bool>()
  private let requestFailedRelay = PublishRelay<Void>()
  private let challengeNotFoundRelay = PublishRelay<Void>()
  private let alreadyJoinedRelay = PublishRelay<Void>()
  
  private let challengeRelay = BehaviorRelay<ChallengeDetail?>(value: nil)
  private let challengeObservable: Observable<ChallengeDetail>

  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: ControlEvent<Void>
    let didTapJoinButton: ControlEvent<Void>
    let requestVerifyInvitationCode: Signal<String>
    let didFinishVerify: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isPrivateChallenge: Driver<Bool>
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
    let alreadyJoined: Signal<Void>
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
      .bind(with: self) { owner, _ in
        owner.didTapJoinButton()
      }
      .disposed(by: disposeBag)
    
    input.didFinishVerify
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachEnterChallengeGoal(challengeName: owner.challengeName, challengeID: owner.challengeId)
      }
      .disposed(by: disposeBag)
    
    input.requestVerifyInvitationCode
      .emit(with: self) { owner, code in
        Task { await owner.requestVerify(invitationCode: code) }
      }
      .disposed(by: disposeBag)
    
    let verificatoinTimeObservable = challengeObservable.map { $0.proveTime.toString("HH : mm") }
    let deadLineObservable = challengeObservable.map { $0.endDate.toString("yyyy.MM.dd") }
    
    return Output(
      isPrivateChallenge: challengeObservable.map { !($0.isPublic ?? false) }.asDriver(onErrorJustReturn: false),
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
      requestFailed: requestFailedRelay.asSignal(),
      alreadyJoined: alreadyJoinedRelay.asSignal()
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
          owner.challengeName = challenge.name
          owner.isPrivateChallenge = !(challenge.isPublic ?? false)
          owner.challengeRelay.accept(challenge)
        },
        onFailure: { owner, error in
          owner.fetchChallengeFailed(with: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func didTapJoinButton() {
    Task {
      let isLogin = await useCase.isLogIn()
      
      DispatchQueue.main.async { [weak self] in
        if isLogin {
          self?.joinChallenge()
        } else {
          self?.coordinator?.attachLogInGuide()
        }
      }
    }
  }
  
  func joinChallenge() {
    if isPrivateChallenge {
      displayUnlockViewRelay.accept(())
    } else {
      coordinator?.attachEnterChallengeGoal(
        challengeName: challengeName, challengeID: challengeId
      )
    }
  }
  
  func requestVerify(invitationCode: String) async {
    do {
      try await useCase.joinPrivateChallnege(id: challengeId, code: invitationCode)
      verifyCodeResultRelay.accept(true)
    } catch {
      requestJoinChallengeFailed(with: error)
    }
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
  
  func requestJoinChallengeFailed(with error: Error) {
    guard let error = error as? APIError else { return }
    
    switch error {
      case let .challengeFailed(reason) where reason == .invalidInvitationCode:
        verifyCodeResultRelay.accept(false)
      case let .challengeFailed(reason) where reason == .alreadyJoinedChallenge:
        alreadyJoinedRelay.accept(())
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        coordinator?.attachLogInGuide()
      case .authenticationFailed:
        coordinator?.attachLogInGuide()
      default:
        requestFailedRelay.accept(())
    }
  }
}

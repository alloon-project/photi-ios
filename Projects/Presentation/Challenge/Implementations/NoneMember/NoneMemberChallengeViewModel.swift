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
  func requestDetach()
}

protocol NoneMemberChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: NoneMemberChallengeCoordinatable? { get set }
}

final class NoneMemberChallengeViewModel: NoneMemberChallengeViewModelType, @unchecked Sendable {
  weak var coordinator: NoneMemberChallengeCoordinatable?
  private let disposeBag = DisposeBag()

  private let challengeId: Int
  private let useCase: ChallengeUseCase

  private var challengeName = ""
  private var isPrivateChallenge: Bool = true
  
  private let displayUnlockViewRelay = PublishRelay<Void>()
  private let verifyCodeResultRelay = PublishRelay<Bool>()
  private let networkUnstableRelay = PublishRelay<Void>()
  private let challengeNotFoundRelay = PublishRelay<Void>()
  
  private let challengeRelay = BehaviorRelay<ChallengeDetail?>(value: nil)
  private let challengeObservable: Observable<ChallengeDetail>

  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: ControlEvent<Void>
    let didTapJoinButton: ControlEvent<Void>
    let requestVerifyInvitationCode: Signal<String>
    let didFinishVerify: Signal<Void>
    let didTapConfirmButtonAtChallengeNotFound: Signal<Void>
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
    let networkUnstable: Signal<Void>
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
        Task { await owner.fetchChallenge() }
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapJoinButton
      .bind(with: self) { owner, _ in
        Task { await owner.attemptToJoinChallenge() }
      }
      .disposed(by: disposeBag)
    
    input.didFinishVerify
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachEnterChallengeGoal(challengeName: owner.challengeName, challengeID: owner.challengeId)
      }
      .disposed(by: disposeBag)
    
    input.requestVerifyInvitationCode
      .emit(with: self) { owner, code in
        Task { await owner.verifyInvitationCode(code) }
      }
      .disposed(by: disposeBag)
    
    input.didTapConfirmButtonAtChallengeNotFound
      .emit(with: self) { owner, _ in
        owner.coordinator?.requestDetach()
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
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension NoneMemberChallengeViewModel {
  @MainActor func attemptToJoinChallenge() async {
    do {
      let isLogin = try await useCase.isLogIn()
       
      decideJoinFlowBasedOnLogIn(isLogin: isLogin)
    } catch {
      networkUnstableRelay.accept(())
    }
  }
  
  func decideJoinFlowBasedOnLogIn(isLogin: Bool) {
    isLogin ? routeBasedOnChallengePrivacy() : coordinator?.attachLogInGuide()
  }
  
  func routeBasedOnChallengePrivacy() {
    isPrivateChallenge ?
    displayUnlockViewRelay.accept(()) :
    coordinator?.attachEnterChallengeGoal(challengeName: challengeName, challengeID: challengeId)
  }
}

// MARK: - API Methods
private extension NoneMemberChallengeViewModel {
  @MainActor func fetchChallenge() async {
    do {
      let challenge = try await useCase.fetchChallengeDetail(id: challengeId).value
      challengeName = challenge.name
      isPrivateChallenge = !(challenge.isPublic ?? false)
      challengeRelay.accept(challenge)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func verifyInvitationCode(_ code: String) async {
    do {
      let isMatch = try await useCase.verifyInvitationCode(id: challengeId, code: code)
      verifyCodeResultRelay.accept(isMatch)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    switch error {
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        challengeNotFoundRelay.accept(())
      case .authenticationFailed:
        coordinator?.attachLogInGuide()
      default:
        networkUnstableRelay.accept(())
    }
  }
}

//
//  NoneMemberChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine
import CoreUI
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
  private var cancellables = Set<AnyCancellable>()

  private let challengeId: Int
  private let useCase: ChallengeUseCase

  private var challengeName = ""
  private var isPrivateChallenge: Bool = true

  private let displayUnlockViewSubject = PassthroughSubject<Void, Never>()
  private let verifyCodeResultSubject = PassthroughSubject<Bool, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let challengeNotFoundSubject = PassthroughSubject<Void, Never>()
  private let exceededJoinableChallengeLimitSubject = PassthroughSubject<Void, Never>()

  private let challengeSubject = CurrentValueSubject<ChallengeDetail?, Never>(nil)

  // MARK: - Input
  struct Input {
    let viewDidLoad: AnyPublisher<Void, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapJoinButton: AnyPublisher<Void, Never>
    let requestVerifyInvitationCode: AnyPublisher<String, Never>
    let didFinishVerify: AnyPublisher<Void, Never>
    let didTapConfirmButtonAtChallengeNotFound: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let isPrivateChallenge: AnyPublisher<Bool, Never>
    let displayUnlockView: AnyPublisher<Void, Never>
    let verifyCodeResult: AnyPublisher<Bool, Never>
    let challengeTitle: AnyPublisher<String, Never>
    let hashTags: AnyPublisher<[String], Never>
    let verificationTime: AnyPublisher<String, Never>
    let goal: AnyPublisher<String, Never>
    let challengeImageURL: AnyPublisher<URL?, Never>
    let memberCount: AnyPublisher<Int, Never>
    let rules: AnyPublisher<[String], Never>
    let deadLine: AnyPublisher<String, Never>
    let memberThumbnailURLs: AnyPublisher<[URL], Never>
    let challengeNotFound: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let exceededJoinableChallengeLimit: AnyPublisher<Void, Never>
  }

  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.viewDidLoad
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchChallenge() }
      }
      .store(in: &cancellables)

    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)

    input.didTapJoinButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.attemptToJoinChallenge() }
      }
      .store(in: &cancellables)

    input.didFinishVerify
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.attachEnterChallengeGoal(challengeName: owner.challengeName, challengeID: owner.challengeId)
      }
      .store(in: &cancellables)

    input.requestVerifyInvitationCode
      .sinkOnMain(with: self) { owner, code in
        Task { await owner.verifyInvitationCode(code) }
      }
      .store(in: &cancellables)

    input.didTapConfirmButtonAtChallengeNotFound
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.requestDetach()
      }
      .store(in: &cancellables)

    let challengePublisher = challengeSubject.compactMap { $0 }.eraseToAnyPublisher()
    let verificationTimePublisher = challengePublisher.map { $0.proveTime.toString("HH : mm") }.eraseToAnyPublisher()
    let deadLinePublisher = challengePublisher.map { $0.endDate.toString("yyyy.MM.dd") }.eraseToAnyPublisher()

    return Output(
      isPrivateChallenge: challengePublisher.map { !($0.isPublic ?? false) }.eraseToAnyPublisher(),
      displayUnlockView: displayUnlockViewSubject.eraseToAnyPublisher(),
      verifyCodeResult: verifyCodeResultSubject.eraseToAnyPublisher(),
      challengeTitle: challengePublisher.map(\.name).eraseToAnyPublisher(),
      hashTags: challengePublisher.map(\.hashTags).eraseToAnyPublisher(),
      verificationTime: verificationTimePublisher,
      goal: challengePublisher.map(\.goal).eraseToAnyPublisher(),
      challengeImageURL: challengePublisher.map(\.imageUrl).eraseToAnyPublisher(),
      memberCount: challengePublisher.map(\.memberCount).eraseToAnyPublisher(),
      rules: challengePublisher.compactMap(\.rules).eraseToAnyPublisher(),
      deadLine: deadLinePublisher,
      memberThumbnailURLs: challengePublisher.map(\.memberImages).eraseToAnyPublisher(),
      challengeNotFound: challengeNotFoundSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      exceededJoinableChallengeLimit: exceededJoinableChallengeLimitSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Internal Methods
extension NoneMemberChallengeViewModel {
  @MainActor func isJoinedChallenge() async -> Bool {
    return await useCase.isJoinedChallenge(id: challengeId)
  }
}

// MARK: - Private Methods
private extension NoneMemberChallengeViewModel {
  @MainActor func attemptToJoinChallenge() async {
    do {
      let isLogin = try await useCase.isLogIn()
      let isPossibleToJoin = await useCase.isPossibleToJoinChallenge()

      isPossibleToJoin ? decideJoinFlowBasedOnLogIn(isLogin: isLogin) : exceededJoinableChallengeLimitSubject.send(())
    } catch {
      networkUnstableSubject.send(())
    }
  }

  func decideJoinFlowBasedOnLogIn(isLogin: Bool) {
    isLogin ? routeBasedOnChallengePrivacy() : coordinator?.attachLogInGuide()
  }

  func routeBasedOnChallengePrivacy() {
    isPrivateChallenge ?
    displayUnlockViewSubject.send(()) :
    coordinator?.attachEnterChallengeGoal(challengeName: challengeName, challengeID: challengeId)
  }
}

// MARK: - API Methods
private extension NoneMemberChallengeViewModel {
  @MainActor func fetchChallenge() async {
    do {
      let challenge = try await useCase.fetchChallengeDetail(id: challengeId)
      challengeName = challenge.name
      isPrivateChallenge = !(challenge.isPublic ?? false)
      challengeSubject.send(challenge)
    } catch {
      requestFailed(with: error)
    }
  }

  func verifyInvitationCode(_ code: String) async {
    do {
      let isMatch = try await useCase.verifyInvitationCode(id: challengeId, code: code)
      verifyCodeResultSubject.send(isMatch)
    } catch {
      requestFailed(with: error)
    }
  }

  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableSubject.send(()) }
    switch error {
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        challengeNotFoundSubject.send(())
      case .authenticationFailed:
        coordinator?.attachLogInGuide()
      default:
        networkUnstableSubject.send(())
    }
  }
}

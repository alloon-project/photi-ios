//
//  OAuthSignUpCoordinator.swift
//  LogInImpl
//
//  Created on 2026/03/02.
//

import Coordinator

protocol OAuthSignUpListener: AnyObject {
  func didFinishOAuthSignUp(userName: String)
  func didTapBackButtonAtOAuthSignUp()
}

final class OAuthSignUpCoordinator: Coordinator {
  weak var listener: OAuthSignUpListener?

  private let navigationControllerable: NavigationControllerable

  private let enterIdContainable: EnterIdContainable
  private var enterIdCoordinator: Coordinating?

  private let agreementContainable: AgreementContainable
  private var agreementCoordinator: Coordinating?

  init(
    navigationControllerable: NavigationControllerable,
    enterIdContainable: EnterIdContainable,
    agreementContainable: AgreementContainable
  ) {
    self.navigationControllerable = navigationControllerable
    self.enterIdContainable = enterIdContainable
    self.agreementContainable = agreementContainable
    super.init()
  }

  override func start() {
    navigationControllerable.navigationController.navigationBar.isHidden = true
    Task { await attachEnterId() }
  }

  override func stop() {
    Task {
      await detachAgreement()
      await detachEnterId()
    }
  }
}

// MARK: - EnterId
@MainActor extension OAuthSignUpCoordinator {
  func attachEnterId() {
    guard enterIdCoordinator == nil else { return }

    let coordinater = enterIdContainable.coordinator(listener: self)
    addChild(coordinater)
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.enterIdCoordinator = coordinater
  }

  func detachEnterId() {
    guard let coordinater = enterIdCoordinator else { return }

    removeChild(coordinater)
    navigationControllerable.popViewController(animated: true)
    self.enterIdCoordinator = nil
  }
}

// MARK: - Agreement
@MainActor extension OAuthSignUpCoordinator {
  func attachAgreement() {
    guard agreementCoordinator == nil else { return }

    let coordinater = agreementContainable.coordinator(listener: self, password: "")
    addChild(coordinater)
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: false)
    self.agreementCoordinator = coordinater
  }

  func detachAgreement() {
    guard let coordinater = agreementCoordinator else { return }

    removeChild(coordinater)
    navigationControllerable.popViewController(animated: false)
    self.agreementCoordinator = nil
  }
}

// MARK: - EnterIdListener
extension OAuthSignUpCoordinator: EnterIdListener {
  func didTapBackButtonAtEnterId() {
    Task { await detachEnterId() }
    listener?.didTapBackButtonAtOAuthSignUp()
  }

  func didFinishEnterId() {
    Task { await attachAgreement() }
  }
}

// MARK: - AgreementListener
extension OAuthSignUpCoordinator: AgreementListener {
  func didTapBackButtonAtAgreement() {
    Task { await detachAgreement() }
  }

  func didFinishAgreement(userName: String) {
    listener?.didFinishOAuthSignUp(userName: userName)
  }
}

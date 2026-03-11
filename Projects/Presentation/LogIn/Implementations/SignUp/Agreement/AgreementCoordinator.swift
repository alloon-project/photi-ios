//
//  AgreementCoordinator.swift
//  LogInImpl
//
//  Created by Codex on 3/2/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Coordinator

protocol AgreementListener: AnyObject {
  func didTapBackButtonAtAgreement()
  func didFinishAgreement(userName: String)
}

protocol AgreementPresentable { }

final class AgreementCoordinator: ViewableCoordinator<AgreementPresentable> {
  weak var listener: AgreementListener?
  
  private let viewModel: AgreementViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: AgreementViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension AgreementCoordinator: AgreementCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtAgreement()
  }
  
  func didFinishAgreement(userName: String) {
    listener?.didFinishAgreement(userName: userName)
  }
}

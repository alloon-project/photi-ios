//
//  InquiryCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol InquiryViewModelable { }

public protocol InquiryListener: AnyObject {
  func didTapBackButtonAtInquiry()
}

final class InquiryCoordinator: Coordinator {
  weak var listener: InquiryListener?
  private let viewController: InquiryViewController
  private let viewModel: any InquiryViewModelType
  
  init(viewModel: InquiryViewModel) {
    self.viewModel = viewModel
    
    self.viewController = InquiryViewController(viewModel: viewModel)
    
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Coordinatable
extension InquiryCoordinator: InquiryCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtInquiry()
  }
}

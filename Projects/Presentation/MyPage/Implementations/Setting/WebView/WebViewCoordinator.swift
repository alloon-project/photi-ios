//
//  WebViewCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 7/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol WebViewListener: AnyObject {}

protocol WebViewPresentable {
  func setUrl(_ url: String)
}

final class WebViewCoordinator: ViewableCoordinator<WebViewPresentable> {
  weak var listener: WebViewListener?
  private let url: String
  
  private let viewModel: WebViewViewModel
    
  init(
    viewControllerable: ViewControllerable,
    viewModel: WebViewViewModel,
    url: String
  ) {
    self.viewModel = viewModel
    self.url = url
        
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.setUrl(url)
  }
}

// MARK: - Coordinatable
extension WebViewCoordinator: WebViewCoordinatable {}

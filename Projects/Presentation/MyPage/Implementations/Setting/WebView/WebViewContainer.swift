//
//  WebViewContainer.swift
//  Presentation
//
//  Created by 임우섭 on 7/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol WebViewDependency: Dependency {}

protocol WebViewContainable: Containable {
  func coordinator(
    listener: WebViewListener,
    url: String
  ) -> ViewableCoordinating
}

final class WebViewContainer:
  Container<WebViewDependency>,
  WebViewContainable,
  WebViewDependency {
  func coordinator(
    listener: WebViewListener,
    url: String
  ) -> ViewableCoordinating {
    let viewModel = WebViewViewModel()
    let viewControllerable = WebViewController(viewModel: viewModel)
    
    let coordinator = WebViewCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      url: url
    )
    coordinator.listener = listener
    
    return coordinator
  }
}

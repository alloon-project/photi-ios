//
//  InquiryContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol InquiryDependency: Dependency { }

public protocol InquiryContainable: Containable {
  func coordinator(listener: InquiryListener) -> Coordinating
}

public final class InquiryContainer: Container<InquiryDependency>, InquiryContainable {
  public func coordinator(listener: InquiryListener) -> Coordinating {
    let viewModel = InquiryViewModel()
    let coordinator = InquiryCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}

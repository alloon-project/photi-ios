//
//  ReportContainer.swift
//  LogInImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Report
import UseCase

public protocol ReportDependency: Dependency {
  var reportUseCase: ReportUseCase { get }
  var inquiryUseCase: InquiryUseCase { get }
}

public final class ReportContainer: Container<ReportDependency>, ReportContainable {
  public func coordinator(listener: ReportListener, reportType: ReportType) -> ViewableCoordinating {
    let viewModel = ReportViewModel(
      reportUseCase: dependency.reportUseCase,
      inquiryUseCase: dependency.inquiryUseCase,
      reportType: reportType
    )
    let viewControllerable = ReportViewController(viewModel: viewModel)
    
    let coordinator = ReportCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    
    coordinator.listener = listener
    return coordinator
  }
}

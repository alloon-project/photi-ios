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
  public func coordinator(listener: ReportListener, reportType: ReportType) -> Coordinating {
    let viewModel = ReportViewModel(
      reportUseCase: dependency.reportUseCase,
      inquiryUseCase: dependency.inquiryUseCase
    )
    let coordinator = ReportCoordinator(viewModel: viewModel, reportType: reportType)
    coordinator.listener = listener
    return coordinator
  }
}

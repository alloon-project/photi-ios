//
//  ReportCoordinator.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import Report

protocol ReportViewModelable { }

final class ReportCoordinator: Coordinator, ReportCoordinatable {
  weak var listener: ReportListener?
    private let viewController: ReportViewController
  private let viewModel: any ReportViewModelType
  
  init(viewModel: ReportViewModel, reportType: ReportType) {
    self.viewModel = viewModel
    self.viewController = ReportViewController(viewModel: viewModel, reportType: reportType)
    
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

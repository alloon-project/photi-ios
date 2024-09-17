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

final class ReportCoordinator: Coordinator {
  weak var listener: ReportListener?
  
  private let viewController: ReportViewController
  private let viewModel: any ReportViewModelType
  
  init(viewModel: ReportViewModel, reportData: ReportDataSource) {
    self.viewModel = viewModel
    self.viewController = ReportViewController(viewModel: viewModel, reportData: reportData)
    
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}

extension ReportCoordinator: ReportCoordinatable {
  func didTapBackButtonAtReport() {
    listener?.detachReport()
  }
}

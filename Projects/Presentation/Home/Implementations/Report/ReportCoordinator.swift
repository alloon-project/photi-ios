//
//  ReportCoordinator.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol ReportViewModelable {
  // Coordinator에서 ViewModel로 전달할 이벤트입니다.
}

protocol ReportListener: AnyObject {

}

final class ReportCoordinator: Coordinator, ReportCoordinatable {
  weak var listener: ReportListener?
  private let reportType: ReportType
  
  private let viewController: ReportViewController
  private let viewModel: any ReportViewModelType
  
  init(viewModel: ReportViewModel, reportType: ReportType) {
    self.viewModel = viewModel
    self.reportType = reportType
    self.viewController = ReportViewController(viewModel: viewModel)
    
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    viewController.setReportType(type: reportType)
    navigationController?.pushViewController(viewController, animated: false)
  }
  
}

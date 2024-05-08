//
//  LoggedOutViewController.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import DesignSystem

final class LoggedOutViewController: UIViewController {
  private let navigations = PrimaryNavigationView(
    textType: .center,
    iconType: .two,
    titleText: "테스트"
  )
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .orange
    self.view.addSubview(navigations)
    navigations.snp.makeConstraints {
      $0.top.equalToSuperview().offset(50)
      $0.height.equalTo(56)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    
  }
  
  private func closeAction() {
    print("닫기")
    if let nav = self.navigationController {
      nav.popViewController(animated: true)
    } else {
      self.dismiss(animated: true)
    }
  }
}

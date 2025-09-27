//
//  WebViewController.swift
//  Core
//
//  Created by 임우섭 on 7/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import SnapKit

public final class WebViewController: UIViewController {
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private var url: URL?
  // MARK: - UI Components
  private let webView = WKWebView()
  
  // MARK: - Initializers
  public init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View LifeCycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupWebView()
  }
}

// MARK: - UI Methods
private extension WebViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubview(self.webView)
  }
  
  func setConstraints() {
    webView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalToSuperview().offset(56)
    }
  }
}

// MARK: - Private Methods
private extension WebViewController {
  func setupWebView() {
    guard let url = self.url else { return }
    let urlRequest = URLRequest(url: url)
    self.webView.load(urlRequest)
  }
}

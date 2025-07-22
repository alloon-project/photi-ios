//
//  WebViewController.swift
//  Presentation
//
//  Created by 임우섭 on 7/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import SnapKit
import Core

final class WebViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private let viewModel: WebViewViewModel
  private var url: URL?
  // MARK: - UI Components
  private let webView = WKWebView()
  
  // MARK: - Initializers
  init(viewModel: WebViewViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
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

// MARK: - Bind Methods
private extension WebViewController {
  func bind() {
    let input = WebViewViewModel.Input()
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {}
  
  func bind(for output: WebViewViewModel.Output) {}
}

// MARK: - WebViewPresentable
extension WebViewController: WebViewPresentable {
  func setUrl(_ urlString: String) {
    self.url = URL(string: urlString)
  }
}

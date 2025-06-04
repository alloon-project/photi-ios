//
//  SettingViewController.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class SettingViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private let viewModel: SettingViewModel
  private var settingMenuItems = [SettingMenuItem]() {
    didSet { menuTableView.reloadData() }
  }
  
  private let requestData = PublishRelay<Void>()
  private let didTapSettingMenu = PublishRelay<SettingMenuItem>()

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "설정", displayMode: .dark)
  
  private let menuTableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(SettingTableViewCell.self)
    tableView.rowHeight = 56
    tableView.separatorInset = .zero
    tableView.separatorColor = .gray200
    tableView.isScrollEnabled = false
    
    return tableView
  }()
  
  // MARK: - Initializers
  init(viewModel: SettingViewModel) {
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
    
    menuTableView.delegate = self
    menuTableView.dataSource = self
    setupUI()
    bind()
    
    requestData.accept(())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - UI Methods
private extension SettingViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, menuTableView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    menuTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(20)
    }
  }
}

// MARK: - Bind Methods
private extension SettingViewController {
  func bind() {
    let input = SettingViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton.asSignal(),
      requestData: requestData.asSignal(),
      didTapSettingMenu: didTapSettingMenu.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: SettingViewModel.Output) {
    output.settingMenuItems
      .drive(rx.settingMenuItems)
      .disposed(by: disposeBag)
  }
}

// MARK: - SettingPresentable
extension SettingViewController: SettingPresentable { }

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingMenuItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(SettingTableViewCell.self, for: indexPath)
    cell.configure(with: settingMenuItems[indexPath.row])
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = settingMenuItems[indexPath.row]
    didTapSettingMenu.accept(item)
  }
}

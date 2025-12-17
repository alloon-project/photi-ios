//
//  RuleDetailViewController.swift
//  HomeImpl
//
//  Created by jung on 1/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import CoreUI
import DesignSystem

final class RuleDetailViewController: UIViewController {
  enum Constants {
    static let mainContentViewHeight: CGFloat = 456
  }
  
  // MARK: - Properties
  private var rules = [String]() {
    didSet { ruleTableView.reloadData() }
  }
  
  // MARK: - UI Components
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    layer.compositingFilter = "multiplyBlendMode"
    
    return layer
  }()
  
  private let mainContentView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 12
    view.backgroundColor = .green0
    
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "규칙".attributedString(
      font: .body1Bold,
      color: .green500
    )
    return label
  }()
  
  private let closeButton: UIButton = {
    let button = UIButton()
    button.setImage(.closeGreen, for: .normal)
    
    return button
  }()
  
  private let ruleTableView: UITableView = {
    let tableView = UITableView()
    tableView.registerCell(RuleDetailCell.self)
    tableView.rowHeight = 61
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.sectionHeaderTopPadding = 0
    
    return tableView
  }()
  
  // MARK: - Initialziers
  init(rules: [String]) {
    self.rules = rules
    super.init(nibName: nil, bundle: nil  )
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    ruleTableView.dataSource = self
    ruleTableView.delegate = self
    setupUI()
    configureCloseButtonAction()
  }
  
  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    dimmedLayer.frame = view.bounds
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentWithAnimation()
  }
}

// MARK: - UI Methods
private extension RuleDetailViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.layer.addSublayer(dimmedLayer)
    view.addSubview(mainContentView)
    mainContentView.addSubviews(titleLabel, closeButton, ruleTableView)
  }
  
  func setConstraints() {
    mainContentView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalToSuperview().offset(-1000)
      $0.height.equalTo(Constants.mainContentViewHeight)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalTo(closeButton.snp.leading).inset(24)
    }
    
    closeButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(24)
      $0.height.width.equalTo(20)
      $0.centerY.equalTo(titleLabel)
    }

    ruleTableView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(23)
      $0.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(titleLabel.snp.bottom).offset(22)
      $0.bottom.equalToSuperview().inset(34)
    }
  }
}

// MARK: - UITableViewDataSource
extension RuleDetailViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return rules.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(RuleDetailCell.self, for: indexPath)
    cell.configure(rule: rules[indexPath.section])
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension RuleDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : 12
  }
}

// MARK: - Private Methods
private extension RuleDetailViewController {
  func configureCloseButtonAction() {
    closeButton.addAction(
      .init { [weak self] _ in
        self?.dismissWithAnimation()
      },
      for: .touchUpInside
    )
  }
  
  func presentWithAnimation() {
    mainContentView.frame.origin.y = view.frame.height
    UIView.animate(withDuration: 0.4) {
      self.mainContentView.center.y = self.view.center.y
      self.mainContentView.layoutIfNeeded()
    }
  }
  
  func dismissWithAnimation() {
    UIView.animate(withDuration: 0.4) {
      self.mainContentView.frame.origin.y = self.view.frame.height
      self.mainContentView.layoutIfNeeded()
    } completion: { _ in
      self.dismiss(animated: false)
    }
  }
}

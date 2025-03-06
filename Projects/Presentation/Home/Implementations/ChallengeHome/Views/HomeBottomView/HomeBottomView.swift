//
//  HomeBottomView.swift
//  HomeImpl
//
//  Created by jung on 10/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import DesignSystem

final class HomeBottomView: UIView {
  var dataSources = [MyChallengePresentationModel]() {
    didSet { tableView.reloadData() }
  }
  
  // MARK: - UI Components
  private let seperatorView: UIImageView = {
    let imageView = UIImageView(image: .pinkingGrayUp)
    imageView.contentMode = .topLeft
    return imageView
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "내 챌린지".attributedString(font: .heading4, color: .photiBlack)
    
    return label
  }()
  
  private let tableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(HomeMyChallengeCell.self)
    tableView.rowHeight = 214
    tableView.isScrollEnabled = false
    tableView.backgroundColor = .clear
    
    return tableView
  }()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension HomeBottomView {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(seperatorView, containerView)
    containerView.addSubviews(titleLabel, tableView)
  }
  
  func setConstraints() {
    seperatorView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(seperatorView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalToSuperview().offset(32)
    }
    
    tableView.snp.makeConstraints {
      $0.width.equalTo(330)
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(40)
    }
  }
}

// MARK: - UITableViewDataSource
extension HomeBottomView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSources.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(HomeMyChallengeCell.self, for: indexPath)
    cell.configure(with: dataSources[indexPath.section])
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension HomeBottomView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section + 1 == dataSources.count else { return nil }
    let view = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 16))
    
    return view
  }
}

//
//  ParticipantViewController.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ParticipantViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: ParticipantViewModel
  private let disposeBag = DisposeBag()
  private var dataSource = [ParticipantPresentationModel]() {
    didSet {
      participantTableView.reloadData()
      configureCountLabel(count: dataSource.count)
    }
  }
  
  // MARK: - UI Components
  private let participantCountLabel = UILabel()
  private let participantTableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.registerCell(ParticipantCell.self)
    tableView.rowHeight = 150
    tableView.showsVerticalScrollIndicator = false
    
    return tableView
  }()
  
  // MARK: - Initializers
  init(viewModel: ParticipantViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    participantTableView.dataSource = self
    setupUI()
  }
}

// MARK: - UI Methods
private extension ParticipantViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(participantCountLabel, participantTableView)
  }
  
  func setConstraints() {
    participantCountLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalToSuperview().offset(32)
    }

    participantTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
      $0.top.equalTo(participantCountLabel.snp.bottom).offset(16)
    }
  }
}

// MARK: - Bind Methods
private extension ParticipantViewController {
  func bind() {
    let input = ParticipantViewModel.Input()
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: ParticipantViewModel.Output) { }
}

// MARK: - ParticipantPresentable
extension ParticipantViewController: ParticipantPresentable { }

// MARK: - UITableViewDataSource
extension ParticipantViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(ParticipantCell.self, for: indexPath)
    cell.configure(with: dataSource[indexPath.row])
    return cell
  }
}

// MARK: - UITableViewDelegate
extension ParticipantViewController: UITableViewDelegate { }

// MARK: - Private Methods
private extension ParticipantViewController {
  func configureCountLabel(count: Int) {
    participantCountLabel.attributedText = "파티원 \(count)명".attributedString(
      font: .body1Bold,
      color: .init(red: 0.27, green: 0.27, blue: 0.27, alpha: 1)
    )
  }
}

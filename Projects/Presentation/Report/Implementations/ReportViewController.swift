//
//  ReportViewController.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem
import Report

final class ReportViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: ReportViewModel
  private var reportType: ReportType = .challenge
  private var selectedRow: Int?
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .none, iconType: .one)
  
  private let reasonLabel = UILabel() 
  private let reasonTableView = {
    let tableView = SelfSizingTableView(maxHeight: 284)
    tableView.registerCell(ReportReasonTableViewCell.self)
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 32
    
    return tableView
  }()
  
  private let detailLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "자세한 내용을 적어주시면 신고에 도움이 돼요".attributedString(font: .heading4, color: .gray900)

    return label
  }()
  
  private let detailContentTextView = LineTextView(placeholder: "신고 내용을 상세히 알려주세요", type: .count(120), mode: .default)
  
  private let reportButton = FilledRoundButton(type: .primary, size: .xLarge, text: "신고하기")
  
  // MARK: - Initializers
  init(viewModel: ReportViewModel) {
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
    
    reasonTableView.delegate = self
    reasonTableView.dataSource = self
    setupUI()
    bind()
  }
  
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ReportViewController {
  func setupUI() {
    self.view.backgroundColor = .white

    switch reportType {
    case .challenge:
      reasonLabel.attributedText = "미션을 신고하는 이유가 무엇인가요?".attributedString(font: .heading4, color: .gray900)
    case .feed:
      reasonLabel.attributedText = "피드를 신고하는 이유가 무엇인가요?".attributedString(font: .heading4, color: .gray900)
    case .member:
      reasonLabel.attributedText = "멤버를 신고하는 이유가 무엇인가요?".attributedString(font: .heading4, color: .gray900)
    }
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(navigationBar, reasonLabel, reasonTableView, detailLabel, detailContentTextView, reportButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    reasonLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
    }
    
    reasonTableView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(reasonLabel.snp.bottom).offset(20)
    }
    
    detailLabel.snp.makeConstraints {
      $0.leading.trailing.equalTo(reasonTableView)
      $0.top.equalTo(reasonTableView.snp.bottom).offset(32)
    }
    
    detailContentTextView.snp.makeConstraints {
      $0.leading.trailing.equalTo(detailLabel)
      $0.top.equalTo(detailLabel.snp.bottom).offset(24)
    }
    
    reportButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension ReportViewController {
  func bind() {
    let input = ReportViewModel.Input()
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: ReportViewModel.Output) { }
}

// MARK: - Internal Methods
extension ReportViewController {
  func setReportType(type: ReportType) {
    self.reportType = type
  }
}

// MARK: - UITableView DataSource, Delegate
extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return reportType.contents.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    32
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(ReportReasonTableViewCell.self, for: indexPath)
    
    let isSelected = indexPath.row == selectedRow
    cell.configure(with: reportType.contents[indexPath.section], isSelected: isSelected)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRow = indexPath.row
    selectRow(at: indexPath)
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == reportType.contents.count - 1 {
      return 0
    } else {
      return 10
    }
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
    view.backgroundColor = .clear
    
    return view
  }
}

// MARK: - Private Methods
private extension ReportViewController {
  func deselectAllCell() {
    self.reasonTableView.visibleCells.forEach { $0.isSelected = false }
  }
  
  func selectRow(at indexPath: IndexPath) {
    deselectAllCell()
    self.reasonTableView.cellForRow(ReportReasonTableViewCell.self, at: indexPath).isSelected = true
  }
}

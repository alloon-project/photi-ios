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

final class ReportViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ReportViewModel
  // MARK: - Properties
  private var selectedIndexPath: IndexPath?
  private let selectedRowRelay = PublishRelay<String>()
  private var isDisplayDetailContent = false
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let reasonLabel = UILabel()
  private let reasonTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(ReportReasonTableViewCell.self)
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 32
    
    return tableView
  }()
  
  private let detailLabel = UILabel()
  private let detailContentTextView: LineTextView = LineTextView(type: .count(120))
  private let reportButton = FilledRoundButton(type: .primary, size: .xLarge)
  
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
    addKeyboardObservers()
    setupUI()
    bind()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    removeKeyboardObservers()
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
    
    setViewHierarchy()
    setConstraints()
    setReportType()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      navigationBar,
      reasonLabel,
      reasonTableView,
      reportButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    reasonLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
    }
    
    reasonTableView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(reasonLabel.snp.bottom).offset(20)
    }
    
    reportButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
  
  func setReportType() {
    reasonLabel.attributedText = viewModel.reportType.title.attributedString(font: .heading4, color: .gray900)
    detailLabel.attributedText = viewModel.reportType.textViewTitle.attributedString(font: .heading4, color: .gray900)
    detailContentTextView.placeholder = viewModel.reportType.textViewPlaceholder
    reportButton.setText(viewModel.reportType.buttonTitle)
  }
  
  func setupDetailContentUI() {
    guard !isDisplayDetailContent else { return }
    isDisplayDetailContent = true
    
    self.view.addSubviews(detailLabel, detailContentTextView)
    
    detailLabel.snp.makeConstraints {
      $0.leading.trailing.equalTo(reasonTableView)
      $0.top.equalTo(reasonTableView.snp.bottom).offset(32)
    }
    
    detailContentTextView.snp.makeConstraints {
      $0.leading.trailing.equalTo(detailLabel)
      $0.top.equalTo(detailLabel.snp.bottom).offset(24)
    }
  }
}

// MARK: - Bind Methods
private extension ReportViewController {
  func bind() {
    let input = ReportViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapReportButton: reportButton.rx.tap,
      reasonAndType: selectedRowRelay.asObservable(),
      content: detailContentTextView.rx.text
    )
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: ReportViewModel.Output) {
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.displayAlertPopUp()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension ReportViewController {
  func displayAlertPopUp() {
    let alertVC = AlertViewController(alertType: .confirm, title: "오류", subTitle: "잠시 후에 다시 시도해주세요.")
    alertVC.present(to: self, animted: false)
  }
}

// MARK: - ReportPresentable
extension ReportViewController: ReportPresentable { }

// MARK: - UITableView DataSource, Delegate
extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.reportType.contents.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    32
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(ReportReasonTableViewCell.self, for: indexPath)
    let isSelected = indexPath == selectedIndexPath
    cell.configure(with: viewModel.reportType.contents[indexPath.row], isSelected: isSelected)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard selectedIndexPath != indexPath else { return }

      let previousIndexPath = selectedIndexPath
      selectedIndexPath = indexPath
      selectedRowRelay.accept(viewModel.reportType.reason[indexPath.row])

      setupDetailContentUI()

      var indexPathsToReload = [indexPath]
      if let previous = previousIndexPath {
          indexPathsToReload.append(previous)
      }
      
      tableView.reloadRows(at: indexPathsToReload, with: .none)
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == viewModel.reportType.contents.count - 1 {
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
private extension ReportViewController {}

// MARK: - Setup Keyboard Observer
private extension ReportViewController {
  func addKeyboardObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  func removeKeyboardObservers() {
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  @objc func keyboardWillShow(_ notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
    else { return }
    
    let keyboardHeight = keyboardFrame.cgRectValue.height
    let viewHeight = self.view.frame.height
    
    let insetFromKeyboardTop: CGFloat = 40
    let textViewBottom = self.detailContentTextView.frame.maxY
    
    let bottomPadding = viewHeight - (textViewBottom + insetFromKeyboardTop)
    let totalPadding = keyboardHeight - bottomPadding
    
    if view.frame.origin.y == 0 {
      view.frame.origin.y += totalPadding
    }
  }
  
  @objc func keyboardWillHide(_ sender: Notification) {
    if view.frame.origin.y != 0 {
      view.frame.origin.y = 0
    }
  }
}

//
//  ListBottomSheetViewController.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

public protocol ListBottomSheetDelegate: AnyObject {
  func didTapIcon(at index: Int)
  func didTapButton(_ bottomSheet: ListBottomSheetViewController)
}

public final class ListBottomSheetViewController: BottomSheetViewController {
  private let disposeBag = DisposeBag()
  
  public weak var delegate: ListBottomSheetDelegate?
  
  /// List의 Title을 정의합니다.
  public var titleText: String {
    didSet {
      self.setTitleLabel(titleText)
    }
  }
  
  /// Button의 text를 정의합니다.
  public var buttonText: String {
    didSet {
      button.setText(buttonText, for: .normal)
    }
  }
  
  /// 보여질 List의 Text입니다.
  public var dataSource: [String] {
    didSet {
      tableView.reloadData()
    }
  }
  
  // MARK: - UI Components
  private let contentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    stackView.alignment = .fill
    stackView.distribution = .fillProportionally
    
    return stackView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    
    return label
  }()
  
  private let tableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView()
    tableView.separatorStyle = .none
    tableView.registerCell(ListBottomSheetCell.self)
    tableView.estimatedRowHeight = 24
    
    return tableView
  }()
  
  private let button = FilledRoundButton(type: .primary, size: .xLarge, text: "확인")
  
  // MARK: - Initializers
  public init(
    title: String = "",
    button: String = "확인",
    dataSource: [String] = []
  ) {
    self.titleText = title
    self.buttonText = button
    self.dataSource = dataSource
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    
    setupUI()
    bind()
  }
}

// MARK: - UI Methods
private extension ListBottomSheetViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    setTitleLabel(titleText)
    button.setText(buttonText, for: .normal)
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(titleLabel, tableView, button)
  }
  
  func setConstraints() {
    contentView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-18)
      $0.bottom.equalToSuperview().offset(-56)
      $0.top.equalToSuperview().offset(40)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(40)
      $0.leading.trailing.equalToSuperview()
    }
    
    let buttonSize = button.intrinsicContentSize
    
    button.snp.makeConstraints {
      $0.top.equalTo(tableView.snp.bottom).offset(40)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.size.equalTo(buttonSize)
    }
  }
}

// MARK: - Bind Methods
private extension ListBottomSheetViewController {
  func bind() {
    button.rx.tap
      .bind(with: self) { owner, _ in
        owner.delegate?.didTapButton(owner)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension ListBottomSheetViewController {
  func setTitleLabel(_ text: String) {
    titleLabel.attributedText = text.attributedString(
      font: .heading3,
      color: .gray900
    )
  }
}

// MARK: - UITableViewDatasource
extension ListBottomSheetViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(ListBottomSheetCell.self, for: indexPath)
    cell.configure(with: dataSource[indexPath.section])
    
    cell.rx.didTapIcon
      .bind(with: self) { owner, _ in
        owner.delegate?.didTapIcon(at: indexPath.section)
      }
      .disposed(by: disposeBag)
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension ListBottomSheetViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == dataSource.count - 1 {
      return 0
    } else {
      return 22
    }
  }
  
  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
    view.backgroundColor = .clear
    
    return view
  }
}

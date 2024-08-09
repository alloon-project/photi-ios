//
//  AlignBottomSheetViewController.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Core

public protocol AlignBottomSheetDelegate: AnyObject {
  func didSeleted(at index: Int)
}

public final class AlignBottomSheetViewController: BottomSheetViewController {
  public enum AlignType {
    case `default`
    case button(text: String)
  }
  
  private lazy var disposeBag = DisposeBag()
  
  private let type: AlignType
  public weak var delegate: AlignBottomSheetDelegate?
  
  public var dataSource: [String] {
    didSet {
      tableView.reloadData()
    }
  }
  
  public var selectedRow: Int {
    didSet {
      let indexPath = IndexPath(row: 0, section: selectedRow)
      self.selectRow(at: indexPath)
    }
  }
  
  // MARK: - UI Components
  private let tableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView(maxHeight: 300)
    tableView.registerCell(AlignCell.self)
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 44
    
    return tableView
  }()
  
  private lazy var button = FilledRoundButton(type: .quaternary, size: .xLarge)
  
  // MARK: - Initializers
  public init(
    type: AlignType,
    selectedRow: Int,
    dataSource: [String] = []
  ) {
    self.type = type
    self.dataSource = dataSource
    self.selectedRow = selectedRow
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    
    setupUI()
    
    if case .button = type {
      bind()
    }
  }
}

// MARK: - UI Methods
private extension AlignBottomSheetViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    if case let .button(title) = type {
      button.setText(title, for: .normal)
    }
  }
  
  func setViewHierarchy() {
    contentView.addSubview(tableView)
    
    if case .button = type {
      contentView.addSubview(button)
    }
  }
  
  func setConstraints() {
    contentView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    switch type {
      case .default:
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
      case .button:
        tableView.snp.makeConstraints {
          $0.leading.trailing.top.equalToSuperview()
        }
        let size = button.intrinsicContentSize
        button.snp.makeConstraints {
          $0.centerX.bottom.equalToSuperview()
          $0.top.equalTo(tableView.snp.bottom)
          $0.size.equalTo(size)
        }
    }
  }
}

// MARK: - Bind
private extension AlignBottomSheetViewController {
  func bind() {
    button.rx.tap
      .bind(with: self) { owner, _ in
        owner.delegate?.didSeleted(at: owner.selectedRow)
        owner.dismissBottomSheet()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDataSource
extension AlignBottomSheetViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(AlignCell.self, for: indexPath)
    let isSelected = indexPath.section == selectedRow

    cell.configure(with: dataSource[indexPath.section], isSelected: isSelected)
    cell.backgroundColor = .clear
    return cell
  }
}

// MARK: - UITableViewDelegate
extension AlignBottomSheetViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard self.selectedRow != indexPath.section else { return }
    
    selectedRow = indexPath.section
    
    switch type {
      case .default:
        delegate?.didSeleted(at: selectedRow)
        dismissBottomSheet()
      default: break
    }
  }
}

// MARK: - Private Methods
private extension AlignBottomSheetViewController {
  func deselectAllCell() {
    self.tableView.visibleCells.forEach { $0.isSelected = false }
  }
  
  func selectRow(at indexPath: IndexPath) {
    deselectAllCell()
    self.tableView.cellForRow(AlignCell.self, at: indexPath).isSelected = true
  }
}

//
//  AlignBottomSheetViewController.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

public protocol AlignBottomSheetDelegate: AnyObject {
  func didSeleted(at index: Int)
}

public final class AlignBottomSheetViewController: BottomSheetViewController {
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
  
  // MARK: - Initializers
  public init(selectedRow: Int, dataSource: [String] = []) {
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
  }
}

// MARK: - UI Methods
private extension AlignBottomSheetViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(tableView)
  }
  
  func setConstraints() { 
    contentView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().offset(-62)
    }
    
    tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
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
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == dataSource.count - 1 {
      return 0
    } else {
      return 16
    }
  }
  
  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
    view.backgroundColor = .clear
    
    return view
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard self.selectedRow != indexPath.section else { return }
    
    selectedRow = indexPath.section
    delegate?.didSeleted(at: selectedRow)
    dismissBottomSheet()
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
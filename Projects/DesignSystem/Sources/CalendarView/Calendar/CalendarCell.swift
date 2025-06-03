//
//  CalendarCell.swift
//  DesignSystem
//
//  Created by jung on 5/13/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxRelay
import SnapKit
import Core

/// 특정한 달의 달력을 표시하는 Cell입니다.
final class CalendarCell: UICollectionViewCell {
  private var selectionMode: CalendarView.SelectionMode = .single
  private var itemHeight: CGFloat = 0
  private var itemSpacing: CGFloat = 0
  private var lineSpacing: CGFloat = 0

  private var dataSource: [CalendarDate] = [] {
    didSet {
      calendarCollectionView.reloadData()
    }
  }
  
  var selectedDates: [CalendarDate]?
  var selectedDateRelay = PublishRelay<CalendarDate>()
  
  // MARK: - UI Components
  private let calendarCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.registerCell(DayCell.self)
    collectionView.isScrollEnabled = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    calendarCollectionView.dataSource = self
    calendarCollectionView.delegate = self
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - Configure Method
  func configure(
    _ dataSource: [CalendarDate],
    selectionMode: CalendarView.SelectionMode,
    itemHeight: CGFloat,
    itemSpacing: CGFloat,
    lineSpacing: CGFloat
  ) {
    self.selectionMode = selectionMode
    self.itemHeight = itemHeight
    self.itemSpacing = itemSpacing
    self.lineSpacing = lineSpacing
    
    calendarCollectionView.collectionViewLayout = collectionViewLayout()
    
    self.dataSource = dataSource
  }
}

// MARK: - UI Methods
private extension CalendarCell {
  func setupUI () {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(calendarCollectionView)
  }
  
  func setConstraints() {
    calendarCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}

// MARK: - UICollectionViewDataSource
extension CalendarCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(DayCell.self, for: indexPath)
    let date = dataSource[indexPath.row]
    let isSelected = (selectedDates ?? []).contains(date)
    
    cell.configure(
      dateType: date.type,
      day: date.day,
      allowedSelection: selectionMode == .single,
      isSelected: isSelected
    )

    return cell
  }
}

// MARK: - UICollecionViewDelegate
extension CalendarCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedDateRelay.accept(dataSource[indexPath.row])
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return false }
    
    return selectionMode == .single ? !cell.isSelected : true
  }
}

// MARK: - Internal Methods
extension CalendarCell {
  func deSelectAllCell() {
    let count = calendarCollectionView.visibleCells.count
    
    for row in (0..<count) {
      let indexPath = IndexPath(row: row, section: 0)
      
      if let cell = calendarCollectionView.cellForItem(at: indexPath) {
        cell.isSelected = false
      }
      calendarCollectionView.deselectItem(at: indexPath, animated: false)
    }
  }
}

// MARK: - Private Methods
private extension CalendarCell {
  func collectionViewLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(itemHeight),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .absolute(itemHeight)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(itemSpacing)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = lineSpacing
    
    return UICollectionViewCompositionalLayout(section: section)
  }
}

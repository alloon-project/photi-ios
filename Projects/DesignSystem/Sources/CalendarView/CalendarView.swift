//
//  CalendarView.swift
//  DesignSystem
//
//  Created by jung on 5/13/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

public protocol CalendarViewDelegate: AnyObject {
  func didSelect(_ date: Date)
  func didTapCloseButton()
}

public final class CalendarView: UIView {
  public enum SelectionMode {
    case single
    case multiple
  }
  
  private let disposeBag = DisposeBag()
  
  public let seletectionMode: SelectionMode
  
  /// Close 버튼 설정
  public var isCloseButtonHidden: Bool = false {
    didSet {
      headerView.closeButton.isHidden = isCloseButtonHidden
    }
  }
  
  /// Day Item의 높이를 정의합니다.
  public var itemHeight: CGFloat = 40 {
    didSet {
      calendarCollectionView.reloadData()
      updateCalendarCollectionView()
    }
  }
  
  /// Day Item간의 spacing을 정의합니다.
  public var itemSpacing: CGFloat = 9 {
    didSet {
      calendarCollectionView.reloadData()
      updateCalendarCollectionView()
    }
  }
  
  /// 요일 간의 spacing을 정의합니다.
  public var lineSpacing: CGFloat = 6 {
    didSet {
      calendarCollectionView.reloadData()
      updateCalendarCollectionView()
    }
  }
  
  /// 달력의 `startDate`를 정의합니다. 해당 날짜를 기준으로 이전 날짜들은 disabled 됩니다.
  public var startDate: Date {
    didSet {
      self.dataSource = dataSource(from: startDate, to: endDate)
      scrollTo(date: currentDate)
    }
  }
  
  /// 달력의 `endDate`를 정의합니다. default는 startDate를 기준으로 5년입니다.
  public var endDate: Date {
    didSet {
      self.dataSource = dataSource(from: startDate, to: endDate)
      scrollTo(date: currentDate)
    }
  }
  
  public var currentDate: Date {
    didSet { scrollTo(date: currentDate) }
  }
  
  /// `default`로 선택된 Date입니다.
  public var defaultSelectedDates: [Date] = [] {
    didSet { calendarCollectionView.reloadData() }
  }
  
  /// 유저가 선택한 날짜입니다.
  public var selectedDate: Date?
  
  private var calendarSize: CGSize {
    return CGSize(
      width: itemHeight * 7 + itemSpacing * 6,
      height: itemHeight * 5 + lineSpacing * 4
    )
  }
  
  private var weekLabelSpacing: CGFloat {
    return itemHeight + itemSpacing - 14
  }
  
  private var dataSource = [[CalendarDate]]() {
    didSet { calendarCollectionView.reloadData() }
  }
  
  private weak var selectedCell: CalendarCell?
  
  public weak var delegate: CalendarViewDelegate?
  
  // MARK: - UI Components
  fileprivate let headerView = CalendarHeaderView()
  private let weekView = WeekView()
  
  private let calendarCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(CalendarCell.self)
    collectionView.collectionViewLayout = layout
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    
    return collectionView
  }()
  
  // MARK: - Initalizers
  public init(
    selectionMode: SelectionMode,
    defaultSelectedDates: [Date],
    startDate: Date,
    currentDate: Date? = nil,
    endDate: Date? = nil
  ) {
    self.seletectionMode = selectionMode
    self.startDate = startDate
    self.currentDate = currentDate ?? startDate
    self.endDate = endDate ?? (Calendar.current.date(byAdding: .year, value: 5, to: startDate) ?? startDate)
    
    self.defaultSelectedDates = defaultSelectedDates
    
    super.init(frame: .zero)
    
    setupUI()
    calendarCollectionView.dataSource = self
    calendarCollectionView.delegate = self
    
    dataSource = dataSource(from: startDate, to: self.endDate)
    scrollTo(date: self.currentDate)
  }
  
  public convenience init(
    selectionMode: SelectionMode,
    startDate: Date,
    currentDate: Date? = nil,
    endDate: Date? = nil
  ) {
    self.init(
      selectionMode: selectionMode,
      defaultSelectedDates: [],
      startDate: startDate,
      currentDate: currentDate,
      endDate: endDate)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension CalendarView {
  func setupUI() {
    let startDate = CalendarDate(date: startDate)
    
    weekView.spacing = weekLabelSpacing
    headerView.text = "\(startDate.year)년 \(startDate.month)월"
    headerView.leftDisabled = true
    
    headerView.leftArrowButton.addTarget(
      self,
      action: #selector(didTapLeftArrowButton),
      for: .touchUpInside
    )
    headerView.rightArrowButton.addTarget(
      self,
      action: #selector(didTapRightArrowButton),
      for: .touchUpInside
    )
    headerView.closeButton.addTarget(
      self,
      action: #selector(didTapCloseButton),
      for: .touchUpInside
    )
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.addSubviews(headerView, weekView, calendarCollectionView)
  }
  
  func setConstraints() {
    headerView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(64)
    }
    
    weekView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
      $0.leading.equalTo(calendarCollectionView).offset(itemHeight/2 - 7)
      $0.height.equalTo(42)
    }
    
    calendarCollectionView.snp.makeConstraints {
      $0.top.equalTo(weekView.snp.bottom)
      $0.size.bottom.equalTo(calendarSize)
      $0.centerX.equalToSuperview()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension CalendarView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(CalendarCell.self, for: indexPath)
    cell.configure(
      dataSource[indexPath.row],
      selectionMode: seletectionMode,
      itemHeight: itemHeight,
      itemSpacing: itemSpacing,
      lineSpacing: lineSpacing
    )
    
    cell.selectedDates = defaultSelectedDates.map { CalendarDate(date: $0) }
    
    cell.selectedDateRelay
      .bind(with: self) { owner, calendarDate in
        owner.selectedDate = calendarDate.date
        owner.delegate?.didSelect(calendarDate.date)
        if let selectedCell = owner.selectedCell, selectedCell !== cell {
          selectedCell.deSelectAllCell()
        }
        owner.selectedCell = cell
      }
      .disposed(by: disposeBag)
    
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarView: UICollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return collectionView.frame.size
  }
}

// MARK: - UIScrollViewDelegate
extension CalendarView {
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    headerView.leftDisabled = page == 0
    headerView.rightDisabled = page == dataSource.count - 1
    if let date = dataSource[page].first {
      setHeaderViewTitle(date)
    }
  }
}

// MARK: - Private Methods
private extension CalendarView {
  @objc func didTapLeftArrowButton() {
    guard let visibleIndexPath = calendarCollectionView.indexPathsForVisibleItems.first else { return }
    let previousItem = visibleIndexPath.item - 1
    guard previousItem >= 0 else { return } // 첫 페이지면 무시
    
    let previousIndexPath = IndexPath(item: previousItem, section: 0)
    calendarCollectionView.scrollToItem(at: previousIndexPath, at: .centeredHorizontally, animated: true)
    
    headerView.leftDisabled = previousItem == 0
    headerView.rightDisabled = previousItem == dataSource.count - 1
    
    if let date = dataSource[previousItem].first {
      setHeaderViewTitle(date)
    }
  }
  
  @objc func didTapRightArrowButton() {
    guard let visibleIndexPath = calendarCollectionView.indexPathsForVisibleItems.first else { return }
    let nextItem = visibleIndexPath.item + 1
    guard nextItem < dataSource.count else { return } // 마지막 페이지이면 무시
    
    let nextIndexPath = IndexPath(item: nextItem, section: 0)
    calendarCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    
    headerView.leftDisabled = nextItem == 0
    headerView.rightDisabled = nextItem == dataSource.count - 1
    
    if let date = dataSource[nextItem].first {
      setHeaderViewTitle(date)
    }
  }
  
  @objc func didTapCloseButton() {
    delegate?.didTapCloseButton()
  }
  
  func updateCalendarCollectionView() {
    calendarCollectionView.snp.updateConstraints {
      $0.size.equalTo(calendarSize)
    }
  }
  
  func setHeaderViewTitle(_ date: CalendarDate) {
    headerView.text = "\(date.year)년 \(date.month)월"
  }
  
  func scrollTo(date: Date) {
    for (pageIndex, dates) in dataSource.enumerated() {
      if let first = dates.first, Calendar.current.isDate(first.date, equalTo: date, toGranularity: .month) {
        let indexPath = IndexPath(item: pageIndex, section: 0)
        calendarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        setHeaderViewTitle(CalendarDate(date: date))
        headerView.leftDisabled = pageIndex == 0
        headerView.rightDisabled = pageIndex == dataSource.count - 1
        
        break
      }
    }
  }
  
  func dataSource(from startDate: Date, to endDate: Date) -> [[CalendarDate]] {
    var dataSource = [[CalendarDate]]()
    
    let startCalendarDate = CalendarDate(date: startDate)
    let endCalendarDate = CalendarDate(date: endDate)
    
    var currentCalendarDate = startCalendarDate
    currentCalendarDate.day = 1
    var lastMonthCalendarDate = startCalendarDate.previousMonth()
    
    while currentCalendarDate.compareYearAndMonth(with: endCalendarDate) {
      var daysOfMonth = [CalendarDate]()
      
      let firstDayOfWeek = currentCalendarDate.startDayOfWeek()
      let totalDays = currentCalendarDate.daysOfMonth()
      let lastMonthTotalDays = lastMonthCalendarDate.daysOfMonth()
      
      // 첫 주의 빈 공간을 저번달로 채웁니다.
      for count in (0..<firstDayOfWeek) {
        var calendarDate = currentCalendarDate
        calendarDate.day = lastMonthTotalDays - firstDayOfWeek + count + 1
        calendarDate.type = .disabled
        
        daysOfMonth.append(calendarDate)
      }
      
      // 이번달을 채웁니다.
      var calendarDate = currentCalendarDate
      calendarDate.day = 1
      for _ in (0..<totalDays) {
        if calendarDate < startCalendarDate {
          calendarDate.type = .disabled
        } else if calendarDate == startCalendarDate {
          calendarDate.type = .startDate
        } else if calendarDate > endCalendarDate {
          calendarDate.type = .disabled
        } else {
          calendarDate.type = .default
        }
        
        daysOfMonth.append(calendarDate)
        
        calendarDate = calendarDate.nextDay()
      }
      
      lastMonthCalendarDate = currentCalendarDate
      currentCalendarDate = currentCalendarDate.nextMonth()
      currentCalendarDate.day = 1
      
      // 마지막 주 빈 공간을 다음달로 채웁니다.
      calendarDate = currentCalendarDate
      calendarDate.type = .disabled
      while daysOfMonth.count < 35 {
        daysOfMonth.append(calendarDate)
        calendarDate = calendarDate.nextDay()
      }
      
      dataSource.append(daysOfMonth)
    }
    
    return dataSource
  }
}

// MARK: - Reactive Extensions
public extension Reactive where Base: CalendarView {
  var didTapCloseButton: ControlEvent<Void> {
    return base.headerView.closeButton.rx.tap
  }
}

//
//  DatePickerBottomSheetViewController.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import SnapKit
import Core

public protocol DatePickerBottomSheetDelegate: AnyObject {
  func didSelect(date: Date)
}

public final class DatePickerBottomSheetViewController: BottomSheetViewController {
  private var cancellables = Set<AnyCancellable>()
  
  public var startDate: Date = .now {
    didSet {
      calendarView.startDate = startDate
      calendarView.endDate = Calendar.current.date(byAdding: .year, value: 5, to: startDate) ?? startDate
    }
  }
  
  public var buttonText: String = "버튼" {
    didSet { button.title = buttonText }
  }
  
  public var selecedDate: Date? {
    didSet {
      calendarView.selectedDate = selecedDate
      selectedDateSubject.send(selecedDate)
    }
  }
  
  private let selectedDateSubject = CurrentValueSubject<Date?, Never>(nil)
  
  public weak var delegate: DatePickerBottomSheetDelegate?
  
  // MARK: - UI Components
  private let calendarView = CalendarView(selectionMode: .single, startDate: .now)
  
  private let button = FilledRoundButton(type: .primary, size: .xLarge)
  
  // MARK: - Initializers
  public init(startDate: Date = .now) {
    self.startDate = startDate
    super.init(nibName: nil, bundle: nil)
  }
  
  public convenience init(selectedDate: Date, startDate: Date) {
    self.init(startDate: startDate)
    self.selecedDate = selectedDate
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.delegate = self
    setupUI()
    bind()
  }
}

// MARK: - UI Methods
private extension DatePickerBottomSheetViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    button.title = buttonText
  }
  
  func setViewHierarchy() {
    self.contentView.addSubviews(calendarView, button)
  }
  
  func setConstraints() {
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(480)
    }

    calendarView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.trailing.equalToSuperview()
    }
    
    button.snp.makeConstraints {
      $0.top.equalTo(calendarView.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind
private extension DatePickerBottomSheetViewController {
  func bind() {
    // mode 바인딩: 선택된 날짜가 없으면 비활성화 모드
    selectedDateSubject
      .map { ($0 == nil) ? ButtonMode.disabled : ButtonMode.default }
      .bind(to: \FilledRoundButton.mode, on: button)
      .store(in: &cancellables)
    
    selectedDateSubject
      .map { $0 != nil }
      .bind(to: \FilledRoundButton.isEnabled, on: button)
      .store(in: &cancellables)
    
    button.tap()
      .sinkOnMain(with: self) { owner, _ in
        if let selecedDate = owner.selecedDate {
          owner.delegate?.didSelect(date: selecedDate)
          owner.dismissBottomSheet()
        }
      }.store(in: &cancellables)
  }
}

// MARK: - CalendarViewDelegate
extension DatePickerBottomSheetViewController: CalendarViewDelegate {
  public func didSelect(_ date: Date) { 
    self.selecedDate = date
  }
  
  public func didTapCloseButton() {
    dismissBottomSheet()
    didDismissSubject.send(())
  }
}

//
//  TimePickerBottomSheet.swift
//  DesignSystem
//
//  Created by jung on 7/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

public protocol TimePickerBottomSheetDelegate: AnyObject {
  func didSelect(hour: Int)
}

public final class TimePickerBottomSheet: BottomSheetViewController {
  private let disposeBag = DisposeBag()
  
  weak var delegate: TimePickerBottomSheetDelegate?
  
  private var dataSource: [Int] = [] {
    didSet { pickerView.reloadAllComponents() }
  }
  
  /// Time Picker에 표기될 minumum 시간을 표기합니다.
  public private(set) var minimumHour: Int
  
  /// Time Picker에 표기될 maximum 시간을 표기합니다.
  public private(set) var maximumHour: Int
  
  /// Timer Picker에서 default로 선택된 시간입니다.
  public private(set) var selectedHour: Int
  
  // MARK: - UI Components
  private let pickerView = TimePickerView()
  private let button = FilledRoundButton(type: .primary, size: .xLarge)
  
  // MARK: - Initializers
  public init(
    minimumHour: Int = 0,
    maximumHour: Int = 24,
    selectedHour: Int? = nil,
    buttonText: String) {
      self.minimumHour = minimumHour
      self.maximumHour = maximumHour
      self.selectedHour = selectedHour ?? minimumHour
      super.init(nibName: nil, bundle: nil)
      button.setText(buttonText, for: .normal)
      setDataSource(minimumHour: minimumHour, maximumHour: maximumHour)
    }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    pickerView.delegate = self
    pickerView.dataSource = self
    
    setupUI()
    bind()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupPickerViewUI()
    
    DispatchQueue.main.async { [weak self] in
      guard 
        let self,
        let row = dataSource.enumerated().first(where: { $0.element == self.selectedHour })
      else { return }
      
      self.pickerView.selectRow(row.offset, inComponent: 0, animated: false)
    }
  }
}

// MARK: - UI Methods
private extension TimePickerBottomSheet {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(pickerView, button)
  }
  
  func setConstraints() {
    contentView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    pickerView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(180)
    }
    
    let size = button.intrinsicContentSize
    
    button.snp.makeConstraints {
      $0.top.equalTo(pickerView.snp.bottom).offset(24)
      $0.bottom.centerX.equalToSuperview()
      $0.size.equalTo(size)
    }
  }
  
  func setupPickerViewUI() {
    let backgroundView = pickerView.subviews[1]
    backgroundView.backgroundColor = .gray100
    backgroundView.layer.cornerRadius = 16

    pickerView.bringSubviewToFront(pickerView.subviews[0])
  }
}

// MARK: - Bind
extension TimePickerBottomSheet {
  func bind() {
    self.button.rx.tap
      .bind(with: self) { owner, _ in
        owner.delegate?.didSelect(hour: owner.selectedHour)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UIPickerViewDelegate
extension TimePickerBottomSheet: UIPickerViewDelegate {
  public func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let hour = dataSource[row]
    let view = TimePickerViewCell(hour: hour, minute: 0)
    
    return view
  }
  
  public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return 60
  }
  
  public func pickerView(
    _ pickerView: UIPickerView,
    didSelectRow row: Int,
    inComponent component: Int
  ) {
    guard let cell = pickerView.view(forRow: row, forComponent: 0) as? TimePickerViewCell else { return }
    self.selectedHour = Int(cell.hourText) ?? 0
  }
}

// MARK: - UIPickerViewDataSource
extension TimePickerBottomSheet: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return dataSource.count
  }
}

// MARK: - Private Methods
private extension TimePickerBottomSheet {
  func setDataSource(minimumHour: Int, maximumHour: Int) {
    guard minimumHour <= maximumHour else { return }
    self.minimumHour = minimumHour
    self.maximumHour = maximumHour
    
    dataSource = [Int](minimumHour...maximumHour)
  }
}

//
//  PhotiSegmentControl.swift
//  DesignSystem
//
//  Created by jung on 12/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

public class PhotiSegmentControl: UIControl {
  // MARK: - Properties
  public var items: [String] {
    didSet { setupSegmentControl(with: items) }
  }
  
  public internal(set) var selectedSegmentIndex: Int = 0
  
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.backgroundColor = .clear
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 0
    
    return stackView
  }()
  
  var segmentButtons = [SegmentButton]() {
    didSet { configureButtons(segmentButtons) }
  }
  
  // MARK: - Initializers
  public init(items: [String]) {
    self.items = items
    super.init(frame: .zero)
    
    setupUI()
  }
  
  convenience init() {
    self.init(items: [])
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
    setupSegmentControl(with: items)
  }
  
  func configureButtons(_ buttons: [SegmentButton]) {
    buttons.forEach { button in
      if button.tag == selectedSegmentIndex { button.isSelected = true }
      
      button.addAction(
        .init { [weak self] _ in
          self?.selectedSegment(at: button.tag)
        },
        for: .touchUpInside
      )
    }
  }
  
  func segmentButton(title: String, tag: Int) -> SegmentButton {
    let button = SegmentButton(title: title)
    button.tag = tag
    
    return button
  }
}

// MARK: - UI Methods
private extension PhotiSegmentControl {
  func setViewHierarchy() {
    addSubview(stackView)
  }
  
  func setConstraints() {
    stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
  
  func setupSegmentControl(with items: [String]) {
    removeAllSegment()
    
    segmentButtons = items.enumerated().map { index, item in
      segmentButton(title: item, tag: index)
    }
    
    stackView.addArrangedSubviews(segmentButtons)
  }
}

// MARK: - Private Methods
private extension PhotiSegmentControl {
  func removeAllSegment() {
    stackView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  func selectedSegment(at index: Int) {
    segmentButtons
      .filter { $0.isSelected }
      .forEach { $0.isSelected = false }
    
    segmentButtons
      .first { $0.tag == index }?.isSelected = true
    
    selectedSegmentIndex = index
    sendActions(for: .valueChanged)
  }
}

public extension Reactive where Base: PhotiSegmentControl {
  var selectedSegment: ControlEvent<Int> {
    let observable = base.rx.controlEvent(.valueChanged)
      .map { _ in return base.selectedSegmentIndex }
      
    return .init(events: observable)
  }
}

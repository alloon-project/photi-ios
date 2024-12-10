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

public final class PhotiSegmentControl: UIControl {
  // MARK: - Properties
  public var items: [String] = [] {
    didSet { setupSegmentControl(with: items) }
  }
  
  public private(set) var selectedSegmentIndex: Int = 0
  
  // MARK: - UI Componenets
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.backgroundColor = .clear
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 0
    
    return stackView
  }()
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension PhotiSegmentControl {
  func setupUI() {
    backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubview(stackView)
  }
  
  func setConstraints() {
    stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}

// MARK: - Private Methods
private extension PhotiSegmentControl {
  func setupSegmentControl(with items: [String]) {
    removeAllSegment()
    
    let buttons = items.enumerated().map { index, item in
      segmentButton(title: item, tag: index)
    }
    
    stackView.addArrangedSubviews(buttons)
  }
  
  func removeAllSegment() {
    stackView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  func segmentButton(title: String, tag: Int) -> SegmentButton {
    let button = SegmentButton(title: title)
    button.tag = tag
    if tag == selectedSegmentIndex { button.isSelected = true }
    
    button.addAction(
      .init { [weak self] _ in
        self?.selectedSegment(at: tag)
      },
      for: .touchUpInside
    )
    
    return button
  }
  
  func selectedSegment(at index: Int) {
    let segmentButtons = stackView.subviews
      .compactMap { $0 as? SegmentButton }
    
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

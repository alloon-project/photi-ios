//
//  CenterSegmentControl.swift
//  DesignSystem
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

public final class CenterSegmentControl: PhotiSegmentControl {
  enum Constants {
    static let lineHeight: CGFloat = 2
    static let lineWidth: CGFloat = 37
  }
  
  public override var selectedSegmentIndex: Int {
    didSet { moveCenterLine(to: selectedSegmentIndex) }
  }
  
  // MARK: - UI Componenets
  private let bottomLine: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  private let centerLine = UIView()
  
  override func segmentButton(title: String, tag: Int) -> SegmentButton {
    let button = CenterSegmentButton(title: title)
    button.tag = tag
    
    return button
  }
  
  override func setupUI() {
    super.setupUI()
    setViewHierarchy()
    setConstraints()
    configureCenterLine()
  }
  
  override func configureButtons(_ buttons: [SegmentButton]) {
    super.configureButtons(buttons)
    centerLine.isHidden = buttons.isEmpty
  }
  
  // MARK: - LayoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    guard !segmentButtons.isEmpty else { return }

    let centerLineX = centerLineXPosition(index: selectedSegmentIndex)

    centerLine.frame = .init(
      x: centerLineX,
      y: frame.height - Constants.lineHeight,
      width: Constants.lineWidth,
      height: Constants.lineHeight
    )
  }
}

// MARK: - UI Methods
private extension CenterSegmentControl {
  func setViewHierarchy() {
    addSubviews(bottomLine, centerLine)
  }
  
  func setConstraints() {
    bottomLine.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(1)
    }
  }
  
  func configureCenterLine() {
    centerLine.layer.cornerRadius = 1
    centerLine.backgroundColor = .blue500
  }
  
  func moveCenterLine(to index: Int) {
    guard segmentButtons.count > index else { return }
    
    let centerLineX = centerLineXPosition(index: index)
    centerLine.frame.origin.x = centerLineX
  }
  
  func centerLineXPosition(index: Int) -> CGFloat {
    guard segmentButtons.count > index else { return 0.0 }
    
    let centerX = segmentButtons[index].center.x
    return centerX - Constants.lineWidth / 2
  }
}

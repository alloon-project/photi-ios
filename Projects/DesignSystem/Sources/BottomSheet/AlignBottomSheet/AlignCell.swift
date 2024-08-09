//
//  AlignCell.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class AlignCell: UITableViewCell {
  private var textColor: UIColor {
    isSelected ? .blue500 : .gray900
  }
  
  override var isSelected: Bool {
    didSet {
      setLabelTextColor(isSelected: isSelected)
    }
  }
  
  // MARK: - UI Components
  let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center

    return label
  }()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with text: String, isSelected: Bool) {
    self.isSelected = isSelected
   
    label.attributedText = text.attributedString(
      font: .body2Bold,
      color: textColor
    )
  }
}

// MARK: - UI Methods
private extension AlignCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(label)
  }
  
  func setConstraints() {
    label.snp.makeConstraints { $0.center.equalToSuperview() }
  }
}

// MARK: - Private Methods
private extension AlignCell {
  func setLabelTextColor(isSelected: Bool) {
    label.attributedText = label.attributedText?.setColor(textColor)
  }
}

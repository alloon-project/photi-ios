//
//  DropDownCell.swift
//  DesignSystem
//
//  Created by jung on 5/17/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class DropDownCell: UITableViewCell {
  // MARK: - UI Components
  private let label = UILabel()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  // MARK: - Configure
  func configure(with text: String) {
    label.attributedText = text.attributedString(
      font: .body2,
      color: .gray900
    )
  }
}

// MARK: - UI Methods
private extension DropDownCell {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(label)
  }
  
  func setConstraints() {
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.centerY.equalToSuperview()
    }
  }
}

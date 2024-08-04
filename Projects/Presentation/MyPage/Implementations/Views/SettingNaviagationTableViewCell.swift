//
//  SettingNaviagationTableViewCell.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class SettingNaviagationTableViewCell: UITableViewCell {
  
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let arrowImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "chevron.right")?.resize(CGSize(width: 13, height: 13))
    return imageView
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
  func configure(with text: String) {
    titleLabel.attributedText = text.attributedString(
      font: .body1,
      color: .gray900
    )
  }
}

// MARK: UI Methods
private extension SettingNaviagationTableViewCell {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(titleLabel, arrowImageView)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview()
    }
    arrowImageView.snp.makeConstraints {
      $0.trailing.centerY.equalToSuperview()
      $0.width.height.equalTo(32)
    }
  }
}

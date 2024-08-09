//
//  SelectCell.swift
//  DesignSystem
//
//  Created by jung on 7/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class SelectCell: UICollectionViewCell {
  // MARK: - UI Components
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  
  override var isHighlighted: Bool {
    didSet {
      self.backgroundColor = backgroundColor(for: isHighlighted)
    }
  }
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with dataSource: SelectDataSource) {
    self.imageView.image = dataSource.image
    self.titleLabel.attributedText = dataSource.title
      .attributedString(font: .heading3, color: .black)
  }
}

// MARK: - UI Methods
private extension SelectCell {
  func setupUI() {
    self.layer.cornerRadius = 12
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.gray200.cgColor
    setViewHierarhcy()
    setConstraints()
  }
  
  func setViewHierarhcy() {
    self.contentView.addSubviews(imageView, titleLabel)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(imageView.snp.bottom).offset(16)
      $0.bottom.equalToSuperview().offset(-16)
    }
  }
}

// MARK: - Private Methods
private extension SelectCell {
  func backgroundColor(for isHighlighted: Bool) -> UIColor {
    return isHighlighted ? .gray300 : .white
  }
}

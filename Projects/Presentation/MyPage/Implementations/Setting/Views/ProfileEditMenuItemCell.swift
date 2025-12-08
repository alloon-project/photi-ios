//
//  ProfileEditMenuItemCell.swift
//  MyPageImpl
//
//  Created by jung on 6/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import CoreUI
import DesignSystem

final class ProfileEditMenuItemCell: UITableViewCell {
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let accessoryViewContainer = UIView()
  private let arrowImageView = UIImageView(image: .chevronForwardGray400)
  private let rightLabel = UILabel()
  
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
  func configure(with item: ProfileEditMenuItem) {
    titleLabel.attributedText = item.title.attributedString(
      font: .body1,
      color: .gray900
    )
    configureAccessoryView(with: item.displayType)
  }
}

// MARK: UI Methods
private extension ProfileEditMenuItemCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(titleLabel, accessoryViewContainer)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.centerY.equalToSuperview()
    }
    
    accessoryViewContainer.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(8)
      $0.centerY.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension ProfileEditMenuItemCell {
  func configureAccessoryView(with type: MenuDisplayType) {
    accessoryViewContainer.subviews.forEach { $0.removeFromSuperview() }
    switch type {
    case .default:
      accessoryViewContainer.addSubview(arrowImageView)
      arrowImageView.snp.remakeConstraints {
        $0.edges.equalToSuperview()
        $0.width.height.equalTo(13)
      }
    case let .leftSubTitle(_, subTitle):
      rightLabel.attributedText = subTitle.attributedString(
        font: .body2,
        color: .gray500
      )
      accessoryViewContainer.addSubview(rightLabel)
      rightLabel.snp.remakeConstraints {
        $0.edges.equalToSuperview()
      }
    }
  }
}

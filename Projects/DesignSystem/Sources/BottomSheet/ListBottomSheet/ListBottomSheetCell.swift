//
//  ListBottomSheetCell.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SnapKit
import Core

final class ListBottomSheetCell: UITableViewCell {
  // MARK: - UI Components
  let label = UILabel()
  let iconView = UIImageView(image: .chevronForwardGray400)
  
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
    label.attributedText = text.attributedString(
      font: .body2Bold,
      color: .gray800
    )
  }
}

// MARK: - UI Methods
private extension ListBottomSheetCell {
  func setupUI() { 
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(label, iconView)
  }
  
  func setConstraints() {
    label.snp.makeConstraints {
      $0.leading.centerY.equalToSuperview()
    }
    
    iconView.snp.makeConstraints {
      $0.width.height.equalTo(20)
      $0.centerY.trailing.equalToSuperview()
    }
  }
}

// MARK: - Reactive Extension
extension Reactive where Base: ListBottomSheetCell {
  var didTapIcon: ControlEvent<Void> {
    let source = base.iconView.rx.tapGesture().when(.recognized).map { _ in }
    return .init(events: source)
  }
}

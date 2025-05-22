//
//  HashTagCell.swift
//  DesignSystem
//
//  Created by jung on 11/8/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

public enum HashTagType {
  case icon(size: ChipSize, type: IconChipType)
  case text(size: ChipSize, type: TextChipType)
  
  func make(with text: String, iconImage: UIImage? = nil) -> UIView {
    switch self {
      case let .icon(size, type):
      return IconChip(text: text, icon: iconImage ?? .closeWhite, type: type, size: size)
      case let .text(size, type):
        return TextChip(text: text, type: type, size: size)
    }
  }
}

public final class HashTagCell: UICollectionViewCell {
  fileprivate var chip: UIView = UIView()
  
  public func configure(type: HashTagType, text: String, iconImage: UIImage? = nil) {
    self.chip = type.make(with: text, iconImage: iconImage)
    
    setupUI(with: chip)
  }
}

// MARK: - UI Methods
private extension HashTagCell {
  func setupUI(with view: UIView) {
    chip.removeFromSuperview()
    chip = view
    
    contentView.addSubview(chip)
    chip.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}

public extension Reactive where Base: HashTagCell {
  var didTapCloseButton: ControlEvent<Void> {
    guard let iconChip = base.chip as? IconChip else {
      let emptyObservable = Observable<Void>.empty()
      return ControlEvent(events: emptyObservable)
    }
    
    return iconChip.rx.didTapIcon
  }
}

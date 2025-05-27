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

public enum HashTagType: Equatable {
  case icon(size: ChipSize, type: IconChipType)
  case text(size: ChipSize, type: TextChipType)
  
  func make(with text: String) -> UIView {
    switch self {
      case let .icon(size, type):
        return IconChip(text: text, icon: .closeWhite, type: type, size: size)
      case let .text(size, type):
        return TextChip(text: text, type: type, size: size)
    }
  }
}

public final class HashTagCell: UICollectionViewCell {
  // MARK: - Variables
  private let disposeBag = DisposeBag()
  public var onTapClose: (() -> Void)?
  fileprivate var chip: UIView = UIView()
  private var type: HashTagType?
  
  public func configure(type: HashTagType, text: String) {
    guard self.type != type else { return configureText(text) }
    self.type = type
    self.chip = type.make(with: text)
    setupUI(with: chip)
    bind()
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    onTapClose = nil
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
  
  func configureText(_ text: String) {
    if let view = chip as? TextChip {
      view.text = text
    } else if let view = chip as? IconChip {
      view.text = text
    }
  }
}

// MARK: - Bind Method
private extension HashTagCell {
  func bind() {
    guard let iconChip = chip as? IconChip else {
      return
    }
    iconChip.rx.didTapIcon
      .bind { [weak self] in
        self?.onTapClose?()
      }.disposed(by: disposeBag)
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

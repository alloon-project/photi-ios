//
//  RecentSearchInputCell.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import DesignSystem

final class RecentSearchInputCell: UICollectionViewCell {
  fileprivate let chip = IconChip(icon: .closeGray700, type: .line, size: .large)
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with text: String) {
    chip.text = text
  }
}

// MARK: - UI Methods
private extension RecentSearchInputCell {
  func setupUI() {
    contentView.addSubview(chip)
    chip.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}

// MARK: - Reactive Extension
extension Reactive where Base: RecentSearchInputCell {
  var didTapDeleteButton: ControlEvent<Void> {
    let events = Observable<Void>.create { observer in
      let cancellable = base.chip.didTapIcon.sink { observer.onNext(()) }
      return Disposables.create { cancellable.cancel() }
    }

    return ControlEvent(events: events)
  }
}

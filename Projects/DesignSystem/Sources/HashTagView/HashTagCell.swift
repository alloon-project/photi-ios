//
//  HashTagCell.swift
//  DesignSystem
//
//  Created by jung on 11/8/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
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
  private var cancellables = Set<AnyCancellable>()
  private let didTapCloseSubject = PassthroughSubject<Void, Never>()
  public var didTapClose: AnyPublisher<Void, Never> { didTapCloseSubject.eraseToAnyPublisher() }
  
  private var chip: UIView = UIView()
  private var type: HashTagType?
  
  public func configure(type: HashTagType, text: String) {
    guard self.type != type else { return configureText(text) }
    self.type = type
    self.chip = type.make(with: text)
    self.cancellables.removeAll()
    setupUI(with: chip)
    
    // 아이콘 칩이면 탭 이벤트를 퍼블리셔로 forward
    if let icon = chip as? IconChip {
      icon.didTapIcon
        .sink(with: self) { owner, _ in
          owner.didTapCloseSubject.send()
        }
        .store(in: &cancellables)
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    cancellables.removeAll()
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

//
//  FeedLikeButton.swift
//  ChallengeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

final class FeedLikeButton: UIButton {
  private let isSelectedImage: UIImage = .heartFilledGray700
    .resize(.init(width: 14, height: 14))
  
  private let defaultImage: UIImage = .heartGray400
    .resize(.init(width: 14, height: 14))
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension FeedLikeButton {
  func setupUI() {
    layer.cornerRadius = 8
    backgroundColor = .gray200
    var configuration = UIButton.Configuration.plain()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 13, trailing: 13)
    configuration.baseBackgroundColor = .clear

    self.configuration = configuration
    self.configurationUpdateHandler = configurationUpdate
  }
    
  func configurationUpdate(button: UIButton) {
    guard var configuration = button.configuration else { return }
    
    switch button.state {
      case .selected:
        configuration.image = isSelectedImage
      default:
        configuration.image = defaultImage
    }
    
    button.configuration = configuration
  }
  
  @objc func didTap() {
    isSelected.toggle()
  }
}

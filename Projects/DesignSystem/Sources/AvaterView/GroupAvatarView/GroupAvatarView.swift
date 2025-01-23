//
//  GroupAvatarView.swift
//  DesignSystem
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core
import SnapKit

public final class GroupAvatarView: UIStackView {
  public enum GroupAvatarSize {
    case small, xSmall
  }
  
  public let size: GroupAvatarSize
  
  // MARK: - Initializers
  public init(size: GroupAvatarSize) {
    self.size = size
    super.init(frame: .zero)
    
    axis = .horizontal
    spacing = (size == .small) ? -12 : -10
    distribution = .fill
    distribution = .fillEqually
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Public Methods
public extension GroupAvatarView {
  func configure(
    maximumAvatarCount: Int,
    avatarImages: [UIImage] = [],
    count: Int
  ) {
    removeAllSubviews()
    let views = configureSubviews(
      maximumAvatarCount: maximumAvatarCount,
      avatarImages: avatarImages,
      count: count
    )
    
    addArrangedSubviews(views)
  }
}

// MARK: - Private Methods
private extension GroupAvatarView {
  func configureSubviews(
    maximumAvatarCount: Int,
    avatarImages: [UIImage],
    count: Int
  ) -> [UIView] {
    var views: [UIView] = avatarImageViews(
      count: min(maximumAvatarCount, count),
      avatarImages: avatarImages
    )
    
    if count > maximumAvatarCount {
      views.append(TextRoundView(size: size, count: count - maximumAvatarCount))
    }
    
    return views
  }
  
  func avatarImageViews(count: Int, avatarImages: [UIImage]) -> [AvatarImageView] {
    var imageViews = [AvatarImageView]()
    var tempAvatarImages: [UIImage?] = Array(repeating: nil, count: count)
    let avatarSize = convertToAvatarSize(size)

    avatarImages.prefix(count).enumerated().forEach {
      tempAvatarImages[$0.offset] = $0.element
    }
    
    tempAvatarImages.forEach {
      imageViews.append(.init(size: avatarSize, image: $0))
    }
    imageViews.forEach {
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.white.cgColor
    }

    return imageViews
  }
  
  func removeAllSubviews() {
    let subviews = subviews
    subviews.forEach { $0.removeFromSuperview() }
  }
  
  func convertToAvatarSize(_ size: GroupAvatarSize) -> AvatarSize {
    switch size {
      case .small: return .small
      case .xSmall: return .xSmall
    }
  }
}

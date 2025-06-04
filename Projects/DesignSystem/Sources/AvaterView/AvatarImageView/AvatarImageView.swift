//
//  AvatarImageView.swift
//  DesignSystem
//
//  Created by jung on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

public final class AvatarImageView: UIImageView {
  // MARK: - Properties
  public override var intrinsicContentSize: CGSize { return cgSize(for: size) }
  
  public let size: AvatarSize
  private var defaultImage: UIImage

  // MARK: - Initializers
  public init(size: AvatarSize, image: UIImage?) {
    self.size = size
    self.defaultImage = .personLight
    super.init(frame: .zero)
    self.clipsToBounds = true
    contentMode = .center
    self.backgroundColor = .gray400
    self.defaultImage = .personLight.resize(defaultImageSize(for: size))
    configureImage(image)
  }
  
  public convenience init(size: AvatarSize) {
    self.init(size: size, image: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = frame.width / 2
  }
}

// MARK: - Public Methods
public extension AvatarImageView {
  func configureImage(_ image: UIImage?) {
    contentMode = image == nil ? .center : .scaleAspectFill

    let image = image ?? defaultImage
    self.image = image
  }
}

// MARK: - Private Methods
private extension AvatarImageView {
  func cgSize(for size: AvatarSize) -> CGSize {
    switch size {
      case .large: return CGSize(width: 96, height: 96)
      case .medium: return CGSize(width: 48, height: 48)
      case .small: return CGSize(width: 30, height: 30)
      case .xSmall: return CGSize(width: 24, height: 24)
    }
  }
  
  func defaultImageSize(for size: AvatarSize) -> CGSize {
    switch size {
      case .large: return CGSize(width: 40, height: 40)
      case .medium: return CGSize(width: 24, height: 24)
      case .small: return CGSize(width: 16, height: 16)
      case .xSmall: return CGSize(width: 12, height: 12)
    }
  }
}

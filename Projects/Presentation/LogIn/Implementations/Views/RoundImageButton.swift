//
//  RoundButton.swift
//  LogInImpl
//
//  Created by jung on 2/17/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import UIKit

final class RoundImageButton: UIButton {
  // MARK: - Initializer
  init(image: UIImage) {
    super.init(frame: .zero)
    configure(with: image)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func configure(with image: UIImage) {
    setTitle(nil, for: .normal)
    setImage(image, for: .normal)
    
    imageView?.contentMode = .scaleAspectFill
    clipsToBounds = true
    
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = bounds.width / 2
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalTo: widthAnchor)
    ])
  }
}

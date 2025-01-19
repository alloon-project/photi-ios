//
//  PhotiNavigationButton.swift
//  DesignSystem
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

public final class PhotiNavigationButton: UIButton {
  public static var optionButton: PhotiNavigationButton {
    return PhotiNavigationButton(image: .ellipsisVerticalWhite)
  }
  public static var searchButton: PhotiNavigationButton {
    return PhotiNavigationButton(image: .searchWhite)
  }
  public static var shareButton: PhotiNavigationButton {
    return PhotiNavigationButton(image: .shareWhite)
  }
  
  // MARK: - intrinsicContentSize
  public override var intrinsicContentSize: CGSize {
    return .init(width: 24, height: 24)
  }
  
  // MARK: - Properties
  private let iconContentInset: NSDirectionalEdgeInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
  private let image: UIImage
  
  // MARK: - Initializers
  init(image: UIImage) {
    self.image = image
    super.init(frame: .zero)
    configure(with: image)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
public extension PhotiNavigationButton {
  func configure(with image: UIImage, color: UIColor) {
    let colorImage = image.color(color)
    configure(with: colorImage)
  }
  
  func convert(color: UIColor) {
    let colorImage = image.color(color)
    configure(with: colorImage)
  }
  
  func configure(with image: UIImage) {
    var configuration = UIButton.Configuration.plain()
    configuration.image = image
    
    configuration.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
    self.configuration = configuration
  }
}

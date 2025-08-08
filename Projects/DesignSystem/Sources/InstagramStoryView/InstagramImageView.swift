//
//  InstagramImageView.swift
//  DesignSystem
//
//  Created by jung on 8/8/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class InstagramImageView: UIView {
  // MARK: - UI Components
  private let bottomGradientLayer: GradientLayer = {
    let color = UIColor(red: 0.118, green: 0.137, blue: 0.149, alpha: 0.8)
    return .init(mode: .bottomToTop, maxColor: color)
  }()
  
  private let feedImageView = UIImageView()
  private let cornerView: UIView = {
    let view = UIView()
    view.backgroundColor = .gray200
    view.layer.cornerRadius = 6
    return view
  }()
  private let labelImageView = UIImageView(image: .logoLettersWhite)
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    bottomGradientLayer.frame = bounds
    roundCorners(leftTop: 16, rightTop: 16, leftBottom: 16, rightBottom: 80)
    configureShapeBorder(width: 8, strockColor: .green100, backGroundColor: .clear)
  }
  
  func configure(with image: UIImage) {
    feedImageView.image = image
  }
}

// MARK: - UI Methods
private extension InstagramImageView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    self.clipsToBounds = true
  }
  
  func setViewHierarchy() {
    addSubview(feedImageView)
    layer.addSublayer(bottomGradientLayer)
    addSubviews(cornerView, labelImageView)
  }
  
  func setConstraints() {
    feedImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    cornerView.snp.makeConstraints {
      $0.trailing.bottom.equalToSuperview().inset(2)
      $0.width.height.equalTo(64)
    }

    labelImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(16)
    }
  }
}

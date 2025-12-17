//
//  FeedImageView.swift
//  MyPageImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import CoreUI
import DesignSystem

final class FeedImageView: UIView {
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    
    return layer
  }()
  
  private let feedImageView = UIImageView()
  private let cornerView: UIView = {
    let view = UIView()
    view.backgroundColor = .gray200
    view.layer.cornerRadius = 6
    return view
  }()
  private let provedDateLabel = UILabel()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    dimmedLayer.frame = bounds
    roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    configureShapeBorder(width: 3, strockColor: .gray200, backGroundColor: .clear)
  }
  
  // MARK: - Configure Methods
  func configure(with model: FeedCardPresentationModel) {
    feedImageView.kf.setImage(with: model.feedImageUrl)
    provedDateLabel.attributedText = model.provedDate.attributedString(
      font: .caption1Bold,
      color: .init(white: 1.0, alpha: 0.6)
    )
  }
}

// MARK: - UI Methods
private extension FeedImageView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    self.clipsToBounds = true
  }
  
  func setViewHierarchy() {
    addSubview(feedImageView)
    layer.addSublayer(dimmedLayer)
    addSubviews(cornerView, provedDateLabel)
  }
  
  func setConstraints() {
    feedImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    cornerView.snp.makeConstraints {
      $0.trailing.bottom.equalToSuperview().inset(2)
      $0.width.height.equalTo(22)
    }

    provedDateLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(16)
    }
  }
}

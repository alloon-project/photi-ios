//
//  InstagramStoryView.swift
//  DesignSystem
//
//  Created by jung on 8/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

public final class InstagramStoryView: UIView {
  // MARK: - UI Components
  private let backgrounView = UIImageView(image: .instagramStoryBackground)
  private let feedImageView = InstagramImageView()
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "오늘의 인증 완료!".attributedString(font: .body1Bold, color: .white)
    return label
  }()
  
  private let titleView = InstagramStoryTitleView()
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  public func configure(image: UIImage, title: String) {
    feedImageView.configure(with: image)
    titleView.configure(with: title)
  }
}

// MARK: - UI Methods
private extension InstagramStoryView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(backgrounView)
    backgrounView.addSubviews(feedImageView, subTitleLabel, titleView)
  }
  
  func setConstraints() {
    backgrounView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    feedImageView.snp.makeConstraints {
      $0.width.equalTo(289)
      $0.height.equalTo(396)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(89)
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(feedImageView.snp.bottom).offset(20)
    }
    
    titleView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(subTitleLabel.snp.bottom).offset(16)
      $0.width.equalTo(feedImageView)
      $0.height.equalTo(50)
    }
  }
}

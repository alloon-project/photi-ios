//
//  EndedChallengeCardCell.swift
//  Presentation
//
//  Created by wooseob on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import Core
import DesignSystem

public final class EndedChallengeCardCell: UICollectionViewCell {
  // MARK: - UI Components
  private let gradientLayer = GradientLayer(
    mode: .bottomToTop,
    minColor: .white,
    maxColor: .init(white: 0.486, alpha: 1)
  )
  private let mainContentView = UIView()
  private let thumbnailView = UIImageView()
  private let titleLabel = UILabel()
  private let deadLineLabel = UILabel()
  private let bottomBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .init(white: 1, alpha: 0.3)
    
    return view
  }()
  private let groupAvatarView = GroupAvatarView(size: .xSmall)
  
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
  public override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = bounds
  }
  
  // MARK: - Configure Methods
  func configure(with model: EndedChallengeCardPresentationModel) {
    thumbnailView.kf.setImage(with: model.thumbnailUrl)
    configureGroupAvatarView(model.memberImageUrls, memberCount: model.currentMemberCnt)
    titleLabel.attributedText = model.title.attributedString(font: .body1Bold, color: .white)
    let deadLineTextColor = UIColor(white: 1, alpha: 0.3)
    deadLineLabel.attributedText = model.deadLine.attributedString(font: .caption1Bold, color: deadLineTextColor)
  }
}

// MARK: - UI Methods
private extension EndedChallengeCardCell {
  func setupUI() {
    titleLabel.numberOfLines = 2
    mainContentView.layer.cornerRadius = 8
    layer.cornerRadius = 8
    layer.borderWidth = 2
    layer.borderColor = UIColor.white.cgColor
    mainContentView.clipsToBounds = true
    
    let shadowColor = UIColor(white: 0.125, alpha: 0.2)
    drawShadow(color: shadowColor, opacity: 1, radius: 6)

    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(mainContentView)
    mainContentView.addSubview(thumbnailView)
    mainContentView.layer.addSublayer(gradientLayer)
    mainContentView.addSubviews(titleLabel, deadLineLabel, bottomBackgroundView)
    bottomBackgroundView.addSubview(groupAvatarView)
  }
  
  func setConstraints() {
    mainContentView.snp.makeConstraints { $0.edges.equalToSuperview() }
    thumbnailView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(deadLineLabel.snp.top).offset(-8)
    }
    
    deadLineLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(bottomBackgroundView.snp.top).offset(-6)
    }
    
    bottomBackgroundView.snp.makeConstraints {
      $0.leading.bottom.trailing.equalToSuperview()
      $0.height.equalTo(49)
    }
    
    groupAvatarView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension EndedChallengeCardCell {
  func configureGroupAvatarView(_ urls: [URL], memberCount: Int) {
    Task { [weak self] in
      guard let self else { return }
      // TODO: - 이미지 다운 샘플링 예정
      let images = await downLoadImages(with: urls)
      
      groupAvatarView.configure(
        maximumAvatarCount: 2,
        avatarImages: images,
        count: memberCount
      )
    }
  }
  
  func downLoadImages(with urls: [URL]) async -> [UIImage] {
    var images = [UIImage]()
    
    await withTaskGroup(of: Void.self) { group in
      urls.forEach { url in
        group.addTask {
          guard let image = try? await KingfisherManager.shared.retrieveImage(with: url) else { return }
          images.append(image.image)
        }
      }
    }
    
    return images
  }
}

//
//  ChallengeThumbnailView.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import DesignSystem

final class ChallengeThumbnailView: UIView, ChallengeInformationPresentable {
  // MARK: UI Components
  private let groupAvatarView = GroupAvatarView(size: .xSmall)
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    layer.cornerRadius = 10
    
    return layer
  }()
  private let countLabel = UILabel()
  private let thumbnailImageView = UIImageView(image: .challengeNonMemberDefaultCard)
  
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
    dimmedLayer.frame = bounds
  }
  
  // MARK: - Configure Methods
  func configure(
    count: Int,
    thumbnailImageURL: URL?,
    avartarImageURLs: [URL] = []
  ) {
    configureCountLabel(count)
    // TODO: - 이미지 다운 샘플링 예정
    if let thumbnailImageURL {
      thumbnailImageView.kf.setImage(with: thumbnailImageURL) { [weak self] result in
        switch result {
          case .failure:
            self?.thumbnailImageView.image = .challengeNonMemberDefaultCard
          default: break
        }
      }
    }
    
    Task { [weak self] in
      guard let self else { return }
      // TODO: - 이미지 다운 샘플링 예정
      let images = await downLoadImages(with: avartarImageURLs)
      
      groupAvatarView.configure(
        maximumAvatarCount: 2,
        avatarImages: images,
        count: count
      )
    }
  }
}

// MARK: - UI Methods
private extension ChallengeThumbnailView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(thumbnailImageView)
    layer.addSublayer(dimmedLayer)
    addSubviews(groupAvatarView, countLabel)
  }
  
  func setConstraints() {
    thumbnailImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    groupAvatarView.snp.makeConstraints {
      $0.leading.top.equalToSuperview().inset(14)
    }
    
    countLabel.snp.makeConstraints {
      $0.leading.equalTo(groupAvatarView.snp.trailing).offset(5)
      $0.centerY.equalTo(groupAvatarView)
    }
  }
}

// MARK: - Private Methods
private extension ChallengeThumbnailView {
  func configureCountLabel(_ count: Int) {
    countLabel.attributedText = "\(count)명 합류".attributedString(
      font: .caption1,
      color: .gray200
    )
  }
  
  func downLoadImages(with urls: [URL]) async -> [UIImage] {
    var images = [UIImage]()
    
    await withTaskGroup(of: Void.self) { [weak self] group in
      guard let self else { return }
      urls.forEach { url in
        group.addTask {
          guard let image = try? await self.downLoadImage(with: url) else { return }
          images.append(image)
        }
      }
    }
    
    return images
  }
  
  func downLoadImage(with url: URL) async throws -> UIImage? {
    return try await withCheckedThrowingContinuation { continuation in
      let resource = KF.ImageResource(downloadURL: url)
      KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
        switch result {
          case .success(let value):
            continuation.resume(returning: value.image)
          case .failure(let error):
            continuation.resume(throwing: error)
        }
      }
    }
  }
}

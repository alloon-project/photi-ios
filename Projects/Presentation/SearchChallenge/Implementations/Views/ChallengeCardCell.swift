//
//  ChallengeCardCell.swift
//  HomeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core
import Kingfisher
import DesignSystem

final class ChallengeCardCell: UICollectionViewCell {
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  
  // MARK: - UI Components
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    layer.cornerRadius = 8
    return layer
  }()
  private let deadLineTextColor = UIColor(white: 1.0, alpha: 0.6)
  
  private let thumbnailView = UIImageView()
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .leading)
  private let titleLabel = UILabel()
  private let deadLineLabel = UILabel()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    hashTagCollectionView.delegate = self
    hashTagCollectionView.dataSource = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    dimmedLayer.frame = contentView.bounds
  }
  
  // MARK: - Configure
  func configure(with model: ChallengeCardPresentationModel) {
    thumbnailView.kf.setImage(with: model.imageUrl)
    titleLabel.attributedText = model.title.attributedString(font: .heading4, color: .white)
    deadLineLabel.attributedText = model.deadLine.attributedString(font: .caption1Bold, color: deadLineTextColor)
    hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension ChallengeCardCell {
  func setupUI() {
    thumbnailView.layer.cornerRadius = 8
    thumbnailView.clipsToBounds = true
    thumbnailView.contentMode = .scaleAspectFill
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(thumbnailView)
    contentView.layer.addSublayer(dimmedLayer)
    contentView.addSubviews(hashTagCollectionView, titleLabel, deadLineLabel)
  }
  
  func setConstraints() {
    thumbnailView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    hashTagCollectionView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(14)
      $0.height.equalTo(50)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(14)
      $0.bottom.equalTo(deadLineLabel.snp.top).offset(-10)
    }
    
    deadLineLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(14)
      $0.bottom.equalToSuperview().inset(16)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension ChallengeCardCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    cell.configure(type: .text(size: .medium, type: .white), text: hashTags[indexPath.row])
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengeCardCell: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let label = UILabel()
    label.attributedText = hashTags[indexPath.row].attributedString(font: .caption1, color: .white)
    label.sizeToFit()
    return .init(width: label.frame.width + 16, height: label.frame.height + 12)
  }
}

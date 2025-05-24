//
//  HashTagChallengeCell.swift
//  HomeImpl
//
//  Created by jung on 5/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Core
import DesignSystem

final class HashTagChallengeCell: UITableViewCell {
  private let deadLineTextColor = UIColor(white: 1.0, alpha: 0.6)
  var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .leading)
  private let thumbnailView = UIImageView()
  private let deadLineLabel = UILabel()
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    layer.cornerRadius = 8
    return layer
  }()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupUI()
    hashTagCollectionView.dataSource = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    dimmedLayer.frame = thumbnailView.bounds
  }
  
  // MARK: - Configure Method
  func configure(with model: ChallengeCardPresentationModel) {
    thumbnailView.kf.setImage(with: model.imageUrl)
    titleLabel.attributedText = model.title.attributedString(font: .heading3, color: .white)
    deadLineLabel.attributedText = model.deadLine.attributedString(font: .caption1Bold, color: deadLineTextColor)
    hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension HashTagChallengeCell {
  func setupUI() {
    selectionStyle = .none
    thumbnailView.layer.cornerRadius = 8
    thumbnailView.clipsToBounds = true

    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(thumbnailView)
    contentView.layer.addSublayer(dimmedLayer)
    contentView.addSubviews(titleLabel, hashTagCollectionView, deadLineLabel)
  }
  
  func setConstraints() {
    thumbnailView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(16)
      $0.top.equalToSuperview().inset(18)
    }
    
    deadLineLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview().inset(18)
    }
    
    hashTagCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview()
      $0.height.equalTo(50)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension HashTagChallengeCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    cell.configure(type: .text(size: .medium, type: .white), text: hashTags[indexPath.row])
    return cell
  }
}

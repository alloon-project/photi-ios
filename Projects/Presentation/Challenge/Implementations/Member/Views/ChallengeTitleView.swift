//
//  ChallengeContentView.swift
//  HomeImpl
//
//  Created by jung on 11/8/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Core
import DesignSystem

final class ChallengeTitleView: UIView {
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  
  // MARK: - UI Components
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    
    return layer
  }()
  
  private let imageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }()

  // 변경
  var titleImage: UIImage? {
    return imageView.image
  }
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 2
    
    return label
  }()
  
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .center)
  
  // MARK: - Initiazliers
  init() {
    super.init(frame: .zero)
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
    dimmedLayer.frame = .init(origin: .zero, size: bounds.size)
  }
}

// MARK: - Internal Methods
extension ChallengeTitleView {
  func configure(with model: ChallengeTitlePresentationModel) {
    if let url = model.imageURL {
      imageView.kf.setImage(with: url)
    }
    setTitle(model.title)
    hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension ChallengeTitleView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(imageView)
    layer.addSublayer(dimmedLayer)
    addSubviews(titleLabel, hashTagCollectionView)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalTo(hashTagCollectionView.snp.top).offset(-12)
    }

    hashTagCollectionView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(73)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(35)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension ChallengeTitleView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    let text = hashTags[indexPath.row]
    cell.configure(type: .text(size: .medium, type: .white), text: text)
    
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengeTitleView: UICollectionViewDelegateFlowLayout {
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

// MARK: - Private Methods
private extension ChallengeTitleView {
  func setTitle(_ title: String) {
    titleLabel.attributedText = title.attributedString(
      font: .heading1,
      color: .white,
      alignment: .center
    )
  }
}

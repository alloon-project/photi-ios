//
//  HashTagResultCardCell.swift
//  HomeImpl
//
//  Created by jung on 5/24/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import CoreUI
import DesignSystem

final class HashTagResultCardCell: UICollectionViewCell {
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  
  private let cardView = SearchChallengeCard()
  private let hashTagCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 8
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(HashTagResultHashTagCell.self)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.automaticallyAdjustsScrollIndicatorInsets = false
    collectionView.contentInsetAdjustmentBehavior = .never
    
    return collectionView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    hashTagCollectionView.dataSource = self
    hashTagCollectionView.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    
    hashTagCollectionView.layoutIfNeeded()
    centerContentHorizontalyByInsetIfNeeded()
  }
  
  func configure(with model: ResultChallengeCardPresentationModel) {
    cardView.configure(with: model)
    hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension HashTagResultCardCell {
  func setupUI() {
    contentView.addSubviews(cardView, hashTagCollectionView)
    cardView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }
    
    hashTagCollectionView.snp.makeConstraints {
      $0.top.equalTo(cardView.snp.bottom).offset(8)
      $0.leading.bottom.trailing.equalToSuperview()
      $0.height.equalTo(HashTagResultViewController.Constants.hashTagCollectionViewHeight)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension HashTagResultCardCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagResultHashTagCell.self, for: indexPath)
    cell.configure(with: hashTags[indexPath.row])
    return cell
  }
}

extension HashTagResultCardCell: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let label = UILabel()
    label.attributedText = hashTags[indexPath.row].attributedString(font: .caption2, color: .white)
    label.sizeToFit()
    return .init(width: label.frame.width + 16, height: label.frame.height + 12)
  }
}

// MARK: - private Methods
private extension HashTagResultCardCell {
  func centerContentHorizontalyByInsetIfNeeded() {
    if hashTagCollectionView.contentSize.width > hashTagCollectionView.frame.size.width {
      hashTagCollectionView.contentInset = .zero
    } else {
      hashTagCollectionView.contentInset = UIEdgeInsets(
        top: 0,
        left: (hashTagCollectionView.frame.size.width) / 2 - (hashTagCollectionView.contentSize.width) / 2,
        bottom: 0,
        right: 0
      )
    }
  }
}

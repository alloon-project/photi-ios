//
//  HomeMyChallengeCell.swift
//  HomeImpl
//
//  Created by jung on 10/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class HomeMyChallengeCell: UITableViewCell {
  // MARK: - Properties
  var hashTags: [String] = [] {
    didSet {
      hashTagCollectionView.reloadData()
      centerContentHorizontalyByInsetIfNeeded()
    }
  }
  
  // MARK: - UI Components
  private let containerView = UIView()
  private let titleLabel = UILabel()
  private let informationStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 14
    stackView.distribution = .fillProportionally
    stackView.alignment = .fill
    
    return stackView
  }()
  
  private let timeInformationView = MyChallengeInformationView()
  private let dateInformationView = MyChallengeInformationView()
  private let challengeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 6
    return imageView
  }()
  
  private let hashTagCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 8
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(HashTagCell.self)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.automaticallyAdjustsScrollIndicatorInsets = false
    collectionView.contentInsetAdjustmentBehavior = .never

    return collectionView
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
  
  // MARK: - Configure Methods
  func configure(with model: MyChallengePresentationModel) {
    configureTitleLabel(text: model.title)
    configureInformationViews(time: model.deadLineTime, date: model.deadLineDate)
    challengeImageView.image = model.image ?? .defaultHomeCard
    self.hashTags = model.hashTags
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    centerContentHorizontalyByInsetIfNeeded()
  }
}

// MARK: - UI Methods
private extension HomeMyChallengeCell {
  func setupUI() {
    contentView.layer.cornerRadius = 8
    selectionStyle = .none
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(containerView)
    containerView.addSubviews(titleLabel, informationStackView, challengeImageView)
    informationStackView.addArrangedSubviews(timeInformationView, dateInformationView)
    challengeImageView.addSubview(hashTagCollectionView)
  }
  
  func setConstraints() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview().inset(10)
      $0.top.equalToSuperview().offset(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
    }

    informationStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(14)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(16)
    }
    
    challengeImageView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(informationStackView.snp.bottom).offset(16)
      $0.height.equalTo(112)
    }

    hashTagCollectionView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(50)
    }
  }
}

// MARK: - CollectionViewDataSource
extension HomeMyChallengeCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    cell.configure(text: hashTags[indexPath.row])
    
    return cell
  }
}

// MARK: - Private Methods
private extension HomeMyChallengeCell {
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
  
  func configureTitleLabel(text: String) {
    titleLabel.attributedText = text.attributedString(font: .body1Bold, color: .photiBlack)
  }
  
  func configureInformationViews(time: String, date: String) {
    timeInformationView.configure(image: .clockGray, text: time)
    dateInformationView.configure(image: .calendarGray, text: date)
  }
}

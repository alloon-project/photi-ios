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
    didSet { hashTagCollectionView.reloadData() }
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
  
  private let hashTagCollectionView: HashTagCollectionView = {
    let collectionView = HashTagCollectionView(allignMent: .center)
    collectionView.registerCell(HashTagCell.self)
    
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
    let text = hashTags[indexPath.row]
    cell.configure(type: .text(size: .medium, type: .gray), text: text)
    
    return cell
  }
}

// MARK: - Private Methods
private extension HomeMyChallengeCell {
  func configureTitleLabel(text: String) {
    titleLabel.attributedText = text.attributedString(font: .body1Bold, color: .photiBlack)
  }
  
  func configureInformationViews(time: String, date: String) {
    timeInformationView.configure(image: .timeGray400, text: time)
    dateInformationView.configure(image: .calendarGray400, text: date)
  }
}

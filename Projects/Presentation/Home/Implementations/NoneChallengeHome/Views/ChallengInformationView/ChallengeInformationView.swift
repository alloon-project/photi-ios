//
//  ChallengeInformationView.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class ChallengeInformationView: UIView {
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  
  // MARK: - UI Components
  private let challengeNameLabel = UILabel()
  private let goalContentView = ChallengeContentView(contentCount: .one(title: "목표"))
  private let challengeTimeContentView = ChallengeContentView(
    contentCount: .two(firstTitle: "인증 시간", secondTitle: "챌린지 종료")
  )
  
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .center)
  private let participateCountView: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    view.layer.cornerRadius = 12
    
    return view
  }()
  private let participateImageView: UIImageView = {
    let imageView = UIImageView(image: .memberGroup)
    imageView.contentMode = .scaleToFill
    
    return imageView
  }()
  
  private let participateCountLabel = UILabel()
  
  private let participateButton = FilledRoundButton(type: .primary, size: .small, text: "나도 함께하기")
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
    
    hashTagCollectionView.dataSource = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(with model: ChallengePresentationModel) {
    goalContentView.configure(firstContent: model.goal)
    challengeTimeContentView.configure(
      firstContent: model.proveTime,
      secondContent: model.endDate
    )
    
    challengeNameLabel.attributedText = model.name.attributedString(font: .body1Bold, color: .gray900)
    participateCountLabel.attributedText = "\(model.numberOfPersons)명 도전 중".attributedString(
      font: .caption1,
      color: .gray700
    )
    
    self.hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension ChallengeInformationView {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    addSubviews(
      challengeNameLabel,
      hashTagCollectionView,
      goalContentView,
      challengeTimeContentView,
      participateCountView,
      participateButton
    )
    
    participateCountView.addSubviews(participateImageView, participateCountLabel)
  }
  
  func setConstraints() {
    challengeNameLabel.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
    }
    
    hashTagCollectionView.snp.makeConstraints {
      $0.top.equalTo(challengeNameLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(29)
    }
    
    goalContentView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.equalTo(hashTagCollectionView.snp.bottom).offset(16)
      $0.height.equalTo(123)
      $0.trailing.equalTo(challengeTimeContentView.snp.leading).offset(-10)
    }
    
    challengeTimeContentView.snp.makeConstraints {
      $0.top.height.equalTo(goalContentView)
      $0.trailing.equalToSuperview()
      $0.width.equalTo(participateButton)
    }
    
    participateCountView.snp.makeConstraints {
      $0.leading.trailing.equalTo(goalContentView)
      $0.top.equalTo(goalContentView.snp.bottom).offset(10)
      $0.height.equalTo(participateButton)
    }
    
    participateImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(14)
      $0.centerY.equalToSuperview()
      $0.width.equalTo(66)
      $0.height.equalTo(30)
    }
    
    participateCountLabel.snp.makeConstraints {
      $0.leading.equalTo(participateImageView.snp.trailing).offset(8)
      $0.centerY.equalToSuperview()
    }
    
    participateButton.snp.makeConstraints {
      $0.top.equalTo(challengeTimeContentView.snp.bottom).offset(10)
      $0.leading.equalTo(challengeTimeContentView)
    }
  }
}

// MARK: -
extension ChallengeInformationView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    cell.configure(
      type: .text(size: .medium, type: .gray),
      text: hashTags[indexPath.row]
    )
    return cell
  }
}

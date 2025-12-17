//
//  ChallengeInformationView.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Kingfisher
import CoreUI
import DesignSystem

final class ChallengeInformationView: UIView {
  private var hashTags = [String]() {
    didSet {
      guard oldValue != hashTags else { return }
      hashTagCollectionView.reloadData()
    }
  }
  private(set) var id: Int = 0
  
  // MARK: - UI Components
  private let challengeNameLabel = UILabel()
  private let goalContentView = ChallengeContentView(contentCount: .one(title: "목표"))
  private let challengeTimeContentView = ChallengeContentView(
    contentCount: .two(firstTitle: "인증 시간", secondTitle: "챌린지 종료")
  )
  
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .center, shouldRegisterDefaultCell: false)
  private let participateCountView: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    view.layer.cornerRadius = 12
    
    return view
  }()
  private let avatarImageView = GroupAvatarView(size: .small)
  private let participateCountLabel = UILabel()
  fileprivate let joinButton = FilledRoundButton(type: .primary, size: .small, text: "나도 함께하기")
  
  // MARK: - Initializers
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
  
  // MARK: - Configure Methods
  func configure(with model: ChallengePresentationModel) {
    self.id = model.id
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
    configureParticipantView(urls: model.memberImageURLs, count: model.numberOfPersons)
    self.hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension ChallengeInformationView {
  func setupUI() {
    hashTagCollectionView.registerCell(NoneChallengeHomeHashTagCell.self)
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
      joinButton
    )
    
    participateCountView.addSubviews(avatarImageView, participateCountLabel)
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
      $0.width.equalTo(joinButton)
    }
    
    participateCountView.snp.makeConstraints {
      $0.leading.trailing.equalTo(goalContentView)
      $0.top.equalTo(goalContentView.snp.bottom).offset(10)
      $0.height.equalTo(joinButton)
    }
    
    avatarImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(14)
      $0.centerY.equalToSuperview()
    }
    
    participateCountLabel.snp.makeConstraints {
      $0.leading.equalTo(avatarImageView.snp.trailing).offset(8)
      $0.centerY.equalToSuperview()
    }
    
    joinButton.snp.makeConstraints {
      $0.top.equalTo(challengeTimeContentView.snp.bottom).offset(10)
      $0.leading.equalTo(challengeTimeContentView)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension ChallengeInformationView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(NoneChallengeHomeHashTagCell.self, for: indexPath)
    cell.configure(with: hashTags[indexPath.row])
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengeInformationView: UICollectionViewDelegateFlowLayout {
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
private extension ChallengeInformationView {
  func configureParticipantView(urls: [URL], count: Int) {
    Task { [weak self] in
      guard let self else { return }
      let images = await downLoadImages(with: urls)
      
      self.avatarImageView.configure(
        maximumAvatarCount: 2,
        avatarImages: images,
        count: count
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

extension Reactive where Base == ChallengeInformationView {
  var didTapJoinButton: ControlEvent<Int> {
    let source = base.joinButton.rx.tap.map { _ in base.id }
    
    return .init(events: source)
  }
}

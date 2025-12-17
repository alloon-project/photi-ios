//
//  HomeMyChallengeCell.swift
//  HomeImpl
//
//  Created by jung on 10/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import CoreUI
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
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.2)
    return view
  }()
 
  private let challengeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 6
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }()
  
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .center)
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    selectionStyle = .none
    hashTagCollectionView.delegate = self
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

    challengeImageView.kf.setImage(with: model.imageUrl) { [weak self] result in
      guard let self else { return }
      switch result {
        case .failure:
          DispatchQueue.main.async { [weak self] in
            self?.challengeImageView.image = .defaultHomeCard
          }
        default: break
      }
    }

    self.hashTags = model.hashTags
  }
}

// MARK: - UI Methods
private extension HomeMyChallengeCell {
  func setupUI() {
    contentView.layer.cornerRadius = 8
    contentView.backgroundColor = .white
    backgroundColor = .clear
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(containerView)
    containerView.addSubviews(titleLabel, informationStackView, challengeImageView)
    informationStackView.addArrangedSubviews(timeInformationView, dateInformationView)
    challengeImageView.addSubview(dimmedView)
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

    dimmedView.snp.makeConstraints {
      $0.edges.equalToSuperview()
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
    cell.configure(type: .text(size: .medium, type: .white), text: text)
    
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeMyChallengeCell: UICollectionViewDelegateFlowLayout {
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
private extension HomeMyChallengeCell {
  func configureTitleLabel(text: String) {
    titleLabel.attributedText = text.attributedString(font: .body1Bold, color: .photiBlack)
  }
  
  func configureInformationViews(time: String, date: String) {
    timeInformationView.configure(image: .timeGray400, text: time)
    dateInformationView.configure(image: .calendarGray400, text: date)
  }
}

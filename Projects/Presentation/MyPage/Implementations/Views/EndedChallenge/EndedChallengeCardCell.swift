//
//  EndedChallengeCardCell.swift
//  Presentation
//
//  Created by wooseob on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import Core

public final class EndedChallengeCardCell: UICollectionViewCell {
  // MARK: - Properties
  private(set) var model: EndedChallengeCardCellPresentationModel?
  
  // MARK: - UI Components
  private let whiteBackGroundView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    view.drawShadow(
      color: .photiBlack,
      opacity: 0.6,
      radius: 8
    )
    view.backgroundColor = .white
    
    return view
  }()
  
  private let challengeImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 8
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }()
  
  private let challengeTitleLabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.attributedText = "산책 챌린지".attributedString(
      font: .body1,
      color: .white
    )
    label.textAlignment = .center
    label.lineBreakMode = .byTruncatingTail
    
    return label
  }()
  
  private let endedDateLabel = {
    let label = UILabel()
    label.attributedText = "2024. 8. 30 종료".attributedString(
      font: .body1,
      color: .init(white: 1.0, alpha: 0.3)
    )
    label.textAlignment = .center
    
    return label
  }()
  
  private let bottomWhiteView = {
    let view = UIView()
    view.backgroundColor = .init(white: 1.0, alpha: 0.3)
    
    return view
  }()
  
  private let participantStackView = {
    let stackView = UIStackView()
    stackView.spacing = -10
    
    return stackView
  }()
  
  private let firstUserImageView = {
    let imageView = UIImageView()
    imageView.configureShapeBorder(
      width: 1,
      strockColor: .white,
      backGroundColor: .gray400
    )
    imageView.layer.cornerRadius = 12
    
    return imageView
  }()
  
  private let secondUserImageView = {
    let imageView = UIImageView()
    imageView.configureShapeBorder(
      width: 1,
      strockColor: .white,
      backGroundColor: .gray400
    )
    imageView.layer.cornerRadius = 12
    
    return imageView
  }()
  
  private let moreUserImageView = {
    let imageView = UIImageView()

    imageView.layer.borderWidth = 1.0
    imageView.layer.borderColor = UIColor.white.cgColor
    
    imageView.layer.cornerRadius = 12
    
    return imageView
  }()
  
  private let moreUserNumberLabel = {
    let label = UILabel()
    label.configureShapeBorder(
      width: 1,
      strockColor: .white,
      backGroundColor: .gray500
    )
    label.layer.cornerRadius = 12
    
    return label
  }()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(with viewModel: EndedChallengeCardCellPresentationModel) {
    if let url = viewModel.challengeImageUrl {
      challengeImageView.kf.setImage(with: url)
    }
    
    challengeTitleLabel.text = viewModel.challengeTitle
    endedDateLabel.text = viewModel.endedDate
    
    setupImageView(memberCount: viewModel.currentMemberCnt)
  }
}

// MARK: - UI Methods
private extension EndedChallengeCardCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(whiteBackGroundView)
    
    whiteBackGroundView.addSubviews(
      challengeImageView,
      challengeTitleLabel,
      endedDateLabel,
      bottomWhiteView
    )
    
    bottomWhiteView.addSubview(participantStackView)
    
    participantStackView.addArrangedSubviews(
      firstUserImageView,
      secondUserImageView,
      moreUserImageView,
      moreUserNumberLabel
    )
  }
  
  func setConstraints() {
    whiteBackGroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    challengeImageView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(1)
    }
    
    bottomWhiteView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(49)
    }
    
    endedDateLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(bottomWhiteView.snp.top).offset(-8)
    }
    
    challengeTitleLabel.snp.makeConstraints {
      $0.bottom.equalTo(endedDateLabel.snp.top).offset(-10)
      $0.leading.equalToSuperview().offset(8)
      $0.trailing.equalToSuperview().offset(-8)
    }
    
    participantStackView.snp.makeConstraints {
      $0.width.equalTo(52)
      $0.height.equalTo(24)
      $0.center.equalTo(bottomWhiteView)
    }
    
    firstUserImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
    
    secondUserImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
    
    moreUserImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
    
    moreUserNumberLabel.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
  }
  
  func setupImageView(memberCount: Int) {
    secondUserImageView.isHidden = memberCount < 2
    moreUserImageView.isHidden = memberCount != 3
    moreUserNumberLabel.isHidden = memberCount <= 3
    
    moreUserNumberLabel.attributedText = "+\(memberCount - 2)".attributedString(
      font: .caption2Bold,
      color: .gray0
    )
  }
}

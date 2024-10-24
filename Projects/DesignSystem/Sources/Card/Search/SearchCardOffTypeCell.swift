//
//  SearchCardOffTypeCell.swift
//  Presentation
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core

public final class SearchCardOffTypeCell: UICollectionViewCell {
  // MARK: - Properties
  private(set) var model: SearchCardPresentationModel?
  
  // MARK: - UI Components
  private let whiteBackGroundView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    
    view.layer.shadowColor = UIColor(resource: .photiBlack).cgColor
    view.layer.shadowRadius = 8
    view.layer.shadowOpacity = 1
    view.layer.shadowPath = nil
    view.backgroundColor = .white
    return view
  }()
  
  private let challengeImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 8
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.backgroundColor = .blue400
    return imageView
  }()
  
  private let challengeTitleLabel = {
    let label = UILabel()
    label.numberOfLines = 2
    
    label.attributedText = """
    산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책
    챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지산책
    챌린지산책 챌린지산책 챌린지산책 챌린지산책 챌린지
    """.attributedString(font: .body1, color: .white)
    
    label.textAlignment = .center
    label.lineBreakMode = .byTruncatingTail
    return label
  }()
  
  private let finishedDateLabel = {
    let label = UILabel()
    label.attributedText = "2024. 8. 30 종료".attributedString(font: .body1, color: .init(white: 1.0, alpha: 0.3))
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
    imageView.backgroundColor = .blue
    imageView.layer.cornerRadius = 12
    return imageView
  }()
  
  private let secondUserImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .orange
    imageView.layer.cornerRadius = 12
    return imageView
  }()
  
  private let moreUserImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .red
    imageView.layer.cornerRadius = 12
    return imageView
  }()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    addUserImageViews() // TODO: API연결시 삭제 예정입니다.
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
   fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure() {
    setupUI()
    addUserImageViews()
  }
}

// MARK: - UI Methods
private extension SearchCardOffTypeCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(whiteBackGroundView)
    
    whiteBackGroundView.addSubviews(challengeImageView,
                                    challengeTitleLabel,
                                    finishedDateLabel,
                                    bottomWhiteView)
    
    bottomWhiteView.addSubview(participantStackView)
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
    
    finishedDateLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(bottomWhiteView.snp.top).offset(-8)
    }
    
    challengeTitleLabel.snp.makeConstraints {
      $0.bottom.equalTo(finishedDateLabel.snp.top).offset(-10)
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
  }
  
  /// 참여자 수 에 따라 달라질 예정입니다.
  func addUserImageViews() {
    participantStackView.addArrangedSubview(firstUserImageView)
    participantStackView.addArrangedSubview(secondUserImageView)
    participantStackView.addArrangedSubview(moreUserImageView)
  }
}

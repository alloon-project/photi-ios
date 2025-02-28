//
//  FeedHistoryCell.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core
import DesignSystem

public final class FeedHistoryCell: UICollectionViewCell {
  // MARK: - Properties
  private(set) var model: FeedHistoryCellPresentationModel?
  
  // MARK: - UI Components
  private let whiteBackGroundView = {
    let view = UIView()
    view.backgroundColor = .gray200
    view.layer.cornerRadius = 8
    
    return view
  }()
  
  private let challengeImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 8
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }()
  
  private let finishedDateLabel = {
    let label = UILabel()
    label.attributedText = "2024. 8. 30 인증".attributedString(
      font: .caption1Bold,
      color: .init(white: 1.0, alpha: 0.6)
    )
    label.textAlignment = .center
    
    return label
  }()
  
  private let challengeTitleChip = TextChip(type: .line, size: .small)
  
  private let shareButton = {
    let button = UIButton()
    button.setImage(.shortcutGray700, for: .normal)
    
    return button
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
  func configure(with viewModel: FeedHistoryCellPresentationModel) {
    if let url = viewModel.challengeImageUrl {
      challengeImageView.kf.setImage(with: url)
    }
    
    finishedDateLabel.text = viewModel.provedDate
    challengeTitleChip.text = viewModel.challengeTitle
  }
}

// MARK: - UI Methods
private extension FeedHistoryCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(
      whiteBackGroundView,
      challengeTitleChip
    )
    
    whiteBackGroundView.addSubviews(
      challengeImageView,
      finishedDateLabel
    )
  }
  
  func setConstraints() {
    whiteBackGroundView.snp.makeConstraints {
      $0.left.top.trailing.equalToSuperview()
      $0.height.equalTo(158)
    }
    
    challengeImageView.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(2)
      $0.bottom.trailing.equalToSuperview().offset(-2)
    }
  }
}

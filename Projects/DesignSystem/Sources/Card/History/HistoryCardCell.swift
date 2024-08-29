//
//  HistoryCardCell.swift
//  DesignSystem
//
//  Created by wooseob on 8/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// 챌린지 히스토리를 보여주는 Cell 입니다.
public final class HistoryCardCell: UICollectionViewCell {
  // MARK: - UI Components
  private let backgroundClearView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.masksToBounds = true
    view.layer.maskedCorners = .layerMaxXMaxYCorner
    view.layer.cornerRadius = 26.675
    
    return view
  }()
  
  private let backgroundGrayView = {
    let view = UIView()
    view.backgroundColor = .gray200
    view.layer.masksToBounds = true
    view.layer.maskedCorners = [.layerMinXMinYCorner,
                                .layerMaxXMinYCorner,
                                .layerMinXMaxYCorner]
    view.layer.cornerRadius = 8.21
    
    return view
  }()
  
  private let thumbnailImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .orange
    imageView.clipsToBounds = true
    imageView.layer.masksToBounds = true
    imageView.layer.maskedCorners = [.layerMinXMinYCorner,
                                     .layerMaxXMinYCorner,
                                     .layerMinXMaxYCorner]
    imageView.layer.cornerRadius = 8.21
    return imageView
  }()
  
  private let authDateLabel = UILabel()
  
  private let roundedSmallView = {
    let view = UIView()
    view.backgroundColor = .gray200
    view.layer.maskedCorners =  [.layerMinXMinYCorner,
                                 .layerMaxXMinYCorner,
                                 .layerMinXMaxYCorner,
                                 .layerMaxXMaxYCorner]
    view.layer.cornerRadius = 4.4
    
    return view
  }()
  
  private let challangeNameChip = TextChip(text: "챌린지 이름", type: .line, size: .small)
  
  private let shareButton = {
    let button = UIButton()
    
    button.setImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
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
  
  // MARK: - Configure Method
  public func configure(
    challangeThumbnail: UIImage,
    authDate: Date,
    challangeName: String
  ) {
    thumbnailImageView.image = challangeThumbnail
    authDateLabel.text = authDate.toString()
    challangeNameChip.text = challangeName
  }
}

// MARK: - UI Methos
private extension HistoryCardCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.contentView.addSubviews(backgroundClearView,
                                 challangeNameChip,
                                 shareButton)
    
    backgroundClearView.addSubview(backgroundGrayView)
    
    backgroundGrayView.addSubviews(thumbnailImageView,
                                   roundedSmallView)
  }
  
  func setConstraints() {
    backgroundClearView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.height.equalTo(self.contentView.snp.width)
    }
    
    backgroundGrayView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    thumbnailImageView.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(3)
      $0.trailing.bottom.equalToSuperview().offset(-3)
    }
    
    roundedSmallView.snp.makeConstraints {
      $0.width.height.equalTo(22)
      $0.trailing.bottom.equalToSuperview().offset(-3)
    }
    
    challangeNameChip.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview()
    }
    
    shareButton.snp.makeConstraints {
      $0.trailing.bottom.equalToSuperview()
      $0.height.width.equalTo(18)
    }
  }
}

// MARK: - Private Methods
private extension HistoryCardCell {}

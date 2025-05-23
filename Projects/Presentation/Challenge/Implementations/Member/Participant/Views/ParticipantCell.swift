//
//  ParticipantCell.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core
import DesignSystem

final class ParticipantCell: UITableViewCell {
  // MARK: - UI Components
  private let containerView = UIView()
  private let userNameLabel = UILabel()
  private let durationLabel = UILabel()
  private let userProfileView = AvatarImageView(size: .medium)
  private let participantInfoUpperView = UIView()
  private let participantGoalView = ParticipantGoalView()
  
  private let participantStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    
    return stackView
  }()
  
  private let ownerBadge = Badge(mode: .line, size: .medium, text: "파티장")
  fileprivate let editButton = {
    let button = UIButton()
    button.setImage(.pencilGray700, for: .normal)
    return button
  }()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(with model: ParticipantPresentationModel) {
    userNameLabel.attributedText = model.name.attributedString(
      font: .body1Bold,
      color: .photiBlack
    )
    
    durationLabel.attributedText = model.duration.attributedString(
      font: .body2,
      color: .gray500
    )
    
    editButton.isHidden = !model.isSelf
    ownerBadge.isHidden = !model.isChallengeOwner

    participantGoalView.configure(goalText: model.goal)
  }
}

// MARK: - UI Methods
private extension ParticipantCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(containerView)
    containerView.addSubviews(
      userProfileView,
      participantStackView,
      participantGoalView,
      ownerBadge,
      editButton
    )
    participantInfoUpperView.addSubviews(userNameLabel, ownerBadge)
    participantStackView.addArrangedSubviews(participantInfoUpperView, durationLabel)
  }
  
  func setConstraints() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(20)
      $0.bottom.equalToSuperview().inset(16)
    }
    
    userProfileView.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
      $0.size.equalTo(userProfileView.intrinsicContentSize)
    }
    
    userNameLabel.snp.makeConstraints {
      $0.leading.centerY.equalToSuperview()
    }
    
    ownerBadge.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(userNameLabel.snp.trailing).offset(6)
    }
    
    editButton.snp.makeConstraints {
      $0.centerY.equalTo(userProfileView)
      $0.trailing.equalToSuperview().inset(3)
      $0.height.width.equalTo(18)
    }
    
    participantStackView.snp.makeConstraints {
      $0.leading.equalTo(userProfileView.snp.trailing).offset(14)
      $0.trailing.equalTo(editButton.snp.leading).inset(11)
    }
    
    participantGoalView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(54)
      $0.top.equalTo(participantStackView.snp.bottom).offset(8)
    }
  }
}

extension Reactive where Base: ParticipantCell {
  var didTapEditButton: ControlEvent<Void> {
    base.editButton.rx.tap
  }
}

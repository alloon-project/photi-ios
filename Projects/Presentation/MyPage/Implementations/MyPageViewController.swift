//
//  MyPageViewController.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

final class MyPageViewController: UIViewController {
  // MARK:- UIComponents
  
  // 사용자 정보 part
  private let userInfoView = {
    let view = UIView()
    view.backgroundColor = .blue500
    return view
  }()
  /// 하단 톱니모양뷰
  private let userInfoBottomImageView = {
    let pinkingView = UIImageView()
//    pinkingView.image = UIImage(resource: .pinking) TODO: - stencil 추가되면 수정
    return pinkingView
  }()
  private let userImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 48
    imageView.backgroundColor = .gray400
    imageView.clipsToBounds = true
    imageView.image = UIImage(systemName: "person.fill")
    return imageView
  }()
  private let settingButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "gearshape")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal) // TODO: - stencil 추가되면 setting으로 수정
    return button
  }()
  private let userNameLabel = {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.attributedText = "유저 아이디".attributedString(font: .heading1, color: .white, alignment: .center)
    return label
  }()
  
  private let authCountBox = {
    let view = UIView()
    view.backgroundColor = .blue400
    view.layer.cornerRadius = 8
    return view
  }()
  private let authCountLabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.attributedText = "인증 횟수".attributedString(font: .heading3, color: .white, alignment: .center)
    return label
  }()
  private let authCountValueLabel = {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.attributedText = "0".attributedString(font: .heading1, color: .white, alignment: .center)
    return label
  }()
  
  private let finishedChallengeCountBox = {
    let view = UIView()
    view.backgroundColor = .blue400
    view.layer.cornerRadius = 8
    return view
  }()
  private let finishedChallengeCountLabel = {
    let label = UILabel()
    label.attributedText = "종료된 챌린지".attributedString(font: .heading3, color: .white, alignment: .center)
    return label
  }()
  private let finishedChallengeCountValueLabel = {
    let label = UILabel()
    label.textColor = .white
    label.attributedText = "0".attributedString(font: .heading1, color: .white, alignment: .center)
    return label
  }()
  
  // 피드
  private let myFeedLabel = {
    let label = UILabel()
    label.textColor = .white
    label.attributedText = "내 피드".attributedString(font: .heading3, color: .gray900)
    return label
  }()
  private let calendarView = {
    let calendarView = CalendarView(startDate: Date())
    calendarView.isCloseButtonHidden = true
    return calendarView
  }()
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bind()
  }
}

// MARK: - Private methods
private extension MyPageViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  func bind() {
  }
  func setViewHierarchy() {
    self.view.addSubviews(userInfoView, userInfoBottomImageView, myFeedLabel, calendarView)
    userInfoView.addSubviews(userImageView, settingButton, userNameLabel, authCountBox, finishedChallengeCountBox)
    authCountBox.addSubviews(authCountLabel, authCountValueLabel)
    finishedChallengeCountBox.addSubviews(finishedChallengeCountLabel, finishedChallengeCountValueLabel)
  }
  
  func setConstraints() {
    userInfoView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.height.equalTo(388)
    }
    userInfoBottomImageView.snp.makeConstraints {
      $0.top.equalTo(userInfoView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(11)
    }
    settingButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
      $0.trailing.equalToSuperview().offset(-19)
      $0.width.height.equalTo(24)
    }
    userImageView.snp.makeConstraints {
      $0.top.equalTo(settingButton.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(96)
    }
    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(userImageView.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
    }
    authCountBox.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(userNameLabel.snp.bottom).offset(40)
      $0.trailing.equalTo(userNameLabel.snp.centerX).offset(-3.5)
      $0.bottom.equalToSuperview().offset(-31)
    }
    authCountLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(22)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
    }
    authCountValueLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
      $0.bottom.equalToSuperview().offset(-23)
    }
    finishedChallengeCountBox.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(authCountBox)
      $0.leading.equalTo(userNameLabel.snp.centerX).offset(3.5)
      $0.bottom.equalTo(authCountBox)
    }
    finishedChallengeCountLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.top.equalToSuperview().offset(22)
      $0.trailing.equalToSuperview().offset(-16)
    }
    finishedChallengeCountValueLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
      $0.bottom.equalToSuperview().offset(-23)
    }
    myFeedLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(userInfoBottomImageView).offset(32)
    }
    
    calendarView.snp.makeConstraints {
      $0.top.equalTo(myFeedLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-40)
    }
  }
}

// MARK: - CalendarView Delegate
extension MyPageViewController: CalendarViewDelegate {
  func didSelect(_ date: Date) {
    
  }
  
  func didTapCloseButton() {
    
  }
}

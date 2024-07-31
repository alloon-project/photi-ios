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
  // MARK: - UIComponents
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
    imageView.image = UIImage(systemName: "person.fill")?.resize(CGSize(width: 20, height: 20))
    return imageView
  }()
  
  private let settingButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "gearshape")?
      .withTintColor(.white, renderingMode: .alwaysOriginal)
      .resize(CGSize(width: 24, height: 24)),
                    for: .normal) // TODO: - stencil 추가되면 setting으로 수정
    return button
  }()
  
  private let userNameLabel = {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.attributedText = "유저 아이디".attributedString(font: .heading1,
                                                     color: .white,
                                                     alignment: .center)
    return label
  }()
  
  private let authCountBox = ChallengeCountBox(title: "인증 횟수", count: 0)
  
  private let finishedChallengeCountBox = ChallengeCountBox(title: "종료된 챌린지", count: 0)
  
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
    self.view.addSubviews(userInfoView, 
                          userInfoBottomImageView,
                          myFeedLabel,
                          calendarView)
    userInfoView.addSubviews(userImageView,
                             settingButton,
                             userNameLabel,
                             authCountBox,
                             finishedChallengeCountBox)
  }
  
  func setConstraints() {
    userInfoView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.height.greaterThanOrEqualTo(388)
    }
    
    userInfoBottomImageView.snp.makeConstraints {
      $0.top.equalTo(userInfoView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(11)
    }
    
    settingButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
      $0.trailing.equalToSuperview().offset(-19)
      $0.width.height.equalTo(32)
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
      $0.top.equalTo(userNameLabel.snp.bottom).offset(36)
      $0.trailing.equalTo(userNameLabel.snp.centerX).offset(-3.5)
      $0.bottom.equalToSuperview().offset(-31)
    }
    
    finishedChallengeCountBox.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(authCountBox)
      $0.leading.equalTo(userNameLabel.snp.centerX).offset(3.5)
      $0.bottom.equalTo(authCountBox)
    }
    
    myFeedLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(userInfoBottomImageView).offset(24)
    }
    
    calendarView.snp.makeConstraints {
      $0.top.equalTo(myFeedLabel.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-40)
    }
  }
}

// MARK: - CalendarView Delegate
extension MyPageViewController: CalendarViewDelegate {
  func didSelect(_ date: Date) { }
  
  func didTapCloseButton() { }
}

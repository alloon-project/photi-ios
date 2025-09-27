//
//  MyPageViewController.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Coordinator
import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class MyPageViewController: UIViewController, ViewControllerable {
  private let viewModel: MyPageViewModel
  private let disposeBag = DisposeBag()
  
  private let didTapDate = PublishRelay<Date>()
  
  // MARK: - UI Components
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.bounces = false
    scrollView.backgroundColor = .blue500
    
    return scrollView
  }()
  
  private let containerView = UIView()

  /// navigationBar
  private let navigationBar: UIView = {
    let view = UIView()
    return view
  }()
  
  private let settingButton: UIButton = {
    let button = UIButton()
    button.setImage(.settingsWhite, for: .normal)
    return button
  }()
  
  /// 상단 유저 정보
  private let userInfoView = UIView()
  private let profileImageView = AvatarImageView(size: .large)
  private let userNameLabel = UILabel()
  private let countBoxStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 7
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    
    return stackView
  }()
  private let feedsCountBox = ChallengeCountBox(title: "인증 횟수")
  private let endedChallengeCountBox = ChallengeCountBox(title: "종료된 챌린지")

  private let seperatorView: UIImageView = {
    let pinkingView = UIImageView(image: .pinkingBlueDown)
    pinkingView.contentMode = .topLeft
    
    return pinkingView
  }()
  
  /// 하단
  private let feedsInfoView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  private let myFeedLabel = {
    let label = UILabel()
    label.attributedText = "내 피드".attributedString(font: .heading3, color: .gray900)
    
    return label
  }()
  
  private let calendarView: CalendarView = {
    let calendarView = CalendarView(
      selectionMode: .multiple,
      startDate: Date(),
      currentDate: Date(),
      endDate: Date()
    )
    calendarView.isCloseButtonHidden = true
    
    return calendarView
  }()
  
  // MARK: - Initializers
  init(viewModel: MyPageViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LifeCycles
  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.delegate = self
    
    setupUI()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    showTabBar(animted: true)
  }
}

// MARK: - Private methods
private extension MyPageViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubview(scrollView)
    scrollView.addSubview(containerView)
    containerView.addSubviews(navigationBar, userInfoView, feedsInfoView, seperatorView)
    navigationBar.addSubview(settingButton)
    userInfoView.addSubviews(profileImageView, userNameLabel, countBoxStackView)
    countBoxStackView.addArrangedSubviews(feedsCountBox, endedChallengeCountBox)
    feedsInfoView.addSubviews(myFeedLabel, calendarView)
  }
  
  func setConstraints() {
    let tabBarMinY = tabBarController?.tabBar.frame.minY ?? 0
    let tabBarHeight = view.frame.height - tabBarMinY
    scrollView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(tabBarHeight)
    }
    
    containerView.snp.makeConstraints {
      $0.edges.width.equalToSuperview()
    }

    navigationBar.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(44)
    }
    
    userInfoView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom)
      $0.leading.trailing.equalToSuperview()
    }

    seperatorView.snp.makeConstraints {
      $0.top.equalTo(userInfoView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(12)
    }
    
    feedsInfoView.snp.makeConstraints {
      $0.top.equalTo(userInfoView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    setNavigationBarConstraints()
    setUserInfoViewConstraints()
    setFeedsInforViewConstraints()
  }
  
  func setNavigationBarConstraints() {
    settingButton.snp.makeConstraints {
      $0.width.height.equalTo(24)
      $0.trailing.equalToSuperview().inset(19)
      $0.centerY.equalToSuperview()
    }
  }
  
  func setUserInfoViewConstraints() {
    profileImageView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
    }
    
    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    countBoxStackView.snp.makeConstraints {
      $0.top.equalTo(userNameLabel.snp.bottom).offset(22)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(30)
      $0.height.equalTo(88)
    }
  }
  
  func setFeedsInforViewConstraints() {
    myFeedLabel.snp.makeConstraints {
      $0.top.equalTo(seperatorView).offset(40)
      $0.leading.equalToSuperview().offset(24)
    }
    
    calendarView.snp.makeConstraints {
      $0.top.equalTo(myFeedLabel.snp.bottom).offset(22)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(40)
    }
  }
}

// MARK: - Bind Methods
private extension MyPageViewController {
  func bind() {
    let input = MyPageViewModel.Input(
      didTapSettingButton: settingButton.rx.tap,
      didTapAuthCountBox: feedsCountBox.rx.didTapBox,
      didTapEndedChallengeBox: endedChallengeCountBox.rx.didTapBox,
      didBecomeVisible: rx.isVisible.filter { $0 }.map { _ in () }.asSignal(onErrorJustReturn: ()),
      didTapDate: didTapDate.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: MyPageViewModel.Output) {
    output.username
      .map { $0.attributedString(font: .heading1, color: .white, alignment: .center) }
      .drive(userNameLabel.rx.attributedText)
      .disposed(by: disposeBag)
    
    output.feedsCount
      .drive(feedsCountBox.rx.count)
      .disposed(by: disposeBag)
    
    output.endedChallengeCount
      .drive(endedChallengeCountBox.rx.count)
      .disposed(by: disposeBag)
    
    output.profileImageURL
      .drive(with: self) { owner, url in
        Task {
          let image = await owner.profileImage(with: url)
          owner.profileImageView.configureImage(image)
        }
      }
      .disposed(by: disposeBag)
    
    output.calendarStartDate
      .distinctUntilChanged()
      .drive(calendarView.rx.startDate)
      .disposed(by: disposeBag)
    
    output.verifiedChallengeDates
      .distinctUntilChanged()
      .drive(calendarView.rx.defaultSelectedDates)
      .disposed(by: disposeBag)
  }
}

// MARK: - MyPagePresentable
extension MyPageViewController: MyPagePresentable { }

// MARK: - CalendarViewDelegate
extension MyPageViewController: CalendarViewDelegate {
  func didSelect(_ date: Date) {
    didTapDate.accept(date)
  }
  
  func didTapCloseButton() { }
}

// MARK: - Private Methods
private extension MyPageViewController {
  func profileImage(with url: URL?) async -> UIImage? {
    guard let url = url else { return nil }
    
    return await withCheckedContinuation { continuation in
      KingfisherManager.shared.retrieveImage(with: url) { result in
        switch result {
        case .success(let value):
          continuation.resume(returning: value.image)
        case .failure:
          continuation.resume(returning: nil)
        }
      }
    }
  }
}

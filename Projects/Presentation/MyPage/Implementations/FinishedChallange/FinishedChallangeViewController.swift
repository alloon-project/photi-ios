//
//  FinishedChallengeViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class FinishedChallengeViewController: UIViewController {
  private let viewModel: FinishedChallengeViewModel
  
  // MARK: - Variables
  private var disposeBag = DisposeBag()
  
  // MARK: - UIComponents
  private let grayBackgroundView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  
  private let navigationBar = PrimaryNavigationView(
    textType: .none,
    iconType: .one,
    colorType: .dark
  )
  
  private let titleLabel = {
    let label = UILabel()
    label.attributedText = "총 0개의 챌린지가 종료됐어요".attributedString(
      font: .heading3,
      color: .gray900
    ).setColor(.orange400, for: "0")
    label.textAlignment = .center
    
    return label
  }()
  
  /// 하단 톱니모양뷰
  private let grayBottomImageView = {
    let pinkingView = UIImageView()
    pinkingView.image = .pinkingGray
    pinkingView.clipsToBounds = true
    
    return pinkingView
  }()
  
  private let finishedChallengeCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 12
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.contentInset = .init(top: 35, left: 24, bottom: 0, right: 24)
    collectionView.backgroundColor = .white
    collectionView.registerCell(FinishedChallengeCell.self)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: FinishedChallengeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    finishedChallengeCollectionView.delegate = self
    finishedChallengeCollectionView.dataSource = self
    setupUI()
    bind()
  }
}

// MARK: - UI methods
private extension FinishedChallengeViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      grayBackgroundView,
      finishedChallengeCollectionView,
      grayBottomImageView
    )
    
    grayBackgroundView.addSubviews(navigationBar, titleLabel)
  }
  
  func setConstraints() {
    grayBackgroundView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.height.equalTo(200)
    }
    
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(34)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
    }
    
    finishedChallengeCollectionView.snp.makeConstraints {
      $0.top.equalTo(grayBackgroundView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    grayBottomImageView.snp.makeConstraints {
      $0.top.equalTo(grayBackgroundView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(12)
    }
  }
}

// MARK: - Bind Method
private extension FinishedChallengeViewController {
  func bind() {
    let input = FinishedChallengeViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapLeftButton
    )
    
    let output = viewModel.transform(input: input)
  }
}
// MARK: - UICollectionViewDataSource
extension FinishedChallengeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(FinishedChallengeCell.self, for: indexPath)
    
    return cell
  }
}

extension FinishedChallengeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let widthOfCells = collectionView.bounds.width -
    (collectionView.contentInset.left + collectionView.contentInset.right)
    let width = (widthOfCells - 16) / 2.0
    
    return CGSize(width: width, height: 182.0)
  }
}

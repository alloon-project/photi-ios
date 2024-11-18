//
//  ProofChallengeViewController.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ProofChallengeViewController: UIViewController {
  private let viewModel: ProofChallengeViewModel
  
  // MARK: - Variables
  private let disposeBag = DisposeBag()
  
  // MARK: - UIComponents
  private let grayBackgroundView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)

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
  
  private let proofChallengeCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 12
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.contentInset = .init(
      top: 35,
      left: 24,
      bottom: 0,
      right: 24
    )
    collectionView.backgroundColor = .white
    collectionView.registerCell(ProofChallengeCell.self)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: ProofChallengeViewModel) {
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
    
    proofChallengeCollectionView.delegate = self
    proofChallengeCollectionView.dataSource = self
    setupUI()
    bind()
  }
}

// MARK: - UI methods
private extension ProofChallengeViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      grayBackgroundView,
      proofChallengeCollectionView,
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
    
    proofChallengeCollectionView.snp.makeConstraints {
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
private extension ProofChallengeViewController {
  func bind() {
    let input = ProofChallengeViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton
    )
    
    let output = viewModel.transform(input: input)
  }
}
// MARK: - UICollectionViewDataSource
extension ProofChallengeViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    10
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ProofChallengeCell.self, for: indexPath)
    
    return cell
  }
}

extension ProofChallengeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let widthOfCells = collectionView.bounds.width -
    (collectionView.contentInset.left + collectionView.contentInset.right)
    let width = (widthOfCells - 16) / 2.0
    
    return CGSize(width: width, height: 182.0)
  }
}

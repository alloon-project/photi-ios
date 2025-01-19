//
//  EndedChallengeViewController.swift
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

final class EndedChallengeViewController: UIViewController, ViewControllerable {
  private let viewModel: EndedChallengeViewModel
  
  // MARK: - Variables
  private var disposeBag = DisposeBag()
  private var dataSource: [EndedChallengeCardCellPresentationModel] = [] {
    didSet {
      endedChallengeCollectionView.reloadData()
    }
  }
  
  // MARK: - UIComponents
  private let grayBackgroundView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    displayMode: .dark
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
    pinkingView.image = .pinkingGrayDown
    pinkingView.contentMode = .topLeft
    
    return pinkingView
  }()
  
  private let endedChallengeCollectionView = {
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
    collectionView.registerCell(EndedChallengeCardCell.self)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: EndedChallengeViewModel) {
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
    
    endedChallengeCollectionView.delegate = self
    endedChallengeCollectionView.dataSource = self
    setupUI()
    bind()
  }
}

// MARK: - UI methods
private extension EndedChallengeViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      grayBackgroundView,
      endedChallengeCollectionView,
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
    
    endedChallengeCollectionView.snp.makeConstraints {
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
private extension EndedChallengeViewController {
  func bind() {
    let input = EndedChallengeViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      isVisible: self.rx.isVisible
    )
    
    let output = viewModel.transform(input: input)
    
    bind(for: output)
  }
  
  func bind(for output: EndedChallengeViewModel.Output) {
    output.endedChallenges
      .drive(with: self) { owner, challenges in
        owner.dataSource = challenges
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - EndedChallangePresentable
extension EndedChallengeViewController: EndedChallangePresentable { }
  
// MARK: - UICollectionViewDataSource
extension EndedChallengeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    dataSource.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(EndedChallengeCardCell.self, for: indexPath)
    
    cell.configure(with: dataSource[indexPath.row])
    return cell
  }
}

extension EndedChallengeViewController: UICollectionViewDelegateFlowLayout {
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

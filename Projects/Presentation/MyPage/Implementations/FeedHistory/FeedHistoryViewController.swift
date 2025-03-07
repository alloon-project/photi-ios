//
//  FeedHistoryViewController.swift
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

final class FeedHistoryViewController: UIViewController, ViewControllerable {
  private let viewModel: FeedHistoryViewModel
  
  // MARK: - Variables
  private let disposeBag = DisposeBag()
  private var dataSource: [FeedHistoryCellPresentationModel] = [] {
    didSet {
      feedHistoryCollectionView.reloadData()
    }
  }
  // MARK: - UIComponents
  private let grayBackgroundView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let titleLabel = {
    let label = UILabel()
    label.attributedText = "총 0회 인증했어요".attributedString(
      font: .heading3,
      color: .gray900
    ).setColor(.green400, for: "0")
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
  
  private let feedHistoryCollectionView = {
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
    collectionView.registerCell(FeedHistoryCell.self)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: FeedHistoryViewModel) {
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
    
    feedHistoryCollectionView.delegate = self
    feedHistoryCollectionView.dataSource = self
    setupUI()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - UI methods
private extension FeedHistoryViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      grayBackgroundView,
      feedHistoryCollectionView,
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
    
    feedHistoryCollectionView.snp.makeConstraints {
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
private extension FeedHistoryViewController {
  func bind() {
    let input = FeedHistoryViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      isVisible: self.rx.isVisible
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: FeedHistoryViewModel.Output) {
    output.feedHistory
      .drive(with: self) { owner, feeds in
        owner.dataSource = feeds
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - FeedHistoryPresentable
extension FeedHistoryViewController: FeedHistoryPresentable {
  func setMyFeedCount(_ count: Int) {
    titleLabel.attributedText = "총 \(count)회 인증했어요".attributedString(
      font: .heading3,
      color: .gray900
    ).setColor(.green400, for: "\(count)")
    titleLabel.textAlignment = .center
  }
}

// MARK: - UICollectionViewDataSource
extension FeedHistoryViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    dataSource.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(FeedHistoryCell.self, for: indexPath)
    
    cell.configure(with: dataSource[indexPath.row])
    return cell
  }
}

extension FeedHistoryViewController: UICollectionViewDelegateFlowLayout {
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

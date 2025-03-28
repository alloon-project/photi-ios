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
  typealias DataSourceType = UICollectionViewDiffableDataSource<Int, FeedHistoryCellPresentationModel>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Int, FeedHistoryCellPresentationModel>
  
  private let viewModel: FeedHistoryViewModel
  
  // MARK: - Variables
  private let disposeBag = DisposeBag()
  private var dataSource: DataSourceType?
  private var maxFeedsCount: Int = 0 // Presentable에서 초기화.
  private var currentPageRelay: BehaviorRelay<Int> = BehaviorRelay(value: 0)
  
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
    
    setFeedCollectionView()
    setupUI()
    bind()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

//MARK: - Private Methods
private extension FeedHistoryViewController {
  func setFeedCollectionView() {
    diffableDataSource()
    feedHistoryCollectionView.delegate = self
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
      isVisible: self.rx.isVisible,
      fetchMoreData: currentPageRelay.asObservable()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: FeedHistoryViewModel.Output) {
    output.feedHistory
      .drive(with: self) { owner, feeds in
        owner.append(models: feeds)
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for cell: FeedHistoryCell, model: FeedHistoryCellPresentationModel) {
    // TODO: ChallengeID값을 활용하여 해당 챌린지로 넘어가기.
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
    maxFeedsCount = count
  }
}

// MARK: - UICollectionView Diffable DataSource
extension FeedHistoryViewController {
  func diffableDataSource() {
    self.dataSource = .init(collectionView: feedHistoryCollectionView) { collectionView, indexPath, model in
      let cell = collectionView.dequeueCell(FeedHistoryCell.self, for: indexPath)
      cell.configure(with: model)
      
      return cell
    }
  }
  
  func append(models: [FeedHistoryCellPresentationModel]) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    
    // 섹션이 이미 존재하는지 확인
    DispatchQueue.main.async {
      if !snapshot.sectionIdentifiers.contains(0) {
          snapshot.appendSections([0]) // 최초 한 번만 추가
      }
      snapshot.appendItems(models, toSection: 0)
      dataSource.apply(snapshot)
    }
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
    
    return CGSize(width: width, height: 189.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let dataSource else { return }
    let snapshot = dataSource.snapshot()
    let count = snapshot.itemIdentifiers(inSection: 0).count
    
    if indexPath.item == count - 1 && count != maxFeedsCount {
      currentPageRelay.accept(count)
    }
  }
}

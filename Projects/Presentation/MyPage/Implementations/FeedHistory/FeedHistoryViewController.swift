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
  enum Constants {
    static let itemSpacing: CGFloat = 10
    static let groupSpacing: CGFloat = 16
  }
  
  typealias DataSourceType = UICollectionViewDiffableDataSource<Int, FeedHistoryCellPresentationModel>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Int, FeedHistoryCellPresentationModel>
  
  private let viewModel: FeedHistoryViewModel
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private var datasource: DataSourceType?

  private let requestData = PublishRelay<Void>()
  private let didTapFeed = PublishRelay<(challengeId: Int, feedId: Int)>()
  private let didTapShareButton = PublishRelay<(challengeId: Int, feedId: Int)>()

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let topView: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  private let titleLabel = UILabel()
  private let seperatorView: UIImageView = {
    let pinkingView = UIImageView(image: .pinkingGrayDown)
    pinkingView.contentMode = .topLeft
    
    return pinkingView
  }()
  private let feedHistoryCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.backgroundColor = .white
    collectionView.registerCell(FeedHistoryCell.self)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false

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
    
    configureFeedCollectionView()
    setupUI()
    bind()
    
    requestData.accept(())
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - Private Methods
private extension FeedHistoryViewController {
  func configureFeedCollectionView() {
    let datasource = diffableDataSource()
    self.datasource = datasource
    
    feedHistoryCollectionView.dataSource = datasource
    feedHistoryCollectionView.collectionViewLayout = compositionalLayout()
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
    view.addSubviews(topView, feedHistoryCollectionView, seperatorView)
    topView.addSubviews(navigationBar, titleLabel)
  }
  
  func setConstraints() {
    topView.snp.makeConstraints {
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
      $0.centerX.equalToSuperview()
    }
    
    seperatorView.snp.makeConstraints {
      $0.top.equalTo(topView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(12)
    }
    
    feedHistoryCollectionView.snp.makeConstraints {
      $0.top.equalTo(seperatorView.snp.bottom).offset(22)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
    }
  }
}

// MARK: - Bind Method
private extension FeedHistoryViewController {
  func bind() {
    let input = FeedHistoryViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapFeed: didTapFeed.asSignal(),
      didTapShareButton: didTapShareButton.asSignal(),
      requestData: requestData.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: FeedHistoryViewModel.Output) {
    output.feeds
      .drive(with: self) { owner, feeds in
        owner.append(models: feeds)
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for cell: FeedHistoryCell, model: FeedHistoryCellPresentationModel) {
    cell.rx.didTapShareButton
      .bind(with: self) { owner, _ in
        owner.didTapShareButton.accept((model.challengeId, model.feedId))
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - FeedHistoryPresentable
extension FeedHistoryViewController: FeedHistoryPresentable {
  func configureProvedFeedCount(_ count: Int) {
    titleLabel.attributedText = "총 \(count)회 인증했어요".attributedString(
      font: .heading3,
      color: .gray900
    ).setColor(.green400, for: "\(count)")
    titleLabel.textAlignment = .center
  }
}

// MARK: - UICollectionView Diffable DataSource
extension FeedHistoryViewController {
  func diffableDataSource() -> DataSourceType {
    return .init(collectionView: feedHistoryCollectionView) { [weak self] collectionView, indexPath, model in
      let cell = collectionView.dequeueCell(FeedHistoryCell.self, for: indexPath)
      cell.configure(with: model)
      self?.bind(for: cell, model: model)
      return cell
    }
  }
  
  func append(models: [FeedHistoryCellPresentationModel]) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    
    if !snapshot.sectionIdentifiers.contains(0) {
      snapshot.appendSections([0])
    }
    snapshot.appendItems(models)
    
    datasource.apply(snapshot)
  }
}

// MARK: - UICollectionViewLayout
private extension FeedHistoryViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, environment in
      let itemSpacing = Constants.itemSpacing

      let availableWidth = environment.container.effectiveContentSize.width
      let itemWidth = (availableWidth - itemSpacing) / 2
      let itemHeight = itemWidth * 1.195
      
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .absolute(itemWidth),
        heightDimension: .absolute(itemHeight)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(itemHeight)
      )
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
      group.interItemSpacing = .fixed(itemSpacing)
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets.bottom = 40
      section.interGroupSpacing = Constants.groupSpacing
      
      return section
    }
  }
}

// MARK: - UICollectionViewDelegate
extension FeedHistoryViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    
    guard yOffset > (scrollView.contentSize.height - scrollView.bounds.size.height) else { return }
    
    requestData.accept(())
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = datasource?.itemIdentifier(for: indexPath) else { return }
    didTapFeed.accept((item.challengeId, item.feedId))
  }
}

//
//  RecentChallengesViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class RecentChallengesViewController: UIViewController, ViewControllerable {
  fileprivate enum Constants {
    static let itemSpacing: CGFloat = 11
  }
  
  typealias DataSourceType = UICollectionViewDiffableDataSource<Int, ChallengeCardPresentationModel>
  typealias SnapShot = NSDiffableDataSourceSnapshot<Int, ChallengeCardPresentationModel>
  
  // MARK: - Properties
  private let viewModel: RecentChallengesViewModel
  private let disposeBag = DisposeBag()
  private var datasource: DataSourceType?
  
  private let requestData = PublishRelay<Void>()
  private let didTapChallenge = PublishRelay<Int>()
  
  // MARK: - UI Components
  private let challengeCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.registerCell(ChallengeCardCell.self)
    collectionView.registerHeader(RecentChallengeSectionHeader.self)
    collectionView.backgroundColor = .clear
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = .init(top: 24, left: 0, bottom: 40, right: 0)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false

    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: RecentChallengesViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
    challengeCollectionView.collectionViewLayout = compositionalLayout()
    let datasource = diffableDatasource()
    self.datasource = datasource
    datasource.supplementaryViewProvider = supplementaryViewProvider()
    challengeCollectionView.dataSource = datasource
    challengeCollectionView.delegate = self
    
    requestData.accept(())
  }
}

// MARK: - UI Methods
private extension RecentChallengesViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubview(challengeCollectionView)
  }
  
  func setConstraints() {
    challengeCollectionView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(24)
    }
  }
}

// MARK: - Bind Methods
private extension RecentChallengesViewController {
  func bind() {
    let input = RecentChallengesViewModel.Input(
      requestData: requestData.asSignal(),
      didTapChallenge: didTapChallenge.asSignal()
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: RecentChallengesViewModel.Output) {
    output.initialChallenges
      .drive(with: self) { owner, challengs in
        owner.initialize(with: challengs)
      }
      .disposed(by: disposeBag)
    
    output.challenges
      .drive(with: self) { owner, challengs in
        owner.append(models: challengs)
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - RecentChallengesPresentable
extension RecentChallengesViewController: RecentChallengesPresentable { }

// MARK: - UICollectionViewLayout
private extension RecentChallengesViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, environment in
      let itemSpacing = Constants.itemSpacing
      let availableWidth = environment.container.effectiveContentSize.width
      let itemWidth = (availableWidth - itemSpacing) / 2
      let itemHeight = itemWidth * 1.265
      
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
      section.interGroupSpacing = itemSpacing
      section.contentInsets.top = 20
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: .init(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      header.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
      section.boundarySupplementaryItems = [header]
      return section
    }
  }
}

// MARK: - UICollectionViewDataSource
private extension RecentChallengesViewController {
  func diffableDatasource() -> DataSourceType {
    return .init(collectionView: challengeCollectionView) { collectionView, indexPath, model in
      let cell = collectionView.dequeueCell(ChallengeCardCell.self, for: indexPath)
      cell.configure(with: model)
      return cell
    }
  }
  
  func supplementaryViewProvider() -> DataSourceType.SupplementaryViewProvider? {
    return .init { collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else { return nil }
      let headerView = collectionView.dequeueHeader(RecentChallengeSectionHeader.self, for: indexPath)
      headerView.frame = .init(origin: .zero, size: .init(width: 200, height: 24))
      return headerView
    }
  }
  
  func initialize(with models: [ChallengeCardPresentationModel]) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    snapshot.deleteAllItems()
    
    snapshot = append(models: models, to: snapshot)
    datasource.apply(snapshot)
  }
  
  func append(models: [ChallengeCardPresentationModel]) {
    guard let datasource else { return }
    let snapshot = append(models: models, to: datasource.snapshot())
    datasource.apply(snapshot)
  }
  
  func append(models: [ChallengeCardPresentationModel], to snapshot: SnapShot) -> SnapShot {
    var snapshot = snapshot
    if !snapshot.sectionIdentifiers.contains(0) {
      snapshot.appendSections([0])
    }
    models.forEach { snapshot.appendItems([$0]) }
    
    return snapshot
  }
}

// MARK: - UICollectionViewDelegate
extension RecentChallengesViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    
    guard yOffset > (scrollView.contentSize.height - scrollView.bounds.size.height) else { return }
    
    requestData.accept(())
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = datasource?.itemIdentifier(for: indexPath) else { return }
    didTapChallenge.accept(item.id)
  }
}

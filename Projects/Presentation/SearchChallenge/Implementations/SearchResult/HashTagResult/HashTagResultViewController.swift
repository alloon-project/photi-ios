//
//  HashTagResultViewController.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class HashTagResultViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let itemSpacing: CGFloat = 11
    static let groupSpacing: CGFloat = 16
    static let horizontalContentInset: CGFloat = 24
    static let hashTagCollectionViewHeight: CGFloat = 25
  }
  
  typealias DataSourceType = UICollectionViewDiffableDataSource<Int, ResultChallengeCardPresentationModel>
  typealias SnapShot = NSDiffableDataSourceSnapshot<Int, ResultChallengeCardPresentationModel>
  
  // MARK: - Properties
  private let viewModel: HashTagResultViewModel
  private let disposeBag = DisposeBag()
  private var datasource: DataSourceType?
  
  private let requestData = PublishRelay<Void>()
  private let didTapChallenge = PublishRelay<Int>()
  
  // MARK: - UI Components
  private let emptyResultLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "해당 챌린지가 없어요.".attributedString(font: .body2, color: .gray400)
    
    return label
  }()
  
  private let challengeCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.registerCell(HashTagResultCardCell.self)
    collectionView.backgroundColor = .clear
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false

    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: HashTagResultViewModel) {
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
    challengeCollectionView.dataSource = datasource
    challengeCollectionView.delegate = self
  }
}

// MARK: - UI Methods
private extension HashTagResultViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(emptyResultLabel, challengeCollectionView)
  }
  
  func setConstraints() {
    challengeCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    emptyResultLabel.snp.makeConstraints { $0.center.equalToSuperview() }
  }
}

// MARK: - Bind Methods
private extension HashTagResultViewController {
  func bind() {
    let input = HashTagResultViewModel.Input(
      requestData: requestData.asSignal(),
      didTapChallenge: didTapChallenge.asSignal()
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: HashTagResultViewModel.Output) {
    output.initialChallenges
      .drive(with: self) { owner, challenges in
        owner.initialize(with: challenges)
        owner.emptyResultLabel.isHidden = !challenges.isEmpty
      }
      .disposed(by: disposeBag)
    
    output.challenges
      .drive(with: self) { owner, challenges in
        owner.append(models: challenges)
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - HashTagResultPresentable
extension HashTagResultViewController: HashTagResultPresentable { }

// MARK: - UICollectionViewLayout
private extension HashTagResultViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, environment in
      let itemSpacing = Constants.itemSpacing
      let horizontalInset = Constants.horizontalContentInset
      
      let availableWidth = environment.container.effectiveContentSize.width
      let itemWidth = ((availableWidth - horizontalInset * 2) - itemSpacing) / 2
      let itemHeight = itemWidth * 1.15 + Constants.hashTagCollectionViewHeight + 8
      
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
      section.contentInsets = .init(
        top: horizontalInset,
        leading: horizontalInset,
        bottom: 40,
        trailing: horizontalInset
      )
      section.interGroupSpacing = Constants.groupSpacing
      
      return section
    }
  }
}

// MARK: - UICollectionViewDataSource
private extension HashTagResultViewController {
  func diffableDatasource() -> DataSourceType {
    return .init(collectionView: challengeCollectionView) { collectionView, indexPath, model in
      let cell = collectionView.dequeueCell(HashTagResultCardCell.self, for: indexPath)
      cell.configure(with: model)
      return cell
    }
  }
  
  func initialize(with models: [ResultChallengeCardPresentationModel]) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    snapshot.deleteAllItems()
    
    snapshot = append(models: models, to: snapshot)
    datasource.apply(snapshot)
  }
  
  func append(models: [ResultChallengeCardPresentationModel]) {
    guard let datasource else { return }
    let snapshot = append(models: models, to: datasource.snapshot())
    datasource.apply(snapshot)
  }
  
  func append(models: [ResultChallengeCardPresentationModel], to snapshot: SnapShot) -> SnapShot {
    var snapshot = snapshot
    if !snapshot.sectionIdentifiers.contains(0) {
      snapshot.appendSections([0])
    }
    models.forEach { snapshot.appendItems([$0]) }
    
    return snapshot
  }
}

// MARK: - UICollectionViewDelegate
extension HashTagResultViewController: UICollectionViewDelegate {
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

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
  enum Constants {
    static let itemSpacing: CGFloat = 11
    static let groupSpacing: CGFloat = 16
    static let horizontalContentInset: CGFloat = 24
  }
  
  typealias DataSourceType = UICollectionViewDiffableDataSource<Int, EndedChallengeCardPresentationModel>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Int, EndedChallengeCardPresentationModel>
  
  // MARK: - Properties
  private let viewModel: EndedChallengeViewModel
  private let disposeBag = DisposeBag()
  private var datasource: DataSourceType?
  
  private let requestData = PublishRelay<Void>()
  private let didTapChallenge = PublishRelay<Int>()
  
  // MARK: - UIComponents
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
  
  private let endedChallengeCollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.backgroundColor = .white
    collectionView.registerCell(EndedChallengeCardCell.self)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    
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
    
    configureCollectionView()
    setupUI()
    bind()
    
    requestData.accept(())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - UI methods
private extension EndedChallengeViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func configureCollectionView() {
    let datasource = diffableDataSource()
    self.datasource = datasource
    
    endedChallengeCollectionView.dataSource = datasource
    endedChallengeCollectionView.collectionViewLayout = compositionalLayout()
    endedChallengeCollectionView.delegate = self
  }
  
  func setViewHierarchy() {
    view.addSubviews(topView, endedChallengeCollectionView, seperatorView)
    topView.addSubviews(navigationBar, titleLabel)
    
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
    
    endedChallengeCollectionView.snp.makeConstraints {
      $0.top.equalTo(seperatorView.snp.bottom).offset(22)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
}

// MARK: - Bind Method
private extension EndedChallengeViewController {
  func bind() {
    let input = EndedChallengeViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      requestData: requestData.asSignal(),
      didTapChallenge: didTapChallenge.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    
    bind(for: output)
  }
  
  func bind(for output: EndedChallengeViewModel.Output) {
    output.endedChallenges
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

// MARK: - EndedChallangePresentable
extension EndedChallengeViewController: EndedChallangePresentable {
  func configureEndedChallengeCount(_ count: Int) {
    titleLabel.attributedText = "총 \(count)개의 챌린지가 종료됐어요".attributedString(
      font: .heading3,
      color: .gray900
    ).setColor(.orange400, for: "\(count)")
  }
}

// MARK: - UICollectionViewDataSource
private extension EndedChallengeViewController {
  func diffableDataSource() -> DataSourceType {
    return .init(collectionView: endedChallengeCollectionView) { collectionView, indexPath, model in
      let cell = collectionView.dequeueCell(EndedChallengeCardCell.self, for: indexPath)
      cell.configure(with: model)
      return cell
    }
  }
  
  func append(models: [EndedChallengeCardPresentationModel]) {
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
private extension EndedChallengeViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, environment in
      let itemSpacing = Constants.itemSpacing
      let horizontalInset = Constants.horizontalContentInset
      
      let availableWidth = environment.container.effectiveContentSize.width
      let itemWidth = ((availableWidth - horizontalInset * 2) - itemSpacing) / 2
      let itemHeight = itemWidth * 1.15
      
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
        top: 0,
        leading: horizontalInset,
        bottom: 40,
        trailing: horizontalInset
      )
      section.interGroupSpacing = Constants.groupSpacing
      
      return section
    }
  }
}

// MARK: - UICollectionViewDelegate
extension EndedChallengeViewController: UICollectionViewDelegate {
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

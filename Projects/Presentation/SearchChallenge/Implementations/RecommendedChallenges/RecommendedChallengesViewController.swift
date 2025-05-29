//
//  RecommendedChallengesViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class RecommendedChallengesViewController: UIViewController, ViewControllerable {
  typealias DataSourceType = UITableViewDiffableDataSource<Int, ChallengeCardPresentationModel>
  typealias SnapShot = NSDiffableDataSourceSnapshot<Int, ChallengeCardPresentationModel>
  
  // MARK: - Properties
  private let viewModel: RecommendedChallengesViewModel
  private let disposeBag = DisposeBag()
  private var datasource: DataSourceType?
  private var hashTagIsSticky = false {
    didSet {
      guard hashTagIsSticky != oldValue else { return }
      hashTagIsSticky ? stickHashTagView() : unStickHashTagView()
      popularHashTagView.isSticky = hashTagIsSticky
    }
  }
  
  private let requestData = PublishRelay<Void>()
  private let requestHashTagChallenge = PublishRelay<Void>()
  private let didSelectHashTag = PublishRelay<String>()
  private let didTapChallenge = PublishRelay<Int>()
  
  private var popularChallenges = [ChallengeCardPresentationModel]() {
    didSet { popularChallengesCollectionView.reloadData() }
  }
  
  private let hashTagChallenges = [ChallengeCardPresentationModel]()
  
  // MARK: - UI Components
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let popularChallengesHeaderView = SearchChallengeHeaderView(
    image: .fireGray700,
    title: "지금 인기 있는 챌린지"
  )
  private let popularChallengesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    layout.itemSize = .init(width: 150, height: 200)
    layout.minimumInteritemSpacing = 12
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(ChallengeCardCell.self)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()
  private let dashLineView = DashLineView(lineDashPattern: [4, 4], lineColor: .gray400)
  private let dummyView = UIView()
  private let hashTagHeaderView = SearchChallengeHeaderView(
    image: .rocketGray700,
    title: "해시태그 모아보기"
  )
  private let popularHashTagPlaceholder = UIView()
  private let popularHashTagView = HashTagView()
  private let hashtagChallengeTableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView()
    tableView.sectionFooterHeight = 20
    tableView.registerCell(HashTagChallengeCell.self)
    tableView.rowHeight = 160
    tableView.separatorStyle = .none
    
    return tableView
  }()
  
  // MARK: - Initializers
  init(viewModel: RecommendedChallengesViewModel) {
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
    scrollView.delegate = self
    popularChallengesCollectionView.dataSource = self
    popularChallengesCollectionView.delegate = self
    
    let hashTagDataSource = diffableDatasource()
    datasource = hashTagDataSource
    hashtagChallengeTableView.dataSource = hashTagDataSource
    hashtagChallengeTableView.delegate = self
    
    requestData.accept(())
  }
}

// MARK: - UI Methods
private extension RecommendedChallengesViewController {
  func setupUI() {
    view.backgroundColor = .white
    scrollView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubviews(popularChallengesHeaderView, popularChallengesCollectionView, dashLineView)
    contentView.addSubviews(hashTagHeaderView, popularHashTagPlaceholder, hashtagChallengeTableView)
    view.addSubview(popularHashTagView)
  }
  
  func setConstraints() {
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints {
      $0.edges.width.equalToSuperview()
    }
    
    popularChallengesHeaderView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(24)
    }

    popularChallengesCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(popularChallengesHeaderView.snp.bottom).offset(20)
      $0.height.equalTo(200)
    }
    
    dashLineView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(popularChallengesCollectionView.snp.bottom).offset(32)
    }
    
    hashTagHeaderView.snp.makeConstraints {
      $0.top.equalTo(dashLineView.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    popularHashTagPlaceholder.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(hashTagHeaderView.snp.bottom)
      $0.height.equalTo(64)
    }
    
    popularHashTagView.snp.makeConstraints {
      $0.edges.equalTo(popularHashTagPlaceholder)
    }
        
    hashtagChallengeTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
      $0.top.equalTo(dashLineView.snp.bottom).offset(120)
    }
  }
}

// MARK: - Bind Methods
private extension RecommendedChallengesViewController {
  func bind() {
    let input = RecommendedChallengesViewModel.Input(
      requestData: requestData.asSignal(),
      requestHashTagChallenge: requestHashTagChallenge.asSignal(),
      didSelectHashTag: didSelectHashTag.asSignal(),
      didTapChallenge: didTapChallenge.asSignal()
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() {
    popularHashTagView.rx.didSelectHasTag
      .skip(1)
      .bind(to: didSelectHashTag)
      .disposed(by: disposeBag)
  }
  
  func viewModelBind(for output: RecommendedChallengesViewModel.Output) {
    output.popularChallenges
      .drive(rx.popularChallenges)
      .disposed(by: disposeBag)
    
    output.hashTags
      .drive(popularHashTagView.rx.hashTags)
      .disposed(by: disposeBag)
    
    output.hashTagInitialChallenges
      .drive(with: self) { owner, models in
        owner.initialize(with: models)
      }
      .disposed(by: disposeBag)
    
    output.hashTagChallenges
      .drive(with: self) { owner, models in
        owner.append(models: models)
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - RecommendedChallengesPresentable
extension RecommendedChallengesViewController: RecommendedChallengesPresentable { }

// MARK: - UIScrollViewDelegate
extension RecommendedChallengesViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let placeholderFrame = popularHashTagPlaceholder.convert(popularHashTagPlaceholder.bounds, to: view)
    hashTagIsSticky = placeholderFrame.minY <= 0
    
    let yOffset = scrollView.contentOffset.y
    
    guard yOffset > (scrollView.contentSize.height - scrollView.bounds.size.height) else { return }
    
    requestHashTagChallenge.accept(())
  }
}

// MARK: - UICollectionViewDataSource
extension RecommendedChallengesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    popularChallenges.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ChallengeCardCell.self, for: indexPath)
    cell.configure(with: popularChallenges[indexPath.row])
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension RecommendedChallengesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = popularChallenges[indexPath.row]
    didTapChallenge.accept(item.id)
  }
}

// MARK: - UITableViewDataSource
extension RecommendedChallengesViewController {
  func diffableDatasource() -> DataSourceType {
    return .init(tableView: hashtagChallengeTableView) { tableView, indexPath, model in
      let cell = tableView.dequeueCell(HashTagChallengeCell.self, for: indexPath)
      cell.configure(with: model)
      return cell
    }
  }
 
  func initialize(with models: [ChallengeCardPresentationModel]) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    snapshot.deleteAllItems()

    snapshot = append(models: models, to: snapshot)
    datasource.apply(snapshot) { [weak self] in
      self?.scrollToTopHashTagChallenges()
    }
  }
  
  func append(models: [ChallengeCardPresentationModel]) {
    guard let datasource else { return }
    let snapshot = append(models: models, to: datasource.snapshot())
    datasource.apply(snapshot)
  }
  
  func append(models: [ChallengeCardPresentationModel], to snapshot: SnapShot) -> SnapShot {
    var snapshot = snapshot
    models.forEach {
      guard !snapshot.sectionIdentifiers.contains($0.id) else { return }
      snapshot.appendSections([$0.id])
      snapshot.appendItems([$0], toSection: $0.id)
    }
    
    return snapshot
  }
}

// MARK: - UITableViewDelegate
extension RecommendedChallengesViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let item = datasource?.itemIdentifier(for: indexPath) else { return }
    didTapChallenge.accept(item.id)
  }
}

// MARK: - Private Methods
private extension RecommendedChallengesViewController {
  func stickHashTagView() {
    popularHashTagView.snp.remakeConstraints {
      $0.leading.trailing.height.equalTo(popularHashTagPlaceholder)
      $0.top.equalToSuperview()
    }
  }
  
  func unStickHashTagView() {
    popularHashTagView.snp.remakeConstraints {
      $0.edges.equalTo(popularHashTagPlaceholder)
    }
  }
  
  func scrollToTopHashTagChallenges() {
    guard hashTagIsSticky else { return }

    let hashtagTableViewPosition = hashtagChallengeTableView.convert(hashtagChallengeTableView.bounds, to: scrollView)
    let contentYPosition = hashtagTableViewPosition.minY - popularHashTagView.frame.height
    scrollView.setContentOffset(CGPoint(x: 0, y: contentYPosition), animated: true)
  }
}

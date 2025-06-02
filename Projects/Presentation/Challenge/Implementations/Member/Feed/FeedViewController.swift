//
//  FeedViewController.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class FeedViewController: UIViewController, ViewControllerable, CameraRequestable {
  enum Constants {
    static let feedSpacing = 7.0
    static let feedLineSpacing = 10.0
    static let feedHeaderHeight = 44.0
    static let feedFooterHeight = 6.0
  }
  
  typealias DataSourceType = UICollectionViewDiffableDataSource<String, FeedPresentationModel>
  typealias SnapShot = NSDiffableDataSourceSnapshot<String, FeedPresentationModel>

  // MARK: - Properties
  private let viewModel: FeedViewModel
  private let disposeBag = DisposeBag()

  private var currentPercent = PhotiProgressPercent.percent0 {
    didSet {
      guard viewDidAppear else { return }
      progressBar.percent = currentPercent
      updateTagViewContraints(percent: currentPercent)
    }
  }
  private var isProve: ProveType = .didNotProve("") {
    didSet {
      guard viewWillAppear else { return }
      if currentPercent == .percent100 {
        cameraShutterButton.isHidden = true
        cameraView.isHidden = true
        return
      }
      configureTodayHeaderView(for: isProve)
      cameraShutterButton.isHidden = (isProve == .didProve)
      cameraView.isHidden = (isProve == .didProve)
      
      if viewDidAppear, isProve != .didProve { presentPoofTipView() }
    }
  }
  private var feedsAlign: FeedsAlignMode = .recent {
    didSet { orderButton.text = feedsAlign.rawValue }
  }
  private var dataSource: DataSourceType?
  private var viewWillAppear: Bool = false
  private var viewDidAppear: Bool = false

  private let requestData = PublishRelay<Void>()
  private let reloadData = PublishRelay<Void>()
  private let didTapFeedCell = PublishRelay<Int>()
  private let contentOffset = PublishRelay<Double>()
  private let uploadImageRelay = PublishRelay<UIImageWrapper>()
  private let requestFeeds = PublishRelay<Void>()
  private let feedsAlignRelay = BehaviorRelay<FeedsAlignMode>(value: .recent)
  private let didTapLikeButtonRelay = PublishRelay<(Bool, Int)>()
  
  // MARK: - UI Components
  private let progressBar = MediumProgressBar(percent: .percent0)
  private let orderButton = IconTextButton(text: "최신순", icon: .chevronDownGray700, size: .xSmall)
  private let tagView = TagView(image: .peopleWhite)
  private let emptyFeedsImageView = UIImageView(image: .challengeEmptyFeed)
  private let feedCollectionView: SelfVerticalSizingCollectionView = {
    let collectionView = SelfVerticalSizingCollectionView(layout: UICollectionViewLayout())
    collectionView.registerCell(FeedCell.self)
    collectionView.registerHeader(FeedsHeaderView.self)
    collectionView.registerFooter(FeedsLoadingFooterView.self)
    collectionView.backgroundColor = .clear
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    
    return collectionView
  }()
  private let cameraView = FeedCameraGradientView()
  private let cameraShutterButton: UIButton = {
    let button = UIButton()
    button.setImage(.shutterWhite, for: .normal)
    
    return button
  }()
  
  // MARK: - Initializers
  init(viewModel: FeedViewModel) {
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
    let dataSource = diffableDataSource()
    self.dataSource = dataSource
    feedCollectionView.dataSource = dataSource
    feedCollectionView.collectionViewLayout = compositionalLayout()
    dataSource.supplementaryViewProvider = supplementaryViewProvider()
    feedCollectionView.delegate = self
    configureRefreshControl()
    requestData.accept(())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard !viewWillAppear else { return }
    self.viewWillAppear = true
    if case let .didNotProve(time) = isProve, time.isEmpty { return }
    
    if currentPercent == .percent100 {
      cameraShutterButton.isHidden = true
      cameraView.isHidden = true
    }
    
    cameraShutterButton.isHidden = (isProve == .didProve)
    cameraView.isHidden = (isProve == .didProve)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard !viewDidAppear else { return }
    self.viewDidAppear = true
    progressBar.percent = currentPercent
    updateTagViewContraints(percent: currentPercent)
    if isProve != .didProve && currentPercent != .percent100 { presentPoofTipView() }
  }
}

// MARK: - UI Methods
private extension FeedViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      progressBar,
      orderButton,
      feedCollectionView,
      cameraView,
      emptyFeedsImageView,
      tagView,
      cameraShutterButton
    )
  }
  
  func setConstraints() {
    progressBar.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.trailing.equalTo(orderButton.snp.leading).offset(-21)
      $0.height.equalTo(6)
      $0.top.equalToSuperview().offset(24)
    }
    
    orderButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalTo(progressBar)
    }
    
    tagView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(progressBar.snp.bottom).offset(8)
    }
    
    feedCollectionView.snp.makeConstraints {
      $0.top.equalTo(orderButton.snp.bottom).offset(30)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
    }

    cameraView.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
      $0.height.equalTo(161)
    }

    cameraShutterButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(64)
      $0.bottom.equalToSuperview().inset(22)
    }
    
    emptyFeedsImageView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(23)
      $0.top.equalToSuperview().offset(74)
    }
  }
}

// MARK: - Bind
private extension FeedViewController {
  func bind() {
    let input = FeedViewModel.Input(
      requestData: requestData.asSignal(),
      reloadData: reloadData.asSignal(),
      didTapFeed: didTapFeedCell.asSignal(),
      contentOffset: contentOffset.asSignal(),
      uploadImage: uploadImageRelay.asSignal(),
      requestFeeds: requestFeeds.asSignal(),
      feedsAlign: feedsAlignRelay.asDriver(),
      didTapIsLikeButton: didTapLikeButtonRelay.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func bind(for output: FeedViewModel.Output) {
    output.proveMemberCount
      .drive(with: self) { owner, count in
        switch count {
          case .default(let count):
            owner.tagView.title = "오늘 \(count)명 인증!"
          case .ended:
            owner.tagView.title = "챌린지 완료!"
        }
      }
      .disposed(by: disposeBag)
    
    output.provePercent
      .drive(with: self) { owner, progress in
        owner.configureProgressBar(for: progress)
      }
      .disposed(by: disposeBag)
    
    output.proofRelay
      .distinctUntilChanged { $0 == $1 }
      .drive(rx.isProve)
      .disposed(by: disposeBag)
    
    output.proveFeed
      .drive(with: self) { owner, feed in
        owner.appendFront(models: feed)
      }
      .disposed(by: disposeBag)
    
    output.feeds
      .drive(with: self) { owner, feeds in
        owner.feedCollectionView.refreshControl?.endRefreshing()
        owner.emptyFeedsImageView.isHidden = (feeds != .empty)
        if feeds == .empty { owner.cameraView.isHidden = true }
        switch feeds {
          case let .initialPage(models):
            owner.initialize(models: models)
          case let .default(models):
            owner.append(models: models)
          default: break
        }
      }
      .disposed(by: disposeBag)
    
    output.isUploadSuccess
      .emit(with: self) { owner, _ in
        LoadingAnimation.logo.stop()
        owner.isProve = .didProve
      }
      .disposed(by: disposeBag)
  }
  
  func bindFailed(for output: FeedViewModel.Output) {
    output.fileTooLarge
      .emit(with: self) { owner, _ in
        owner.presentFileTooLargeAlert()
      }
      .disposed(by: disposeBag)
    
    output.startFetching
      .emit(with: self) { owner, _ in
        owner.updateFeedsFooterLoadingState(isFetching: true)
      }
      .disposed(by: disposeBag)
    
    output.stopFetching
      .emit(with: self) { owner, _ in
        owner.updateFeedsFooterLoadingState(isFetching: false)
      }
      .disposed(by: disposeBag)
  }

  func viewBind() {
    orderButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.presentBottomSheet()
      }
      .disposed(by: disposeBag)
    
    cameraShutterButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.requestOpenCamera(delegate: owner)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(cell: FeedCell) {
    cell.rx.didTapLikeButton
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .bind(with: self) { owner, result in
        owner.didTapLikeButtonRelay.accept(result)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - FeedPresentable
extension FeedViewController: FeedPresentable {
  func deleteFeed(feedId: Int) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    
    guard let model = snapshot.itemIdentifiers.first(where: { $0.id == feedId }) else { return }
    
    if
      let section = snapshot.sectionIdentifier(containingItem: model),
      snapshot.numberOfItems(inSection: section) == 1 {
      snapshot.deleteSections([section])
    }
    
    snapshot.deleteItems([model])
    dataSource.apply(snapshot)
  }
  
  func updateLikeState(feedId: Int, isLiked: Bool) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    
    guard
      let oldItem = snapshot.itemIdentifiers.first(where: { $0.id == feedId }),
      oldItem.isLike != isLiked
    else { return }
    
    var updatedItem = oldItem
    updatedItem.isLike = isLiked
    
    snapshot.insertItems([updatedItem], afterItem: oldItem)
    snapshot.deleteItems([oldItem])
    
    dataSource.apply(snapshot)
  }
}

// MARK: - UICollectionViewDiffableDataSource
extension FeedViewController {
  func diffableDataSource() -> DataSourceType {
    return .init(collectionView: feedCollectionView) { [weak self] collectionView, indexPath, model in
      let cell = collectionView.dequeueCell(FeedCell.self, for: indexPath)
      cell.configure(with: model)
      self?.bind(cell: cell)
      return cell
    }
  }
  
  func supplementaryViewProvider() -> DataSourceType.SupplementaryViewProvider? {
    return .init { [weak self] collectionView, kind, indexPath in
      if kind == UICollectionView.elementKindSectionHeader {
        return self?.supplementaryHeaderView(collectionView, at: indexPath)
      } else if kind == UICollectionView.elementKindSectionFooter {
        return self?.supplementaryFooterView(collectionView, at: indexPath)
      } else {
        return nil
      }
    }
  }
  
  func supplementaryHeaderView(_ collectionView: UICollectionView, at indexPath: IndexPath) -> FeedsHeaderView? {
    let headerView = collectionView.dequeueHeader(FeedsHeaderView.self, for: indexPath)
    guard let sectionData = dataSource?.sectionIdentifier(for: indexPath.section) else {
      return headerView
    }
    if indexPath.section == 0, sectionData == "오늘" {
      switch isProve {
        case let .didNotProve(proveTime):
          headerView.configure(date: sectionData, type: .didNotProve(proveTime))
        case .didProve:
          headerView.configure(date: sectionData, type: .didProve)
      }
    } else {
      headerView.configure(date: sectionData)
    }
    
    return headerView
  }
  
  func supplementaryFooterView(_ collectionView: UICollectionView, at indexPath: IndexPath) -> FeedsLoadingFooterView? {
    let footerView = collectionView.dequeueFooter(FeedsLoadingFooterView.self, for: indexPath)
    footerView.isHidden = true
    
    return footerView
  }
  
  func configureTodayHeaderView(for type: ProveType) {
    let indexPath = IndexPath(row: 0, section: 0)
    guard
      let headerView = feedCollectionView.headerView(FeedsHeaderView.self, at: indexPath),
      let sectionData = dataSource?.sectionIdentifier(for: 0),
      sectionData == "오늘"
    else { return }

    switch type {
      case let .didNotProve(proveTime):
        headerView.configure(type: .didNotProve(proveTime))
      case .didProve:
        headerView.configure(type: .didProve)
    }
  }
  
  func initialize(models: [FeedPresentationModel]) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    snapshot.deleteAllItems()
    
    snapshot = append(models: models, to: snapshot)
    dataSource.apply(snapshot)
  }
  
  func appendFront(models: [FeedPresentationModel]) {
    guard let dataSource, let firstModel = models.first else { return }
    var snapshot = dataSource.snapshot()
    
    let updateGroup = firstModel.updateGroup
    
    if !snapshot.sectionIdentifiers.contains(updateGroup) {
      if let firstSection = snapshot.sectionIdentifiers.first {
        snapshot.insertSections([updateGroup], beforeSection: firstSection)
      } else {
        snapshot.appendSections([updateGroup])
      }
    }
    
    if let firstItem = snapshot.itemIdentifiers(inSection: firstModel.updateGroup).first {
      snapshot.insertItems(models, beforeItem: firstItem)
    } else {
      snapshot.appendItems(models, toSection: firstModel.updateGroup)
    }
    
    dataSource.apply(snapshot)
  }
  
  func append(models: [FeedPresentationModel]) {
    guard let dataSource else { return }
    let snapshot = append(models: models, to: dataSource.snapshot())
    dataSource.apply(snapshot)
  }
  
  func append(models: [FeedPresentationModel], to snapshot: SnapShot) -> SnapShot {
    var snapshot = snapshot
    models.forEach {
      if !snapshot.sectionIdentifiers.contains($0.updateGroup) {
        snapshot.appendSections([$0.updateGroup])
        snapshot.appendItems([$0], toSection: $0.updateGroup)
      }
      snapshot.appendItems([$0], toSection: $0.updateGroup)
    }
    
    return snapshot
  }
  
  func deleteAllFeeds() {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    
    snapshot.deleteAllItems()
    dataSource.apply(snapshot)
  }
}

// MARK: - UICollectionViewDelegate
extension FeedViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
    didTapFeedCell.accept(item.id)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    contentOffset.accept(yOffset)
    
    guard yOffset > (scrollView.contentSize.height - scrollView.bounds.size.height) else { return }
   
    requestFeeds.accept(())
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension FeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      picker.dismiss(animated: true)
      return
    }
    picker.dismiss(animated: true)
    
    let popOver = UploadPhotoPopOverViewController(type: .two, image: image)
    popOver.present(to: self, animated: true)
    popOver.delegate = self
  }
}

// MARK: - UploadPhotoPopOverDelegate
extension FeedViewController: UploadPhotoPopOverDelegate {
  func upload(_ popOver: UploadPhotoPopOverViewController, image: UIImage) {
    uploadImageRelay.accept(.init(image: image))
    LoadingAnimation.logo.start()
  }
}

// MARK: - AlignBottomSheetDelegate
extension FeedViewController: AlignBottomSheetDelegate {
  func didSelected(at index: Int, data: String) {
    self.feedsAlign = .init(rawValue: data) ?? feedsAlign
    feedsAlignRelay.accept(feedsAlign)
    deleteAllFeeds()
  }
}

// MARK: - Private Methods
private extension FeedViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, environment in
      let itemSpacing = Constants.feedSpacing
      let availableWidth = environment.container.effectiveContentSize.width
      let itemWidth = (availableWidth - itemSpacing) / 2
      
      let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemWidth))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemWidth))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
      group.interItemSpacing = .fixed(itemSpacing)
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 10
      section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 18, trailing: 0)
      
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(Constants.feedHeaderHeight)
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      header.pinToVisibleBounds = true
      
      let footerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(Constants.feedFooterHeight)
      )
      let footer = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: footerSize,
        elementKind: UICollectionView.elementKindSectionFooter,
        alignment: .bottom
      )

      section.boundarySupplementaryItems = [header, footer]
      return section
    }
  }
  
  func configureRefreshControl() {
    feedCollectionView.refreshControl = UIRefreshControl()
    feedCollectionView.refreshControl?.addTarget(self, action: #selector(refreshStart), for: .valueChanged)
  }
  
  @objc func refreshStart() {
    reloadData.accept(())
  }
  
  func updateTagViewContraints(percent: PhotiProgressPercent) {
    let tagViewLeading = tagViewLeading(for: percent.rawValue)

    UIView.animate(withDuration: 0.4) {
      self.tagView.snp.updateConstraints {
        $0.leading.equalToSuperview().offset(tagViewLeading)
      }
      self.view.layoutIfNeeded()
    }
  }
  
  func tagViewLeading(for progess: Double) -> Double {
    let centerX = progressBar.bounds.width * progess
    let leading: Double = centerX - tagView.frame.width / 2.0

    return leading.bound(lower: 24, upper: progressBar.bounds.width - tagView.frame.width)
  }
  
  func presentPoofTipView() {
    let tipView = ToastView(
      tipPosition: .centerBottom,
      text: "오늘의 인증이 완료되지 않았어요!",
      icon: .bulbWhite
    )
    
    tipView.setConstraints { [weak self] make in
      guard let self else { return }
      make.bottom.equalTo(cameraShutterButton.snp.top).offset(-6)
      make.centerX.equalToSuperview()
    }
    
    tipView.present(to: self)
  }
  
  func presentBottomSheet() {
    let dataSource = FeedsAlignMode.allCases.map { $0.rawValue }
    let selectedRow = dataSource.firstIndex(of: feedsAlign.rawValue)
    
    let bottomSheet = AlignBottomSheetViewController(
      type: .default,
      selectedRow: selectedRow ?? 0,
      dataSource: dataSource
    )
    bottomSheet.delegate = self
    bottomSheet.present(to: self, animated: true)
  }
  
  func presentAlreadyVerifyFeedAlert() {
    let alert = AlertViewController(alertType: .confirm, title: "이미 인증한 챌린지입니다.")
    
    alert.present(to: self, animted: true)
  }
  
  func presentFileTooLargeAlert() {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "파일 용량이 너무 큽니다.",
      subTitle: "파일 용량은 8MB이하여야 합니다."
    )
    
    alert.present(to: self, animted: true)
  }
  
  func updateFeedsFooterLoadingState(isFetching: Bool) {
    guard let dataSource else { return }
    
    let lastSection = dataSource.numberOfSections(in: feedCollectionView) - 1
    let lastIndexPath = IndexPath(row: 0, section: lastSection)
    let loadingView = feedCollectionView.footerView(FeedsLoadingFooterView.self, at: lastIndexPath)

    loadingView?.isHidden = !isFetching
    isFetching ? loadingView?.startLoading() : loadingView?.stopLoading()
    
    if !isFetching, lastSection > 0 {
      (0..<lastSection).map { IndexPath(row: 0, section: $0) }.forEach {
        let loadingView = feedCollectionView.footerView(FeedsLoadingFooterView.self, at: $0)
        loadingView?.isHidden = true
        loadingView?.stopLoading()
      }
    }
  }
  
  func configureProgressBar(for progress: ProgressType) {
    progressBar.progressTintColor = progress == .ended ? .orange400 : .green400
    tagView.backgroundColor = progress == .ended ? .orange400 : .green400
    
    switch progress {
      case .ended:
        currentPercent = .percent100
      case let .default(percent):
        currentPercent = .init(percent)
    }
  }
}

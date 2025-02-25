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
  private var isProof: ProveType = .didNotProof("") {
    didSet {
      guard viewWillAppear else { return }
      configureTodayHeaderView(for: isProof)
      cameraShutterButton.isHidden = (isProof != .didProof)
    }
  }
  private var feedsAlign: FeedsAlignMode = .recent {
    didSet { orderButton.text = feedsAlign.rawValue }
  }
  private var dataSource: DataSourceType?
  private var viewWillAppear: Bool = false
  private var viewDidAppear: Bool = false

  private let viewDidLoadRelay = PublishRelay<Void>()
  private let didTapFeedCell = PublishRelay<String>()
  private let contentOffset = PublishRelay<Double>()
  private let uploadImageRelay = PublishRelay<Data>()
  private let requestFeeds = PublishRelay<Void>()
  private let feedsAlignRelay = BehaviorRelay<FeedsAlignMode>(value: .recent)
  private let didTapLikeButtonRelay = PublishRelay<(Bool, Int)>()
  
  // MARK: - UI Components
  private let progressBar = MediumProgressBar(percent: .percent0)
  private let orderButton = IconTextButton(text: "최신순", icon: .chevronDownGray700, size: .xSmall)
  private let tagView = TagView(image: .peopleWhite)
  private let feedCollectionView: SelfVerticalSizingCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 7
    layout.headerReferenceSize = .init(width: 0, height: 44)
    layout.footerReferenceSize = .init(width: 0, height: 6)
    layout.sectionInset = .init(top: 8, left: 0, bottom: 18, right: 0)
    layout.itemSize = .init(width: 160, height: 160)
    layout.sectionHeadersPinToVisibleBounds = true
    
    let collectionView = SelfVerticalSizingCollectionView(layout: layout)
    collectionView.registerCell(FeedCell.self)
    collectionView.registerHeader(FeedsHeaderView.self)
    collectionView.registerFooter(FeedsLoadingFooterView.self)
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    
    return collectionView
  }()
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
    dataSource.supplementaryViewProvider = supplementaryViewProvider()
    feedCollectionView.delegate = self
    
    viewDidLoadRelay.accept(())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard !viewWillAppear else { return }
    self.viewWillAppear = true
    configureTodayHeaderView(for: isProof)
    cameraShutterButton.isHidden = (isProof == .didProof)
    if isProof != .didProof { presentPoofTipView() }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard !viewDidAppear else { return }
    self.viewDidAppear = true
    progressBar.percent = currentPercent
    updateTagViewContraints(percent: currentPercent)
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
      $0.centerX.bottom.equalToSuperview()
      $0.width.equalTo(327)
    }

    cameraShutterButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(64)
      $0.bottom.equalToSuperview().inset(22)
    }
  }
}

// MARK: - Bind
private extension FeedViewController {
  func bind() {
    let input = FeedViewModel.Input(
      viewDidLoad: viewDidLoadRelay.asSignal(),
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
      .map { "오늘 \($0)명 인증!" }
      .drive(tagView.rx.title)
      .disposed(by: disposeBag)
    
    output.provePercent
      .map { PhotiProgressPercent($0) }
      .drive(rx.currentPercent)
      .disposed(by: disposeBag)
    
    output.proofRelay
      .distinctUntilChanged { $0 == $1 }
      .drive(rx.isProof)
      .disposed(by: disposeBag)
    
    output.feeds
      .drive(with: self) { owner, feeds in
        switch feeds {
          case let .initialPage(models):
            owner.initialize(models: models)
          case let .default(models):
            owner.append(models: models)
        }
      }
      .disposed(by: disposeBag)
    
    output.isUploadSuccess
      .emit(with: self) { owner, _ in
        LoadingAnimation.default.stop()
        owner.isProof = .didProof
        owner.cameraShutterButton.isHidden = true
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
extension FeedViewController: FeedPresentable { }

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
    headerView.configure(date: sectionData)
    
    return headerView
  }
  
  func supplementaryFooterView(_ collectionView: UICollectionView, at indexPath: IndexPath) -> FeedsLoadingFooterView? {
    let footerView = collectionView.dequeueFooter(FeedsLoadingFooterView.self, for: indexPath)
    footerView.isHidden = true
    
    return footerView
  }
  
  func configureTodayHeaderView(for type: ProveType) {
    let indexPath = IndexPath(row: 0, section: 0)
    guard let headerView = feedCollectionView.headerView(FeedsHeaderView.self, at: indexPath) else { return }
    
    switch type {
      case let .didNotProof(proveTime):
        headerView.configure(type: .didNotProof(proveTime))
      case .didProof:
        headerView.configure(type: .didProof)
    }
  }
  
  func initialize(models: [FeedPresentationModel]) {
    let snapshot = append(models: models, to: SnapShot())
    dataSource?.apply(snapshot)
  }
  
  func append(models: [FeedPresentationModel]) {
    guard let dataSource else { return }
    let snapshot = append(models: models, to: dataSource.snapshot())
    dataSource.apply(snapshot)
  }
  
  func append(models: [FeedPresentationModel], to snapshot: SnapShot) -> SnapShot {
    var snapshot = snapshot
    models.forEach {
      if !snapshot.sectionIdentifiers.contains($0.updateTime) {
        snapshot.appendSections([$0.updateTime])
      }
      snapshot.appendItems([$0], toSection: $0.updateTime)
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
    // TODO: API 연결 후 수정
    didTapFeedCell.accept("0")
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
    uploadImageRelay.accept(image.pngData() ?? Data())
    LoadingAnimation.default.start()
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
}

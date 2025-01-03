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

final class FeedViewController: UIViewController, CameraRequestable {
  // MARK: - Properties
  private var currentPercent = PhotiProgressPercent.percent0 {
    didSet {
      progressBar.percent = currentPercent
      updateTagViewContraints(percent: currentPercent)
    }
  }
  private var feedAlign: FeedAlignMode = .recent
  private var isProof: Bool = false
  private let viewModel: FeedViewModel
  private let disposeBag = DisposeBag()
  private var didProof: Bool = false
  private var feeds = [[FeedPresentationModel]]() {
    didSet {
      feedCollectionView.reloadData()
    }
  }
  private let didTapFeedCell = PublishRelay<String>()
  private let uploadImageRelay = PublishRelay<Data>()
  
  // MARK: - UI Components
  private let progressBar = MediumProgressBar(percent: .percent0)
  private let orderButton = IconTextButton(text: "최신순", icon: .chevronDownGray700, size: .xSmall)
  private let tagView = TagView(image: .peopleWhite)
  private let feedCollectionView: SelfVerticalSizingCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 7
    layout.itemSize = .init(width: 160, height: 160)
    layout.sectionHeadersPinToVisibleBounds = true
    
    let collectionView = SelfVerticalSizingCollectionView(layout: layout)
    collectionView.registerCell(FeedCell.self)
    collectionView.registerHeader(FeedCollectionHeaderView.self)
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
    feedCollectionView.dataSource = self
    feedCollectionView.delegate = self
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    cameraShutterButton.isHidden = isProof
    guard !isProof else { return }
    presentPoofTipView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      self.currentPercent = .percent40
    }
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
      $0.centerX.equalToSuperview()
      $0.width.equalTo(327)
      $0.bottom.equalToSuperview()
    }
    
    cameraShutterButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(64)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
    }
  }
}

// MARK: - Bind
private extension FeedViewController {
  func bind() {
    let input = FeedViewModel.Input(
      didTapOrderButton: orderButton.rx.tap
        .asSignal()
        .map { .popular },
      didTapFeed: didTapFeedCell.asSignal(),
      uploadImage: uploadImageRelay.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func bind(for output: FeedViewModel.Output) {
    output.isUploadSuccess
      .emit(with: self) { owner, _ in
        LoadingAnimation.default.stop()
        owner.isProof = true
        owner.cameraShutterButton.isHidden = true
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
}

// MARK: - UICollectionViewDataSource
extension FeedViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return feeds.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return feeds[section].count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(FeedCell.self, for: indexPath)
    cell.configure(with: feeds[indexPath.section][indexPath.row])
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard  kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
      
    let header = collectionView.dequeueHeader(FeedCollectionHeaderView.self, for: indexPath)
    
    /// 테스트용 코드입니다.
    if indexPath.section == 0 {
      header.configure(date: "오늘", type: .didNotProof(deadLine: "18:00까지"))
    } else {
      header.configure(date: "1일 전", type: .none)
    }
    
    return header
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int
  ) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 44)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return .init(top: 8, left: 0, bottom: 18, right: 0)
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
  func didSeleted(at index: Int, data: String) {
    self.feedAlign = .init(rawValue: data) ?? feedAlign
    orderButton.text = feedAlign.rawValue
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
    let dataSource = FeedAlignMode.allCases.map { $0.rawValue }
    let selectedRow = dataSource.firstIndex(of: feedAlign.rawValue)
    
    let bottomSheet = AlignBottomSheetViewController(
      type: .default,
      selectedRow: selectedRow ?? 0,
      dataSource: dataSource
    )
    bottomSheet.delegate = self
    bottomSheet.present(to: self, animated: true)
  }
}

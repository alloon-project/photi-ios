//
//  FeedDetailViewController.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import Kingfisher
import SnapKit
import CoreUI
import DesignSystem

final class FeedCommentViewController: UIViewController, ViewControllerable {
  typealias DataSourceType = UITableViewDiffableDataSource<String, FeedCommentPresentationModel>
  typealias Snapshot = NSDiffableDataSourceSnapshot<String, FeedCommentPresentationModel>

  // MARK: - Properties
  var keyboardShowNotification: NSObjectProtocol?
  var keyboardHideNotification: NSObjectProtocol?
  private var dropDownOptions = [String]()
  private let viewModel: FeedCommentViewModel
  private var cancellables = Set<AnyCancellable>()
  private var dataSource: DataSourceType?

  private let requestCommentsSubject = PassthroughSubject<Void, Never>()
  private let requestDataSubject = PassthroughSubject<Void, Never>()
  private let requestDeleteCommentSubject = PassthroughSubject<Int, Never>()
  private let uploadCommentSubject = PassthroughSubject<String, Never>()
  private let didTapShareButtonSubject = PassthroughSubject<Void, Never>()
  private let didTapDeleteFeedButtonSubject = PassthroughSubject<Void, Never>()
  private let didTapReportButtonSubject = PassthroughSubject<Void, Never>()
  private let didTapBackgroundSubject = PassthroughSubject<Void, Never>()

  // MARK: - UI Components
  private let blurView: UIView = {
    let view = UIView()
    view.layer.compositingFilter = "multiplyBlendMode"
    view.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4)

    return view
  }()
  private let mainContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    view.layer.masksToBounds = true

    return view
  }()
  private let imageView = UIImageView()
  private let topView = FeedCommentTopView()
  private let bottomView = UIView()
  private let bottomGradientLayer: GradientLayer = {
    let color = UIColor(red: 0.118, green: 0.137, blue: 0.149, alpha: 0.8)
    return .init(mode: .bottomToTop, maxColor: color)
  }()

  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.registerCell(FeedCommentCell.self)
    tableView.backgroundColor = .clear
    tableView.rowHeight = UITableView.automaticDimension
    tableView.sectionHeaderHeight = 12
    tableView.sectionHeaderTopPadding = 0

    return tableView
  }()
  private let commentTextField = FeedCommentTextField()
  private lazy var dropDownView = DropDownView(anchorView: topView.optionButton)

  // MARK: - Initializers
  init(viewModel: FeedCommentViewModel) {
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

    let dataSource = diffableDataSource()
    self.dataSource = dataSource
    tableView.dataSource = dataSource
    tableView.delegate = self
    configureRefreshControl()
    setupUI()
    setupTapGesture()
    bind()

    requestDataSubject.send(())
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    keyboardShowNotification = registerKeyboardShowNotification()
    keyboardHideNotification = registerKeyboardHideNotification()
  }

  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    mainContainerView.layoutIfNeeded()
    bottomGradientLayer.frame = bottomView.bounds

    presentWithAnimation()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification(keyboardShowNotification, keyboardHideNotification)

    guard let coordinator = transitionCoordinator else { return }
    keepAliveBlurView()
    coordinator.animateAlongsideTransition(in: self.view, animation: nil) { _ in
      self.blurView.removeFromSuperview()
    }
  }

  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension FeedCommentViewController {
  func setupUI() {
    imageView.contentMode = .scaleAspectFill
    setViewHierarchy()
    setConstraints()
  }

  func setViewHierarchy() {
    view.addSubviews(blurView, mainContainerView)
    mainContainerView.addSubviews(imageView, topView, bottomView)
    bottomView.layer.addSublayer(bottomGradientLayer)
    bottomView.addSubviews(tableView, commentTextField)
  }

  func setConstraints() {
    blurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    mainContainerView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(327)
      $0.height.equalTo(558)
    }

    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    topView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(80)
    }

    bottomView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(279)
    }

    tableView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.leading.trailing.equalToSuperview().inset(18)
      $0.height.equalTo(170)
    }

    commentTextField.snp.makeConstraints {
      $0.top.equalTo(tableView.snp.bottom).offset(18)
      $0.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview().inset(18)
    }
  }

  func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBlurView))
    blurView.addGestureRecognizer(tapGesture)
  }

  @objc func didTapBlurView() {
    didTapBackgroundSubject.send(())
  }
}

// MARK: - Bind Methods
private extension FeedCommentViewController {
  func bind() {
    let didTapLikeButton = topView.didTapLikeButton
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)

    let input = FeedCommentViewModel.Input(
      didTapBackground: didTapBackgroundSubject.eraseToAnyPublisher(),
      requestComments: requestCommentsSubject.eraseToAnyPublisher(),
      requestData: requestDataSubject.eraseToAnyPublisher(),
      didTapLikeButton: didTapLikeButton.eraseToAnyPublisher(),
      didTapDeleteButton: didTapDeleteFeedButtonSubject.eraseToAnyPublisher(),
      didTapReportButton: didTapReportButtonSubject.eraseToAnyPublisher(),
      requestDeleteComment: requestDeleteCommentSubject.eraseToAnyPublisher(),
      requestUploadComment: uploadCommentSubject.eraseToAnyPublisher()
    )
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }

  func viewBind() {
    commentTextField.didBeginInitialEditing
      .sinkOnMain(with: self) { owner, _ in
        owner.presentToastView()
      }
      .store(in: &cancellables)

    commentTextField.didTapReturn
      .sinkOnMain(with: self) { owner, _ in
        owner.didTapReturnButton()
      }
      .store(in: &cancellables)

    topView.didTapOptionButton
      .sinkOnMain(with: self) { owner, _ in
        owner.configureDropDown()
      }
      .store(in: &cancellables)
  }

  func bind(for output: FeedCommentViewModel.Output) {
    bindFeedInfo(for: output)
    bindRequestFailed(for: output)

    output.comments
      .dropFirst()
      .sinkOnMain(with: self) { owner, commentPage in
        switch commentPage {
          case let .initialPage(comments):
            owner.initialize(models: comments)
          case let .default(comments):
            owner.appendToFront(models: comments)
        }
      }
      .store(in: &cancellables)

    output.stopLoadingAnimation
      .sinkOnMain(with: self) { owner, _ in
        owner.tableView.refreshControl?.endRefreshing()
        owner.scrollToBottom()
      }
      .store(in: &cancellables)

    output.comment
      .sinkOnMain(with: self) { owner, model in
        owner.append(model: model)
      }
      .store(in: &cancellables)

    didTapShareButtonSubject
      .withLatestFrom(output.instagramStoryInformation)
      .sinkOnMain(with: self) { owner, info in
        Task { await owner.openInstagramToShareStory(url: info.0, challengeName: info.1) }
      }
      .store(in: &cancellables)

    output.deleteComment
      .sinkOnMain(with: self) { owner, id in
        owner.delete(commentId: id)
      }
      .store(in: &cancellables)

    output.uploadCommentSuccess
      .sinkOnMain(with: self) { owner, result in
        owner.update(commentId: result.1, for: result.0)
      }
      .store(in: &cancellables)
  }

  func bindFeedInfo(for output: FeedCommentViewModel.Output) {
    output.feedImageURL
      .compactMap { $0 }
      .sinkOnMain(with: self) { owner, url in
        owner.imageView.kf.setImage(with: url)
      }
      .store(in: &cancellables)

    output.author
      .sinkOnMain(with: self) { owner, author in
        owner.topView.author = author
      }
      .store(in: &cancellables)

    output.updateTime
      .sinkOnMain(with: self) { owner, updateTime in
        owner.topView.updateTime = updateTime
      }
      .store(in: &cancellables)

    output.likeCount
      .sinkOnMain(with: self) { owner, likeCount in
        owner.topView.likeCount = likeCount
      }
      .store(in: &cancellables)

    output.isLike
      .sinkOnMain(with: self) { owner, isLike in
        owner.topView.isLike = isLike
      }
      .store(in: &cancellables)

    output.dropDownOptions
      .sinkOnMain(with: self) { owner, options in
        owner.dropDownOptions = options
      }
      .store(in: &cancellables)
  }

  func bindRequestFailed(for output: FeedCommentViewModel.Output) {
    output.uploadCommentFailed
      .sinkOnMain(with: self) { owner, id in
        owner.delete(modelId: id)
      }
      .store(in: &cancellables)
  }

  func bind(for cell: FeedCommentCell) {
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    cell.addGestureRecognizer(longPressGesture)
  }

  @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    guard let cell = gesture.view as? FeedCommentCell, cell.id != -1 else { return }

    switch gesture.state {
      case .began:
        cell.isPressed = true
      case .failed, .cancelled:
        cell.isPressed = false
      case .ended:
        requestDeleteCommentSubject.send(cell.id)
      default: break
    }
  }
}

// MARK: - FeedCommentPresentable
extension FeedCommentViewController: FeedCommentPresentable { }

// MARK: - UITableViewDelegate
extension FeedCommentViewController: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    setupBoundaryCellAlpha()
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .clear
    if section == 0 { view.isHidden = true }
    return view
  }
}

// MARK: - KeyboardListener
extension FeedCommentViewController: KeyboardListener {
  func keyboardWillShow(keyboardHeight: CGFloat) {
    let remainPlace = view.frame.height - mainContainerView.frame.maxY
    self.bottomView.transform = CGAffineTransform(
      translationX: 0,
      y: remainPlace - keyboardHeight
    )
  }

  func keyboardWillHide() {
    self.bottomView.transform = .identity
  }
}

// MARK: - TableView DataSource
private extension FeedCommentViewController {
  func diffableDataSource() -> DataSourceType {
    return .init(tableView: tableView) { [weak self] tableView, indexPath, model in
      let cell = tableView.dequeueCell(FeedCommentCell.self, for: indexPath)
      cell.configure(model: model)
      if model.isOwner { self?.bind(for: cell) }

      return cell
    }
  }

  func appendToFront(models: [FeedCommentPresentationModel]) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()

    guard let minSection = snapshot.sectionIdentifiers.min() else { return append(models: models) }

    let sections = models.map { $0.id }
    snapshot.insertSections(sections, beforeSection: minSection)

    models.forEach { model in
      snapshot.appendItems([model], toSection: model.id)
    }

    dataSource.apply(snapshot)
  }

  func initialize(models: [FeedCommentPresentationModel]) {
    let snapshot = append(models: models, snapshot: Snapshot())
    dataSource?.apply(snapshot) { [weak self] in
      self?.scrollToBottom()
    }
  }

  func append(models: [FeedCommentPresentationModel]) {
    guard let dataSource else { return }
    let snapshot = append(models: models, snapshot: dataSource.snapshot())
    dataSource.apply(snapshot) { [weak self] in
      self?.scrollToBottom()
    }
  }

  func append(model: FeedCommentPresentationModel) {
    guard let dataSource else { return }
    commentTextField.text = ""
    let snapshot = append(model: model, snapshot: dataSource.snapshot())
    dataSource.apply(snapshot) { [weak self] in
      self?.scrollToBottom { [weak self] in
        self?.presentDeleteToastView()
      }
    }
  }

  func append(model: FeedCommentPresentationModel, snapshot: Snapshot) -> Snapshot {
    var snapshot = snapshot
    snapshot.appendSections([model.id])
    snapshot.appendItems([model], toSection: model.id)
    return snapshot
  }

  func append(models: [FeedCommentPresentationModel], snapshot: Snapshot) -> Snapshot {
    var snapshot = snapshot
    let sections = models.map { $0.id }

    snapshot.appendSections(sections)
    models.forEach { model in
      snapshot.appendItems([model], toSection: model.id)
    }

    return snapshot
  }

  func update(commentId: Int, for modelId: String) {
    guard let dataSource else { return }

    var snapshot = dataSource.snapshot()

    guard let index = snapshot.itemIdentifiers.firstIndex(where: { $0.id == modelId }) else { return }

    let existingModel = snapshot.itemIdentifiers[index]
    var updatedModel = existingModel
    updatedModel.commentId = commentId

    snapshot.deleteItems([existingModel])
    snapshot.appendItems([updatedModel], toSection: modelId)
    dataSource.apply(snapshot, animatingDifferences: false)
  }

  func delete(commentId: Int) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    guard let index = snapshot.itemIdentifiers.firstIndex(where: { $0.commentId == commentId }) else { return }
    let model = snapshot.itemIdentifiers[index]

    snapshot.deleteSections([model.id])
    dataSource.apply(snapshot) { [weak self] in
      guard snapshot.itemIdentifiers.count <= 3 else { return }
      self?.scrollToBottom()
    }
  }

  func delete(modelId: String) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    guard let model = snapshot.itemIdentifiers.first(where: { $0.id == modelId }) else { return }
    snapshot.deleteSections([model.id])
    dataSource.apply(snapshot) { [weak self] in
      guard snapshot.itemIdentifiers.count <= 3 else { return }
      self?.scrollToBottom()
    }
  }
}

// MARK: - DropDownDelegate
extension FeedCommentViewController: DropDownDelegate {
  func dropDown(_ dropDown: DropDownView, didSelectRowAt: Int) {
    if dropDownOptions.count == 1 {
      didTapReportButtonSubject.send(())
    } else if didSelectRowAt == 0 {
      didTapShareButtonSubject.send(())
    } else {
      presentDeleteWaringAlert()
    }
  }
}

// MARK: - Private Methods
private extension FeedCommentViewController {
  func configureRefreshControl() {
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(refreshStart), for: .valueChanged)
  }

  @objc func refreshStart() {
    requestCommentsSubject.send(())
  }

  func scrollToBottom(_ completion: (() -> Void)? = nil) {
    tableView.layoutIfNeeded()
    UIView.animate(withDuration: 0.3) {
      let scrollDistance = self.tableView.contentSize.height - self.tableView.frame.height + 8
      self.tableView.setContentOffset(CGPoint(x: 0, y: scrollDistance), animated: false)
      self.view.layoutIfNeeded()
    } completion: { _ in
      self.setupBoundaryCellAlpha()
      completion?()
    }
  }

  func setupBoundaryCellAlpha() {
    let minOffsetY = tableView.contentOffset.y
    let maxOffsetY = minOffsetY + tableView.frame.height

    let visibleCells = tableView.visibleCells.compactMap { $0 as? FeedCommentCell }
    visibleCells.forEach { $0.alpha = 1.0; $0.isPressed = false }
    let filtersCell = visibleCells.filter { cellDidInBoundary($0, minBoundary: minOffsetY, maxBoundary: maxOffsetY) }
    filtersCell
      .forEach { $0.alpha = 0.5 }
  }

  func cellDidInBoundary(_ cell: UITableViewCell, minBoundary: CGFloat, maxBoundary: CGFloat) -> Bool {
    let minY = cell.frame.minY
    let maxY = cell.frame.maxY

    return (minY < minBoundary && maxY > minBoundary) || (minY < maxBoundary && maxY > maxBoundary)
  }

  func presentToastView() {
    let toastText = "엔터를 누르면 댓글이 전송돼요~"
    let toastView = ToastView(tipPosition: .none, text: toastText, icon: .bulbWhite)
    toastView.setConstraints { [weak self] in
      guard let self else { return }
      $0.trailing.equalTo(commentTextField)
      $0.bottom.equalTo(commentTextField.snp.top).offset(-18)
    }

    toastView.present(to: self)
  }

  func presentDeleteToastView() {
    let toastText = "길게 누르면 댓글이 삭제돼요~"
    let toastView = ToastView(tipPosition: .leftBottom, text: toastText, icon: .bulbWhite)
    let inset = deleteToastViewBottomInset()
    toastView.setConstraints { [weak self] in
      guard let self else { return }
      $0.leading.equalTo(tableView)
      $0.bottom.equalTo(tableView).offset(-inset)
    }

    toastView.present(to: self)
  }

  func presentDeleteWaringAlert() {
    let alert = AlertViewController(
      alertType: .canCancel,
      title: "피드를 삭제할까요?",
      subTitle: "삭제한 피드는 복구할 수 없으며,\n오늘 더 이상 피드를 올릴 수 없어요."
    )
    alert.present(to: self, animted: true)
    alert.cancelButtonTitle = "취소할게요"
    alert.confirmButtonTitle = "삭제할게요"
    alert.didTapConfirmButton
      .sinkOnMain(with: self) { owner, _ in
        owner.didTapDeleteFeedButtonSubject.send(())
      }.store(in: &cancellables)
  }

  func deleteToastViewBottomInset() -> CGFloat {
    guard let dataSource else { return 0.0 }
    let count = dataSource.snapshot().numberOfItems
    let indexPath = IndexPath(row: 0, section: count - 1)
    guard let cell = tableView.cellForRow(at: indexPath) else { return 0.0 }
    let cellRect = cell.convert(cell.bounds, to: tableView)
    return cellRect.height + 18
  }

  func didTapReturnButton() {
    view.endEditing(true)
    guard !commentTextField.text.isEmpty else { return }
    uploadCommentSubject.send(commentTextField.text)
  }

  func presentWithAnimation() {
    let origin = mainContainerView.frame.origin
    mainContainerView.frame.origin = .init(x: origin.x, y: view.frame.maxY)

    UIView.animate(withDuration: 0.3) {
      self.mainContainerView.frame.origin = origin
      self.mainContainerView.layoutIfNeeded()
    }
  }

  func configureDropDown() {
    view.addSubviews(dropDownView)
    dropDownView.setConstraints { [weak self] make in
      guard let self else { return }
      make.top.equalTo(topView.optionButton.snp.bottom).offset(8)
      make.trailing.equalTo(topView.optionButton)
      make.width.equalTo(130)
    }
    dropDownView.delegate = self
    dropDownView.dataSource = dropDownOptions
  }

  func keepAliveBlurView() {
    guard let window = UIWindow.key else { return }

    blurView.frame = window.frame
    window.addSubview(blurView)
  }

  @MainActor func openInstagramToShareStory(url: URL?, challengeName: String) async {
    do {
      guard
        let url = url,
        let result = try? await KingfisherManager.shared.retrieveImage(with: url)
      else { throw InstagramStoryManager.InstagramStoryError.failedConvertToData }

      let storyView = InstagramStoryView()
      storyView.configure(image: result.image, title: challengeName)
      storyView.frame.size = .init(width: 346, height: 646)

      let instagramURL = try InstagramStoryManager.shared.prepareInstagramStoryShare(view: storyView)
      UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
    } catch {
      guard let error = error as? InstagramStoryManager.InstagramStoryError else { return }

      switch error {
        case .failedConvertToData: presentConverToStoryDataAlert()
        case .notInstalled: presentFailedOpenInstagramToShareStoryAlert()
      }
    }
  }

  func presentConverToStoryDataAlert() {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "스토리 변환에 실패했어요",
      subTitle: "인스타그램 스토리 변환에 실패했어요.\n 잠시 후에 다시 시도해 주세요."
    )
    alert.present(to: self, animted: true)
  }

  func presentFailedOpenInstagramToShareStoryAlert() {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "인스타그램이 설치되어 있지 않아요",
      subTitle: "인스타그램이 설치되어 있지 않아\n 스토리 공유를 할 수 없어요."
    )
    alert.present(to: self, animted: true)
  }
}

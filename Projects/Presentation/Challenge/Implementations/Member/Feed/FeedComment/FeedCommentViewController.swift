//
//  FeedDetailViewController.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class FeedCommentViewController: UIViewController {
  typealias DataSourceType = UITableViewDiffableDataSource<String, CommentPresentationModel>
  typealias Snapshot = NSDiffableDataSourceSnapshot<String, CommentPresentationModel>
  
  // MARK: - Properties
  private let viewModel: FeedCommentViewModel
  private let disposeBag = DisposeBag()
  private var dataSource: DataSourceType?
  
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
  private let topView = UIView()
  private let bottomView = UIView()
  
  private let topGradientLayer = FeedCommentGradientLayer(mode: .topToBottom, maxAlpha: 0.5)
  private let bottomGradientLayer = FeedCommentGradientLayer(mode: .bottomToTop, maxAlpha: 0.8)
  
  private let avatarImageView = AvatarImageView(size: .xSmall)
  private let userNameLabel = UILabel()
  private let updateTimeLabel = UILabel()
  private let likeButton = IconButton(size: .small)
  private let likeCountLabel = UILabel()
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
    setupUI()
    bind()
  }
  
  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    mainContainerView.layoutIfNeeded()
    let width = mainContainerView.frame.width
    
    topGradientLayer.frame = .init(
      origin: .zero,
      size: .init(width: width, height: 80)
    )
    topGradientLayer.bounds.origin.y = -80
    
    bottomGradientLayer.frame = .init(
      origin: .zero,
      size: .init(width: width, height: 279)
    )
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    scrollToBottom()
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
    imageView.contentMode = .scaleAspectFit
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(blurView, mainContainerView)
    mainContainerView.addSubviews(
      imageView,
      topView,
      bottomView
    )
    topView.layer.addSublayer(topGradientLayer)
    bottomView.layer.addSublayer(bottomGradientLayer)
    topView.addSubviews(
      avatarImageView,
      userNameLabel,
      updateTimeLabel,
      likeButton,
      likeCountLabel
    )
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
    
    avatarImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(18)
      $0.top.equalToSuperview().offset(22)
    }
    
    userNameLabel.snp.makeConstraints {
      $0.centerY.equalTo(avatarImageView)
      $0.leading.equalTo(avatarImageView.snp.trailing).offset(6)
    }
    
    updateTimeLabel.snp.makeConstraints {
      $0.centerY.equalTo(avatarImageView)
      $0.leading.equalTo(userNameLabel.snp.trailing).offset(12)
    }
    
    likeButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(18)
    }
    
    likeCountLabel.snp.makeConstraints {
      $0.centerX.equalTo(likeButton)
      $0.top.equalTo(likeButton.snp.bottom).offset(6)
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
}

// MARK: - Bind Methods
private extension FeedCommentViewController {
  func bind() {
    viewBind()
  }
  
  func viewBind() {
    commentTextField.rx.didBeginInitialEditing
      .bind(with: self) { owner, _ in
        owner.presentToastView()
      }
      .disposed(by: disposeBag)
    
    commentTextField.rx.didTapReturn
      .bind(with: self) { owner, _ in
        owner.didTapReturnButton()
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for cell: FeedCommentCell, model: CommentPresentationModel) {
    cell.rx.longPressGesture()
      .map { $0.state }
      .bind(with: self) { owner, state in
        switch state {
          case .began:
            cell.isPressed = true
          case .failed, .cancelled:
            cell.isPressed = false
          case .ended:
            owner.delete(model: model)
          default: break
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDelegate
extension FeedCommentViewController: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    setupBoundaryCellAlpha()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section != 0 else { return nil }
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }
}

// MARK: - TableView DataSource
private extension FeedCommentViewController {
  func diffableDataSource() -> DataSourceType {
    return .init(tableView: tableView) { [weak self] tableView, indexPath, model in
      let cell = tableView.dequeueCell(FeedCommentCell.self, for: indexPath)
      cell.configure(userName: model.userName, comment: model.content)
      
      self?.bind(for: cell, model: model)
      
      return cell
    }
  }
  
  func configureInitialData(models: [CommentPresentationModel]) {
    var snapshot = Snapshot()
    let sections = models.map { $0.id }
    snapshot.appendSections(sections)
    
    models.forEach { model in
      snapshot.appendItems([model], toSection: model.id)
    }
    
    dataSource?.apply(snapshot)
  }
  
  func append(model: CommentPresentationModel) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    snapshot.appendSections([model.id])
    snapshot.appendItems([model], toSection: model.id)
    dataSource.apply(snapshot)
    setupBoundaryCellAlpha()
  }
  
  func delete(model: CommentPresentationModel) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()
    
    snapshot.deleteItems([model])
    snapshot.deleteSections([model.id])
    dataSource.apply(snapshot)
    setupBoundaryCellAlpha()
  }
}

// MARK: - Private Methods
private extension FeedCommentViewController {
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
  
  func setUserName(_ userName: String) {
    userNameLabel.attributedText = userName.attributedString(
      font: .body2Bold,
      color: .white
    )
  }
  
  func updateTime(_ updateTime: String) {
    updateTimeLabel.attributedText = updateTime.attributedString(
      font: .caption1,
      color: .gray200
    )
  }
  
  func setLikeCount(_ likeCount: Int) {
    let likeCountText = likeCount == 0 ? "" : "\(likeCount)"
    likeCountLabel.attributedText = likeCountText.attributedString(
      font: .caption1Bold,
      color: .gray200
    )
  }
  
  func presentToastView() {
    let toastText = "엔터를 누르면 댓글이 전송돼요~"
    let toastView = ToastView(tipPosition: .none, text: toastText, icon: .bulbWhite)
    toastView.setConstraints { [weak self] in
      guard let self else { return }
      $0.trailing.equalTo(commentTextField)
      $0.bottom.equalTo(commentTextField.snp.top).offset(-18)
    }
    
    toastView.present(to: self, at: bottomView)
  }
  
  func presentDeleteToastView() {
    let toastText = "길게 누르면 댓글이 삭제돼요~"
    let toastView = ToastView(tipPosition: .leftBottom, text: toastText, icon: .bulbWhite)
    let inset = deleteToastViewBottomInset()
    toastView.setConstraints { [weak self] in
      guard let self else { return }
      $0.leading.equalTo(tableView)
      $0.bottom.equalTo(tableView).inset(inset)
    }
    
    toastView.present(to: self, at: bottomView)
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
    // TODO: 서버 연동 후, 수정 예정
    let model = CommentPresentationModel(id: UUID().uuidString, userName: "석영", content: commentTextField.text, isOwner: true, updatedAt: Date())
    append(model: model)
    commentTextField.text = ""
    
    scrollToBottom { [weak self] in
      self?.presentDeleteToastView()
    }
  }
  
  func scrollToBottom(_ completion: (() -> Void)? = nil) {
    let count = dataSource?.snapshot().numberOfItems ?? 0
    let indexPath = IndexPath(row: 0, section: count - 1)
    UIView.animate(withDuration: 0.3) {
      self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
      self.view.layoutIfNeeded()
    } completion: { _ in
      completion?()
    }
  }
}
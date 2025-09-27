//
//  ParticipantViewController.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ParticipantViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: ParticipantViewModel
  private let disposeBag = DisposeBag()
  private var dataSource = [ParticipantPresentationModel]() {
    didSet {
      participantTableView.reloadData()
      configureCountLabel(count: dataSource.count)
    }
  }
  
  private let requestData = PublishRelay<Void>()
  private let contentOffset = PublishRelay<Double>()
  private let didTapEditButtonRelay = PublishRelay<String>()

  // MARK: - UI Components
  private let participantCountLabel = UILabel()
  private let participantTableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.registerCell(ParticipantCell.self)
    tableView.rowHeight = 150
    tableView.showsVerticalScrollIndicator = false
    
    return tableView
  }()
  
  // MARK: - Initializers
  init(viewModel: ParticipantViewModel) {
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
    
    participantTableView.dataSource = self
    participantTableView.delegate = self
    setupUI()
    bind()
    
    requestData.accept(())
  }
}

// MARK: - UI Methods
private extension ParticipantViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(participantCountLabel, participantTableView)
  }
  
  func setConstraints() {
    participantCountLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalToSuperview().offset(32)
    }

    participantTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
      $0.top.equalTo(participantCountLabel.snp.bottom).offset(16)
    }
  }
}

// MARK: - Bind Methods
private extension ParticipantViewController {
  func bind() {
    let input = ParticipantViewModel.Input(
      requestData: requestData.asSignal(),
      contentOffset: contentOffset.asSignal(),
      didTapEditButton: didTapEditButtonRelay.asSignal()
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: ParticipantViewModel.Output) {
    output.participants
      .drive(rx.dataSource)
      .disposed(by: disposeBag)
  }
}

// MARK: - ParticipantPresentable
extension ParticipantViewController: ParticipantPresentable {
  func didUpdateGoal(_ goal: String) {
    guard let ownerIndex = dataSource.firstIndex(where: { $0.isSelf }) else { return }
    
    dataSource[ownerIndex].goal = goal
    presentDidChangeGoalToastView()
  }
}

// MARK: - UITableViewDataSource
extension ParticipantViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(ParticipantCell.self, for: indexPath)
    cell.configure(with: dataSource[indexPath.row])
    
    cell.rx.didTapEditButton
      .withUnretained(self)
      .map { ($0.0.dataSource[indexPath.row].goal) }
      .bind(to: didTapEditButtonRelay)
      .disposed(by: disposeBag)
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension ParticipantViewController: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offSet = scrollView.contentOffset.y
    contentOffset.accept(offSet)
  }
}

// MARK: - Private Methods
private extension ParticipantViewController {
  func configureCountLabel(count: Int) {
    participantCountLabel.attributedText = "파티원 \(count)명".attributedString(
      font: .body1Bold,
      color: .init(red: 0.27, green: 0.27, blue: 0.27, alpha: 1)
    )
  }
  
  func presentDidChangeGoalToastView() {
    let toastView = ToastView(
      tipPosition: .none,
      text: "수정 완료! 새로운 목표까지 화이팅이에요!",
      icon: .bulbWhite
    )
    
    toastView.setConstraints {
      $0.bottom.equalToSuperview().inset(64)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
}

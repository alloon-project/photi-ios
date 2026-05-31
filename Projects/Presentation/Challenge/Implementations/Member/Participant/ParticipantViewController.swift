//
//  ParticipantViewController.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import CoreUI
import DesignSystem

final class ParticipantViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: ParticipantViewModel
  private var cancellables = Set<AnyCancellable>()
  private var dataSource = [ParticipantPresentationModel]() {
    didSet {
      participantTableView.reloadData()
      configureCountLabel(count: dataSource.count)
    }
  }

  private let requestDataSubject = PassthroughSubject<Void, Never>()
  private let contentOffsetSubject = PassthroughSubject<Double, Never>()
  private let didTapEditButtonSubject = PassthroughSubject<String, Never>()

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

    requestDataSubject.send(())
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
      requestData: requestDataSubject.eraseToAnyPublisher(),
      contentOffset: contentOffsetSubject.eraseToAnyPublisher(),
      didTapEditButton: didTapEditButtonSubject.eraseToAnyPublisher()
    )
    let output = viewModel.transform(input: input)
    viewModelBind(for: output)
  }

  func viewModelBind(for output: ParticipantViewModel.Output) {
    output.participants
      .sinkOnMain(with: self) { owner, participants in
        owner.dataSource = participants
      }
      .store(in: &cancellables)
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

    cell.didTapEditButton
      .sink { [weak self] in
        guard let self else { return }
        let goal = self.dataSource[indexPath.row].goal
        self.didTapEditButtonSubject.send(goal)
      }
      .store(in: &cancellables)

    return cell
  }
}

// MARK: - UITableViewDelegate
extension ParticipantViewController: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offSet = scrollView.contentOffset.y
    contentOffsetSubject.send(offSet)
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

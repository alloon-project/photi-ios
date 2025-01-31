//
//  ChallengeRuleView.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import DesignSystem

final class ChallengeRuleView: UIView, ChallengeInformationPresentable {
  // MARK: - Properties
  var rules: [String] = [] {
    didSet { configure(rules) }
  }
  
  // MARK: UI Components
  private let seperatorLayer: CAShapeLayer = {
    let shapeLayer = CAShapeLayer()
    let lineDashPattern: [NSNumber]? = [4, 4]
    shapeLayer.strokeColor = UIColor.green200.cgColor
    shapeLayer.lineWidth = 1
    shapeLayer.lineDashPattern = lineDashPattern
    
    return shapeLayer
  }()
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증 룰".attributedString(
      font: .caption1Bold,
      color: .green500
    )
    
    return label
  }()
  private let ruleStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 26
    stackView.alignment = .center
    stackView.distribution = .fillProportionally
    
    return stackView
  }()
  fileprivate lazy var displayAllRulesButton = LineRoundButton(text: "전체보기", type: .secondary, size: .xSmall)

  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    guard
      let subviewsFirstItem = ruleStackView.arrangedSubviews.first,
      ruleStackView.arrangedSubviews.count == 2
    else {
      seperatorLayer.path = nil
      return
    }
    ruleStackView.layoutIfNeeded()

    let yPosition = subviewsFirstItem.frame.maxY + 12
    configureSeperatorView(yPosition: yPosition)
  }
  
  // MARK: - Configure
  func configure(_ rules: [String]) {
    self.rules = rules
    configureRuleViews(rules)
    
    if rules.count > 2 { configureButton() }
  }
}

// MARK: - UI Methods
private extension ChallengeRuleView {
  func setupUI() {
    configureBackground(color: .green0, borderColor: .green100)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, ruleStackView)
    ruleStackView.layer.addSublayer(seperatorLayer)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    ruleStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension ChallengeRuleView {
  func configureRuleViews(_ rules: [String]) {
    removeAllSubviews()
    configureRuleStackViews(Array(rules.prefix(2)))
  }
  
  func removeAllSubviews() {
    let subviews = ruleStackView.arrangedSubviews
    subviews.forEach { $0.removeFromSuperview() }
  }
  
  func configureRuleStackViews(_ rules: [String]) {
    guard !rules.isEmpty else { return }
    let labels = rules.map { ruleLabel($0) }
    
    ruleStackView.addArrangedSubviews(labels)
    labels.forEach { label in
      label.snp.makeConstraints {
        $0.leading.trailing.equalToSuperview().inset(16)
      }
    }
  }
  
  func ruleLabel(_ rule: String) -> UILabel {
    let label = UILabel()
    label.numberOfLines = 0
    label.attributedText = rule.attributedString(
      font: .body2,
      color: .gray800
    )
    
    return label
  }
  
  func configureSeperatorView(yPosition: CGFloat) {
    let path = CGMutablePath()
    let lineStartPoint = CGPoint(x: 0, y: yPosition)
    let lineEndPoint = CGPoint(x: frame.width, y: yPosition)
    
    path.addLines(between: [lineStartPoint, lineEndPoint])
    seperatorLayer.path = path
  }
  
  func configureButton() {
    addSubview(displayAllRulesButton)
    displayAllRulesButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(16)
      $0.centerX.equalToSuperview()
    }
  }
}

extension Reactive where Base: ChallengeRuleView {
  var didTapViewAllRulesButton: ControlEvent<[String]> {
    let source = base.displayAllRulesButton.rx.tap.map { _ in
      base.rules
    }
    
    return .init(events: source)
  }
}

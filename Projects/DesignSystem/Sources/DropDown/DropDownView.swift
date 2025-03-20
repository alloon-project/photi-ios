//
//  DropDownView.swift
//  DesignSystem
//
//  Created by jung on 5/17/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit

public protocol DropDownDelegate: AnyObject {
  func dropDown(_ dropDown: DropDownView, didSelectRowAt: Int)
}

public final class DropDownView: UIView {
  private enum DropDownMode {
    case display
    case hide
  }
  
  public weak var delegate: DropDownDelegate?
  
  /// DropDownView의 상태를 확인하는 private 변수입니다.
  private var dropDownMode: DropDownMode = .hide
  
  /// DropDown을 띄울 Constraint를 적용합니다.
  private var dropDownConstraints: ((ConstraintMaker) -> Void)?
  
  /// DropDown을 display여부를 확인 및 설정할 수 있습니다.
  public var isDisplayed: Bool {
    get { dropDownMode == .display }
    set {
      if newValue {
        becomeFirstResponder()
      } else {
        resignFirstResponder()
      }
    }
  }
  
  /// DropDown에 띄울 목록들을 정의합니다.
  public var dataSource = [String]() {
    didSet { dropDownTableView.reloadData() }
  }
  
  public override var canBecomeFirstResponder: Bool { true }
  
  public var anchorView: UIView? {
    didSet {
      guard let anchorView else { return }
      setupAnchorView(anchorView)
    }
  }
  
  // MARK: - UI Components
  /// DropDown의 AnchorView를 결정합니다.
  fileprivate let dropDownTableView = DropDownTableView()
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    
    dropDownTableView.dataSource = self
    dropDownTableView.delegate = self
    dropDownTableView.backgroundColor = .gray0
  }
  
  public convenience init(anchorView: UIView) {
    self.init()
    self.anchorView = anchorView
    setupAnchorView(anchorView)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UIResponder Methods
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    super.becomeFirstResponder()

    dropDownMode = .display
    displayDropDown(with: dropDownConstraints)
    return true
  }
  
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    
    dropDownMode = .hide
    hideDropDown()
    return true
  }
}

// MARK: - UITableViewDataSource
extension DropDownView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(DropDownCell.self, for: indexPath)
    cell.configure(with: dataSource[indexPath.section])

    return cell
  }
  
  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView(frame: .init(origin: .zero, size: .init(width: tableView.frame.width, height: 2)))
    let strockView = UIView()
    strockView.frame = .init(
      origin: .init(x: 20, y: 0),
      size: .init(width: view.frame.width - 40, height: 2)
    )

    strockView.layer.borderWidth = 1
    strockView.layer.borderColor = UIColor.photiWhite.cgColor
    
    view.addSubview(strockView)
    return view
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == dataSource.count - 1 {
      return 0
    } else {
      return 2
    }
  }
}

// MARK: - UITableViewDelegate
extension DropDownView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    resignFirstResponder()
    delegate?.dropDown(self, didSelectRowAt: indexPath.section)
  }
}

// MARK: - Private Method
public extension DropDownView {
  func setupAnchorView(_ view: UIView) {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAnchorView))
    
    view.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func didTapAnchorView() {
    if dropDownMode == .display {
      resignFirstResponder()
    } else {
      becomeFirstResponder()
    }
  }
  
  /// DropDownList를 보여줍니다.
  func displayDropDown(with constraints: ((ConstraintMaker) -> Void)?) {
    guard let constraints, let window else { return }
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
      guard let self else { return }
      window.addSubview(self.dropDownTableView)
      self.dropDownTableView.snp.makeConstraints(constraints)
    }
  }
  
  /// DropDownList를 hide합니다.
  func hideDropDown() {
    guard let window else { return }
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
      guard let self else { return }
      self.dropDownTableView.snp.removeConstraints()
      self.dropDownTableView.removeFromSuperview()
    }
  }
  
  func setConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) {
    self.dropDownConstraints = closure
  }
}

//
//  UITableView+Extension.swift
//  Core
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

// MARK: - UIKit
public extension UITableView {
  /// table view의 cell을 리턴합니다.
  /// - Parameters:
  ///   - type: 리턴할 cell의 타입 (ex: `MyCell.self`)
  ///   - indexPath: cell의 indexPath
  func cellForRow<T: UITableViewCell>(_ type: T.Type, at indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    guard let cell = cellForRow(at: indexPath) as? T else {
      fatalError("identifier: \(identifier) could not be row as \(T.self)")
    }
    return cell
  }
  
  /// tableView에 cell을 register합니다. identifier는 cell의 type이름으로 지정됩니다.
  /// - Parameter type: register할 cell의 type. (ex: `MyCell.self`)
  func registerCell<T: UITableViewCell>(_ type: T.Type) {
    let identifier = String(describing: type)
    register(T.self, forCellReuseIdentifier: identifier)
  }
  
  /// tableView에서 cell을 dequeue합니다.
  /// - Parameter type: dequeue될 cell의 type. (ex: `MyCell.self`)
  func dequeueCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
      fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
    }
    return cell
  }
  
  /// tableview에 header/footer를 register합니다.
  /// - Parameter type: register할 header/footer type. (ex: `MyHeaderFooter.self`)
  func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ type: T.Type) {
    let identifier = String(describing: type)
    register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
  }
  
  /// tableView에서 header/footer를 dequeue합니다.
  /// - Parameter type: dequeue될 header/footer의 type. (ex: `MyHeaderFooter.self`)
  func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T {
    let identifier = String(describing: type)
    guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
      fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
    }
    return headerFooter
  }
}

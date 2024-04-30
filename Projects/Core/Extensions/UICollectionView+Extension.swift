//
//  UICollectionView+Extension.swift
//  Core
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension UICollectionView {
  /// collection view에 cell을 register합니다. identifier는 cell의 type이름으로 지정됩니다.
  /// - Parameter type: register할 cell의 type. (ex: `MyCell.self`)
  func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
    let identifier = String(describing: type)
    register(T.self, forCellWithReuseIdentifier: identifier)
  }
  
  /// collection view에서 cell을 dequeue합니다.
  /// - Parameter type: dequeue될 cell의 type. (ex: `MyCell.self`)
  func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
      fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
    }
    return cell
  }
  
  /// collection view에 header를 register합니다.
  /// - Parameter type: register할 header의 type. (ex: `MyHeader.self`)
  func registerHeader<T: UICollectionReusableView>(_ type: T.Type) {
    let identifier = String(describing: type)
    register(
      type,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: identifier
    )
  }
  
  /// collection view에서 header를 dequeue합니다.
  /// - Parameter type: dequeue될 header의 type. (ex: `MyHeader.self`)
  func dequeueHeader<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    guard let header = dequeueReusableSupplementaryView(
      ofKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: identifier,
      for: indexPath
    ) as? T else {
      fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
    }
    return header
  }
  
  /// collection view에서 footer을 register합니다.
  /// - Parameter type: register할 footer의 type. (ex: `MyFooter.self`)
  func registerFooter<T: UICollectionReusableView>(_ type: T.Type) {
    let identifier = String(describing: type)
    register(
      type,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: identifier
    )
  }
  
  /// collection view에서 footer를 dequeue합니다.
  /// - Parameter type: dequeue될 footer의 type.(ex: `MyFooter.self`)
  func dequeueFooter<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    guard let footer = dequeueReusableSupplementaryView(
      ofKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: identifier,
      for: indexPath
    ) as? T else {
      fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
    }
    return footer
  }
}

//
//  UIButton+Combine.swift
//  Core
//
//  Created by jung on 11/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Combine

public extension UIButton {
  /// 버튼이 탭될 때마다 Void 이벤트를 방출하는 Publisher
  var tapPublisher: AnyPublisher<Void, Never> {
    eventPublisher(for: .touchUpInside)
      .map { _ in () }
      .eraseToAnyPublisher()
  }
  
  /// 지정한 이벤트로 버튼 탭 Publisher 생성 (Rx의 tap(_:)과 유사)
  /// 기본값은 `.touchUpInside`
  /// - Parameter event: 감지할 UIControl.Event (기본: .touchUpInside)
  /// - Returns: 해당 이벤트가 발생할 때 Void를 방출하는 Publisher
  func tap(_ event: UIControl.Event = .touchUpInside) -> AnyPublisher<Void, Never> {
    eventPublisher(for: event)
      .map { _ in () }
      .eraseToAnyPublisher()
  }
}

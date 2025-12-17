//
//  UITextField+Combine.swift
//  Core
//
//  Created by jung on 11/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Combine

public extension UITextField {
  /// 현재 값 1회 + 이후 `.editingChanged` 마다 텍스트를 방출합니다.
  /// - Note: UI 업데이트 안전을 위해 메인 런루프로 전달하고, 동일 값은 중복 방출하지 않습니다.
  var textPublisher: AnyPublisher<String, Never> {
    let initial = Just(self.text ?? "").eraseToAnyPublisher()
    let changes = eventPublisher(for: .editingChanged)
      .map { [weak self] in self?.text ?? "" }
      .eraseToAnyPublisher()

    return initial
      .merge(with: changes)
      .removeDuplicates()
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}

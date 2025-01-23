//
//  ChallengeInformationPresentable.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

protocol ChallengeInformationPresentable {
  func configureBackground(color: UIColor, borderColor: UIColor?)
}

extension ChallengeInformationPresentable where Self: UIView {
  func configureBackground(color: UIColor, borderColor: UIColor?) {
    layer.cornerRadius = 10
    clipsToBounds = true
    backgroundColor = color
    
    guard let borderColor else { return }
    layer.borderWidth = 1
    layer.borderColor = borderColor.cgColor
  }
}

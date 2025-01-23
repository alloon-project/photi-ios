//
//  RoundImageView.swift
//  Core
//
//  Created by jung on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public final class RoundImageView: UIImageView {
  public override func layoutSubviews() {
    layer.cornerRadius = self.bounds.width / 2.0
  }
}

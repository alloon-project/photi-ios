//
//  UIImageView+Extension.swift
//  Core
//
//  Created by 임우섭 on 9/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

extension UIImageView {
    public func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

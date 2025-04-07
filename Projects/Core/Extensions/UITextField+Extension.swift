//
//  UITextField+Extension.swift
//  Core
//
//  Created by jung on 12/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UITextField {
  func setRightView(
    _ rightView: UIView,
    size: CGSize,
    leftPdding: CGFloat,
    rightPadding: CGFloat,
    viewMode: UITextField.ViewMode = .always
  ) {
    let totalViewSize = CGSize(
      width: size.width + leftPdding + rightPadding,
      height: size.height
    )
    
    let totalView = UIView(frame: .init(origin: .zero, size: totalViewSize))
    totalView.addSubview(rightView)
    rightView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      rightView.centerYAnchor.constraint(equalTo: totalView.centerYAnchor),
      rightView.heightAnchor.constraint(equalToConstant: size.height),
      rightView.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -rightPadding),
      rightView.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: leftPdding)
    ])

    self.rightView = totalView
    self.rightViewMode = viewMode
  }
  
  func setLeftView(
    _ leftView: UIView,
    size: CGSize,
    leftPdding: CGFloat,
    rightPadding: CGFloat,
    viewMode: UITextField.ViewMode = .always
  ) {
    let totalViewSize = CGSize(
      width: size.width + leftPdding + rightPadding,
      height: size.height
    )
    let leftViewOrigin = CGPoint(x: leftPdding, y: 0)
    
    let totalView = UIView(frame: .init(origin: .zero, size: totalViewSize))
    totalView.addSubview(leftView)
    leftView.frame = .init(origin: leftViewOrigin, size: size)
    
    self.leftView = totalView
    leftViewMode = viewMode
  }
  
  func setleftImage(
    _ image: UIImage,
    size: CGSize,
    leftPadding: CGFloat,
    rightPadding: CGFloat
  ) {
    let imageView = UIImageView()
    imageView.image = image
    
    setLeftView(
      imageView,
      size: size,
      leftPdding: leftPadding,
      rightPadding: rightPadding
    )
  }
}

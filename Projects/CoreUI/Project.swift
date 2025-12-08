//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by wooseob on 6/11/25.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
  name: "CoreUI",
  targets: [
    .make(
      name: "CoreUI",
      product: .framework,
      bundleId: "com.photi.coreui",
      sources: [
        "Extensions+CoreUI/**/*.swift",
        "Utils+CoreUI/**/*.swift"
      ]
    )
  ]
)

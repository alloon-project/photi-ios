//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
  name: "Core",
  targets: [
    .make(
      name: "Core",
      product: .framework,
      bundleId: "com.photi.core",
      sources: [
        "Extensions/**",
        "Utils/**"
      ],
      dependencies: [
        .SPM.RxCocoa,
        .SPM.RxSwift
      ]
    )
  ]
)

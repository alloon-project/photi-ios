//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
  name: "Cores",
  targets: [
    .make(
      name: "Core",
      product: .framework,
      bundleId: "com.photi.core",
      sources: [
        "Core/**"
      ]
    ),
    .make(
      name: "CoreUI",
      product: .framework,
      bundleId: "com.photi.coreui",
      sources: [
        "CoreUI/**"
      ]
    )
  ]
)

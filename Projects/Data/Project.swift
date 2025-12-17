//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
  name: "Data",
  targets: [
    .make(
      name: "DTO",
      product: .staticLibrary,
      bundleId: "com.photi.dto",
      sources: ["DTO/**"]
    ),
    .make(
      name: "DataMapper",
      product: .staticLibrary,
      bundleId: "com.photi.dataMapper",
      sources: ["DataMapper/**"],
      dependencies: [
        .Project.Data.DTO,
        .Project.Domain.Entity,
        .Project.Cores.Core
      ]
    ),
    .make(
      name: "RepositoryImpl",
      product: .staticLibrary,
      bundleId: "com.photi.repositoryImpl",
      sources: ["Repository/Implementations/**"],
      dependencies: [
        .Project.Data.DTO,
        .Project.Data.DataMapper,
        .Project.Data.PhotiNetwork,
        .Project.Domain.Repository
      ]
    ),
    .make(
      name: "PhotiNetwork",
      product: .staticLibrary,
      bundleId: "com.photi.photiNetwork",
      sources: ["PhotiNetwork/**"]
    )
  ]
)

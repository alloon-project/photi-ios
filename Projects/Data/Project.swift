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
			bundleId: "com.alloon.dto",
			sources: ["DTO/**"]
		),
		.make(
			name: "DataMapper",
			product: .staticLibrary,
			bundleId: "com.alloon.dataMapper",
			sources: ["DataMapper/**"],
			dependencies: [
				.Project.Data.DTO,
				.Project.Domain.Entity
			]
		),
		.make(
			name: "RepositoryImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.repositoryImpl",
			sources: ["Repository/Implementations/**"],
			dependencies: [
				.Project.Data.DTO,
				.Project.Data.DataMapper,
				.Project.Data.AlloonNetwork,
				.Project.Domain.Repository
			]
		),
		.make(
			name: "AlloonNetwork",
			product: .staticLibrary,
			bundleId: "com.alloon.alloonNetwork",
			sources: ["AlloonNetwork/**"],
			dependencies: [
				.SPM.RxSwift
			]
		)
	]
)

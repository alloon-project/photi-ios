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
			sources: ["DataMapper/**"]
		),
		.make(
			name: "RepositoryImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.repositoryImpl",
			sources: ["Repository/Implementations/**"]
		)
	]
)

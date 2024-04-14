//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
	name:"Core",
	targets: [
		.make(
			name: "Core",
			product: .staticLibrary,
			bundleId: "com.alloon.core",
			sources: [
				"Extensions/**",
				"Utils/**"
			]
		)
	]
)

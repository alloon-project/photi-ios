//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
	name: "DesignSystem",
	targets: [
		.make(
			name: "DesignSystem",
			product: .framework,
			bundleId: "com.alloon.designSystem",
			sources: ["Sources/**"],
			resources: ["Resources/**"]
		)
	],
	resourceSynthesizers: [
		.fonts(),
		.custom(name: "Colors", parser: .assets, extensions: ["xcassets"]),
	]
)

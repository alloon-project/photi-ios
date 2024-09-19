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
			bundleId: "com.photi.designSystem",
			sources: ["Sources/**"],
			resources: ["Resources/**"],
			dependencies: [
				.Project.Core,
				.SPM.RxCocoa,
				.SPM.RxSwift,
				.SPM.SnapKit
			]
		)
	],
	resourceSynthesizers: [
		.fonts(),
		.custom(name: "Colors", parser: .assets, extensions: ["xcassets"]),
		.custom(name: "Images", parser: .assets, extensions: ["xcassets"])
	]
)

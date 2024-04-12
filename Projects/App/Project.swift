//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
	name: "Alloon",
	targets: [
		.make(
			name: "Alloon-DEV",
			product: .app,
			bundleId: "com.alloon-dev",
			infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
			sources: ["Resources/**"]
		),
		.make(
			name: "Alloon-PROD",
			product: .app,
			bundleId: "com.alloon",
			infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
			sources: ["Sources/**"],
			resources: ["Resources/**"]
		)
	]
)

//
//  Project+Extensions.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescription

public extension Project {
	static func make(
		name: String,
		targets: [Target],
		packages: [Package] = [],
		resourceSynthesizers: [ResourceSynthesizer] = [],
		additionalFiles: [FileElement] = []
	) -> Project {
		return Project(
			name: name,
			organizationName: "com.alloon",
			options: .options(
				automaticSchemesOptions: .disabled,
				textSettings: .textSettings(usesTabs: false, indentWidth: 2, tabWidth: 2)
			),
			packages: packages,
			targets: targets,
			additionalFiles: additionalFiles,
			resourceSynthesizers: resourceSynthesizers
		)
	}
}


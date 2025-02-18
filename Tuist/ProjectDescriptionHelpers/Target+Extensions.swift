//
//  Target+Extensions.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescription

public extension Target {
	static func make(
		name: String,
		platform: Platform = .iOS,
		product: Product,
		bundleId: String,
		deploymentTarget: DeploymentTarget = .iOS(targetVersion: "15.0", devices: [.iphone]),
		infoPlist: InfoPlist = .default,
		sources: SourceFilesList,
		resources: ResourceFileElements? = nil,
		scripts: [TargetScript] = [],
		dependencies: [TargetDependency] = [],
		settings: Settings? = nil
	) -> Target {
		return .init(
			name: name,
			platform: platform,
			product: product,
			bundleId: bundleId,
			deploymentTarget: deploymentTarget,
			infoPlist: infoPlist,
			sources: sources,
			resources: resources,
			scripts: scripts,
			dependencies: dependencies,
			settings: settings
		)
	}
}

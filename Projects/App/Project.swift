//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
	name: "Photi",
	targets: [
		.make(
			name: "Photi-DEV",
			product: .app,
			bundleId: "com.photi-dev",
			infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
			sources: ["Sources/**"],
			resources: ["Resources/**"],
			dependencies: [
				.Project.Presentation.Home,
				.Project.Presentation.HomeImpl,
				.Project.Presentation.SearchChallenge,
				.Project.Presentation.SearchChallengeImpl,
				.Project.Presentation.MyPage,
				.Project.Presentation.MyPageImpl,
				.Project.Presentation.LogIn,
				.Project.Presentation.LogInImpl,
				.Project.Presentation.Challenge,
				.Project.Presentation.ChallengeImpl,
				.Project.Presentation.Report,
				.Project.Presentation.ReportImpl,
				.Project.Domain.UseCaseImpl,
				.Project.Data.RepositoryImpl
			],
			settings: .settings(
				base: [
					"ASSETCATALOG_COMPILER_APPICON_NAME": "DevAppIcon",
					"OTHER_LDFLAGS": "-ObjC"
				],
				configurations: [
					.debug(name: .debug, xcconfig: "./xcconfigs/Photi.debug.xcconfig")
				]
			)
		),
		.make(
			name: "Photi-PROD",
			product: .app,
			bundleId: "com.photi-prod",
			infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
			sources: ["Sources/**"],
			resources: ["Resources/**"],
			dependencies: [
				.Project.Presentation.Home,
				.Project.Presentation.HomeImpl,
				.Project.Presentation.SearchChallenge,
				.Project.Presentation.SearchChallengeImpl,
				.Project.Presentation.MyPage,
				.Project.Presentation.MyPageImpl,
				.Project.Presentation.LogIn,
				.Project.Presentation.LogInImpl,
				.Project.Presentation.Challenge,
				.Project.Presentation.ChallengeImpl,
				.Project.Presentation.Report,
				.Project.Presentation.ReportImpl,
				.Project.Domain.UseCaseImpl,
				.Project.Data.RepositoryImpl
			],
			settings: .settings(
				base: [
					"ASSETCATALOG_COMPILER_APPICON_NAME": "ProdAppIcon",
					"OTHER_LDFLAGS": "-ObjC"
				],
				configurations: [
					.debug(name: .debug, xcconfig: "./xcconfigs/Photi.release.xcconfig")
				]
			)
		)
	],
	additionalFiles: [
		"./xcconfigs/Photi.shared.xcconfig"
	]
)

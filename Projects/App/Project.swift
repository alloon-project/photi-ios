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
			sources: ["Sources/**"],
			resources: ["Resources/**"],
			dependencies: [
				.Project.Presentation.Home,
				.Project.Presentation.HomeImpl,
				.Project.Presentation.MyMission,
				.Project.Presentation.MyMissionImpl,
				.Project.Presentation.MyPage,
				.Project.Presentation.MyPageImpl,
				.Project.Presentation.OnBoarding,
				.Project.Presentation.OnBoardingImpl,
				.Project.Presentation.LogIn,
				.Project.Presentation.LogInImpl,
				.Project.Domain.UseCaseImpl,
				.Project.Data.RepositoryImpl
			],
			settings: .settings(
				base: [
					"ASSETCATALOG_COMPILER_APPICON_NAME": "DevAppIcon",
					"OTHER_LDFLAGS": "-ObjC"
				],
				configurations: [
					.debug(name: .debug, xcconfig: "./xcconfigs/Alloon.debug.xcconfig")
				]
			)
		),
		.make(
			name: "Alloon-PROD",
			product: .app,
			bundleId: "com.alloon",
			infoPlist: .file(path: .relativeToRoot("Projects/App/Info.plist")),
			sources: ["Sources/**"],
			resources: ["Resources/**"],
			dependencies: [
				.Project.Presentation.Home,
				.Project.Presentation.HomeImpl,
				.Project.Presentation.MyMission,
				.Project.Presentation.MyMissionImpl,
				.Project.Presentation.MyPage,
				.Project.Presentation.MyPageImpl,
				.Project.Presentation.OnBoarding,
				.Project.Presentation.OnBoardingImpl,
				.Project.Presentation.LogIn,
				.Project.Presentation.LogInImpl,
				.Project.Domain.UseCaseImpl,
				.Project.Data.RepositoryImpl
			],
			settings: .settings(
				base: [
					"ASSETCATALOG_COMPILER_APPICON_NAME": "ProdAppIcon",
					"OTHER_LDFLAGS": "-ObjC"
				],
				configurations: [
					.debug(name: .debug, xcconfig: "./xcconfigs/Alloon.release.xcconfig")
				]
			)
		)
	],
	additionalFiles: [
		"./xcconfigs/Alloon.shared.xcconfig"
	]
)

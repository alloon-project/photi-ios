//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
	name:"Presentation",
	targets: [
		.make(
			name: "LogInImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.logInImpl",
			sources: ["LogIn/Implementations/**"],
			dependencies: [
				.Project.Presentation.LogIn,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "LogIn",
			product: .staticLibrary,
			bundleId: "com.alloon.logIn",
			sources: ["LogIn/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "OnBoardingImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.onBoardingImpl",
			sources: ["OnBoarding/Implementations/**"],
			dependencies: [
				.Project.Presentation.OnBoarding,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "OnBoarding",
			product: .staticLibrary,
			bundleId: "com.alloon.onBoarding",
			sources: ["OnBoarding/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "MyMissionImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.myMissionImpl",
			sources: ["MyMission/Implementations/**"],
			dependencies: [
				.Project.Presentation.MyMission,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "MyMission",
			product: .staticLibrary,
			bundleId: "com.alloon.myMission",
			sources: ["MyMission/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "MyPageImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.myPageImpl",
			sources: ["MyPage/Implementations/**"],
			dependencies: [
				.Project.Presentation.MyPage,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "MyPage",
			product: .staticLibrary,
			bundleId: "com.alloon.myPage",
			sources: ["MyPage/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "HomeImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.homeImpl",
			sources: ["Home/Implementations/**"],
			dependencies: [
				.Project.Presentation.Home,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "Home",
			product: .staticLibrary,
			bundleId: "com.alloon.home",
			sources: ["Home/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		)
	]
)

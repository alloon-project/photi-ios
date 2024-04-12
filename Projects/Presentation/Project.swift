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
			sources: ["LogIn/Implementations/**"]
		),
		.make(
			name: "LogIn",
			product: .staticLibrary,
			bundleId: "com.alloon.logIn",
			sources: ["LogIn/Interfaces/**"]
		),
		.make(
			name: "OnBoardingImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.onBoardingImpl",
			sources: ["OnBoarding/Implementations/**"]
		),
		.make(
			name: "OnBoarding",
			product: .staticLibrary,
			bundleId: "com.alloon.onBoarding",
			sources: ["OnBoarding/Interfaces/**"]
		),
		.make(
			name: "MyMissionImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.myMissionImpl",
			sources: ["MyMission/Implementations/**"]
		),
		.make(
			name: "MyMission",
			product: .staticLibrary,
			bundleId: "com.alloon.myMission",
			sources: ["MyMission/Interfaces/**"]
		),
		.make(
			name: "MyPageImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.myPageImpl",
			sources: ["MyPage/Implementations/**"]
		),
		.make(
			name: "MyPage",
			product: .staticLibrary,
			bundleId: "com.alloon.myPage",
			sources: ["MyPage/Interfaces/**"]
		)
	]
)

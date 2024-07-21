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
		// MARK: - Main Coordinators
		.make(
			name: "HomeImpl",
			product: .staticLibrary,
			bundleId: "com.photi.homeImpl",
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
			bundleId: "com.photi.home",
			sources: ["Home/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "SearchChallengeImpl",
			product: .staticLibrary,
			bundleId: "com.photi.searchChallengeImpl",
			sources: ["SearchChallenge/Implementations/**"],
			dependencies: [
				.Project.Presentation.SearchChallenge,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "SearchChallenge",
			product: .staticLibrary,
			bundleId: "com.photi.searchChallenge",
			sources: ["SearchChallenge/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "MyPageImpl",
			product: .staticLibrary,
			bundleId: "com.photi.myPageImpl",
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
			bundleId: "com.photi.myPage",
			sources: ["MyPage/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		// MARK: - Sub Coordinators
		.make(
			name: "LogInImpl",
			product: .staticLibrary,
			bundleId: "com.photi.logInImpl",
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
			bundleId: "com.photi.logIn",
			sources: ["LogIn/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "ChallengeImpl",
			product: .staticLibrary,
			bundleId: "com.photi.challengeImpl",
			sources: ["Challenge/Implementations/**"],
			dependencies: [
				.Project.Presentation.Challenge,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "Challenge",
			product: .staticLibrary,
			bundleId: "com.photi.challenge",
			sources: ["Challenge/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		),
		.make(
			name: "ReportImpl",
			product: .staticLibrary,
			bundleId: "com.photi.reportImpl",
			sources: ["Report/Implementations/**"],
			dependencies: [
				.Project.Presentation.Report,
				.Project.Domain.UseCase,
				.Project.Domain.Entity,
				.Project.DesignSystem,
				.SPM.RxCocoa,
				.SPM.RxGesture,
				.SPM.SnapKit
			]
		),
		.make(
			name: "Report",
			product: .staticLibrary,
			bundleId: "com.photi.report",
			sources: ["Report/Interfaces/**"],
			dependencies: [
				.Project.Core
			]
		)
	]
)

//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
	name: "Domain",
	targets: [
		.make(
			name: "Entity",
            product: .framework,
			bundleId: "com.photi.entity",
			sources: ["Entity/**"]
		),
		.make(
			name: "UseCaseImpl",
			product: .staticLibrary,
			bundleId: "com.photi.useCaseImpl",
			sources: ["UseCase/Implementations/**"],
			dependencies: [
				.Project.Domain.UseCase
			]
		),
		.make(
			name: "UseCase",
			product: .framework,
			bundleId: "com.photi.useCase",
			sources: ["UseCase/Interfaces/**"],
			dependencies: [
        .Project.Domain.Entity,
        .Project.Core,
        .SPM.RxSwift
			]
		),
		.make(
			name: "Repository",
			product: .framework,
			bundleId: "com.photi.repository",
			sources: ["Repository/Interfaces/**"],
			dependencies: [
				.Project.Domain.Entity
			]
		)
	]
)

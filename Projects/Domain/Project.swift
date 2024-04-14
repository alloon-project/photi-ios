//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by jung on 4/12/24.
//

import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.make(
	name:"Domain",
	targets: [
		.make(
			name: "Entity",
			product: .staticLibrary,
			bundleId: "com.alloon.entity",
			sources: ["Entity/**"]
		),
		.make(
			name: "UseCaseImpl",
			product: .staticLibrary,
			bundleId: "com.alloon.useCaseImpl",
			sources: ["UseCase/Implementations/**"],
			dependencies: [
				.Project.Domain.UseCase
			]
		),
		.make(
			name: "UseCase",
			product: .staticLibrary,
			bundleId: "com.alloon.useCase",
			sources: ["UseCase/Interfaces/**"],
			dependencies: [
				.Project.Domain.Entity,
				.Project.Domain.Repository,
				.SPM.RxSwift
			]
		),
		.make(
			name: "Repository",
			product: .staticLibrary,
			bundleId: "com.alloon.repository",
			sources: ["Repository/Interfaces/**"],
			dependencies: [
				.Project.Domain.Entity,
				.SPM.RxSwift
			]
		)
	]
)

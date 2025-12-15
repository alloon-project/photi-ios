//
//  TargetDependency+Project.swift
//  Config
//
//  Created by jung on 4/14/24.
//

import ProjectDescription

public extension TargetDependency {
	enum Project {}
}

public extension TargetDependency.Project {
   enum Cores {}
	enum Presentation {}
	enum Data {}
	enum Domain {}
	
	static let DesignSystem = TargetDependency.project(
		target: "DesignSystem",
		path: .relativeToRoot("Projects/DesignSystem")
	)
}

public extension TargetDependency.Project.Cores {
   static let Core = TargetDependency.project(
      target: "Core",
      path: .relativeToRoot("Projects/Cores")
   )
   
   static let CoreUI = TargetDependency.project(
      target: "CoreUI",
      path: .relativeToRoot("Projects/Cores")
   )
}

// MARK: - Presentation
public extension TargetDependency.Project.Presentation {
	static let Home = TargetDependency.project(
		target: "Home",
		path: .relativeToRoot("Projects/Presentation")
	)
	static let HomeImpl = TargetDependency.project(
		target: "HomeImpl",
		path: .relativeToRoot("Projects/Presentation")
	)
	
	static let SearchChallenge = TargetDependency.project(
		target: "SearchChallenge",
		path: .relativeToRoot("Projects/Presentation")
	)
	static let SearchChallengeImpl = TargetDependency.project(
		target: "SearchChallengeImpl",
		path: .relativeToRoot("Projects/Presentation")
	)
	
	static let MyPage = TargetDependency.project(
		target: "MyPage",
		path: .relativeToRoot("Projects/Presentation")
	)
	static let MyPageImpl = TargetDependency.project(
		target: "MyPageImpl",
		path: .relativeToRoot("Projects/Presentation")
	)
	
	static let LogIn = TargetDependency.project(
		target: "LogIn",
		path: .relativeToRoot("Projects/Presentation")
	)
	static let LogInImpl = TargetDependency.project(
		target: "LogInImpl",
		path: .relativeToRoot("Projects/Presentation")
	)
	
	static let Challenge = TargetDependency.project(
		target: "Challenge",
		path: .relativeToRoot("Projects/Presentation")
	)
	static let ChallengeImpl = TargetDependency.project(
		target: "ChallengeImpl",
		path: .relativeToRoot("Projects/Presentation")
	)
	
	static let Report = TargetDependency.project(
		target: "Report",
		path: .relativeToRoot("Projects/Presentation")
	)
	static let ReportImpl = TargetDependency.project(
		target: "ReportImpl",
		path: .relativeToRoot("Projects/Presentation")
	)
}

// MARK: - Data
public extension TargetDependency.Project.Data {
	static let DTO = TargetDependency.project(
		target: "DTO",
		path: .relativeToRoot("Projects/Data")
	)
	
	static let DataMapper = TargetDependency.project(
		target: "DataMapper",
		path: .relativeToRoot("Projects/Data")
	)
	
	static let RepositoryImpl = TargetDependency.project(
		target: "RepositoryImpl",
		path: .relativeToRoot("Projects/Data")
	)
	
	static let PhotiNetwork = TargetDependency.project(
		target: "PhotiNetwork",
		path: .relativeToRoot("Projects/Data")
	)
}

// MARK: - Domain
public extension TargetDependency.Project.Domain {
	static let Entity = TargetDependency.project(
		target: "Entity",
		path: .relativeToRoot("Projects/Domain")
	)
	
	static let Repository = TargetDependency.project(
		target: "Repository",
		path: .relativeToRoot("Projects/Domain")
	)
	
	static let UseCase = TargetDependency.project(
		target: "UseCase",
		path: .relativeToRoot("Projects/Domain")
	)
	static let UseCaseImpl = TargetDependency.project(
		target: "UseCaseImpl",
		path: .relativeToRoot("Projects/Domain")
	)
}

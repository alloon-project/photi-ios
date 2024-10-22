//
//  TargetDependency+SPM.swift
//  Config
//
//  Created by jung on 4/14/24.
//

import ProjectDescription

public extension TargetDependency {
	enum SPM {}
}

public extension TargetDependency.SPM {
	static let RxSwift = TargetDependency.external(name: "RxSwift")
	static let RxCocoa = TargetDependency.external(name: "RxCocoa")
	static let RxRelay = TargetDependency.external(name: "RxRelay")
	static let RxGesture = TargetDependency.external(name: "RxGesture")
	static let SnapKit = TargetDependency.external(name: "SnapKit")
	static let Kingfisher = TargetDependency.external(name: "Kingfisher")
}

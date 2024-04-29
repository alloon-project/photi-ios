//
//  Dependencies.swift
//  Config
//
//  Created by jung on 4/14/24.
//

import ProjectDescription

let dependencies = Dependencies(
		swiftPackageManager: [
				.remote(
						url: "https://github.com/ReactiveX/RxSwift.git",
						requirement: .exact("6.6.0")
				),
				.remote(
					url: "https://github.com/SnapKit/SnapKit.git",
					requirement: .exact("5.6.0")
				),
				.remote(
					url: "https://github.com/RxSwiftCommunity/RxGesture.git",
					requirement: .exact("4.0.1")
				)
		],
		platforms: [.iOS]
)

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
				),
				.remote(
					url: "https://github.com/onevcat/Kingfisher.git",
					requirement: .exact("8.1.0")
				),
				.remote(
					url: "https://github.com/airbnb/lottie-ios.git",
					requirement: .exact("4.5.0")
				),
        .remote(
          url: "https://github.com/jungseokyoung-cloud/Coordinator.git",
          requirement: .exact("1.1.2")
        )
		],
		platforms: [.iOS]
)

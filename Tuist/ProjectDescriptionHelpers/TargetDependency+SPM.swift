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
    static let SnapKit = TargetDependency.external(name: "SnapKit")
    static let Kingfisher = TargetDependency.external(name: "Kingfisher")
    static let Lottie = TargetDependency.external(name: "Lottie")
    static let Coordinator = TargetDependency.external(name: "Coordinator")
    static let KakaoSDKAuth = TargetDependency.external(name: "KakaoSDKAuth")
    static let KakaoSDKUser = TargetDependency.external(name: "KakaoSDKUser")
    static let KakaoSDKCommon = TargetDependency.external(name: "KakaoSDKCommon")
}

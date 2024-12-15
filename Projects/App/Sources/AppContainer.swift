//
//  AppContainer.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import DataMapper
import Home
import HomeImpl
import LogIn
import LogInImpl
import MyPage
import MyPageImpl
import Report
import ReportImpl
import Repository
import RepositoryImpl
import SearchChallenge
import SearchChallengeImpl
import UseCase
import UseCaseImpl

final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinator() -> Coordinating
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  LogInDependency,
  SignUpDependency,
  HomeDependency,
  SearchChallengeDependency,
  MyPageDependency,
  ReportDependency {
  func coordinator() -> Coordinating {
    let home = HomeContainer(dependency: self)
    let searchChallenge = SearchChallengeContainer(dependency: self)
    let myPage = MyPageContainer(dependency: self)
    
    return AppCoordinator(
      homeContainable: home,
      searchChallengeContainable: searchChallenge,
      myPageContainable: myPage
    )
  }
  
  // MARK: - Containable
  lazy var loginContainable: LogInContainable = {
    return LogInContainer(dependency: self)
  }()
  
  lazy var signUpContainable: SignUpContainable = {
    return SignUpContainer(dependency: self)
  }()
  
  lazy var reportContainable: ReportContainable = {
    return ReportContainer(dependency: self)
  }()
  
  // MARK: - UseCase
  lazy var logInUseCase: LogInUseCase = {
    return LogInUseCaseImpl(repository: logInRepository)
  }()
  
  lazy var findPasswordUseCase: FindPasswordUseCase = {
    return FindPasswordUseCaseImpl(repository: findPasswordRepository)
  }()
  
  lazy var signUpUseCase: SignUpUseCase = {
    return SignUpUseCaseImpl(repository: signUpRepository)
  }()
  
  lazy var myPageUseCase: MyPageUseCase = {
    return MyPageUseCaseImpl(repository: myPageRepository)
  }()
  
  lazy var profileEditUseCase: ProfileEditUseCase = {
    return ProfileEditUseCaseImpl(repository: profileEditRepository)
  }()
  
  lazy var changePasswordUseCase: ChangePasswordUseCase = {
    return ChangePasswordUseCaseImpl(repository: changePasswordRepository)
  }()

  lazy var homeUseCae: HomeUseCase = {
    return HomeUseCaseImpl(repository: challengeRepository)
  }()
  
  // MARK: - Repository
  lazy var logInRepository: LogInRepository = {
    return LogInRepositoryImpl(dataMapper: LogInDataMapperImpl())
  }()
  
  lazy var findPasswordRepository: FindPasswordRepository = {
    return FindPasswordRepositoryImpl(dataMapper: FindPasswordDataMapperImpl())
  }()
  
  lazy var signUpRepository: SignUpRepository = {
    return SignUpRepositoryImpl(dataMapper: SignUpDataMapperImpl())
  }()
  
  lazy var myPageRepository: MyPageRepository = {
    return MyPageRepositoyImpl(dataMapper: MyPageDataMapperImpl())
  }()
  
  lazy var profileEditRepository: ProfileEditRepository = {
    return ProfileEditRepositoryImpl(dataMapper: ProfileEditDataMapperImpl())
  }()
  
  lazy var changePasswordRepository: ChangePasswordRepository = {
    return ChangePasswordRepositoryImpl(dataMapper: ChangePasswordDataMapperImpl())
  }()
  
  lazy var challengeRepository: ChallengeRepository = {
    return ChallengeRepositoryImpl(dataMapper: ChallengeDataMapperImpl())
  }()
}

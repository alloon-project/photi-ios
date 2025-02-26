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
  func coordinator() -> ViewableCoordinating
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
  func coordinator() -> ViewableCoordinating {
    let viewControllerable = AppViewController()
    
    let home = HomeContainer(dependency: self)
    let searchChallenge = SearchChallengeContainer(dependency: self)
    let myPage = MyPageContainer(dependency: self)
    
    return AppCoordinator(
      viewControllerable: viewControllerable,
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
  
  lazy var findIdUseCase: FindIdUseCase = {
    return FindIdUseCaseImpl(repository: findIdRepository)
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
  
  lazy var endedChallengeUseCase: EndedChallengeUseCase = {
    return EndedChallengeUseCaseImpl(repository: challengeRepository)
  }()
  
  lazy var homeUseCae: HomeUseCase = {
    return HomeUseCaseImpl(repository: challengeRepository)
  }()
  
  lazy var challengeUseCase: ChallengeUseCase = {
    return ChallengeUseCaseImpl(repository: challengeRepository, authRepository: authRepository)
  }()
   
  lazy var feedUseCase: FeedUseCase = {
    return FeedUseCaseImpl(repository: challengeRepository)
  }()

  lazy var reportUseCase: ReportUseCase = {
    return ReportUseCaseImpl(repository: reportRepository)
  }()
  
  lazy var inquiryUseCase: InquiryUseCase = {
    return InquiryUseCaseImpl(repository: inquiryRepository)
  }()
  
  lazy var resignUsecase: ResignUseCase = {
    return ResignUseCaseImpl(repository: resignRepository)
  }()
  
  // MARK: - Repository
  lazy var authRepository: AuthRepository = {
    return AuthRepositoryImpl()
  }()
  
  lazy var logInRepository: LogInRepository = {
    return LogInRepositoryImpl(dataMapper: LogInDataMapperImpl())
  }()
  
  lazy var findIdRepository: FindIdRepository = {
    return FindIdRepositoryImpl(dataMapper: FindIdDataMapperImpl())
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
  
  lazy var reportRepository: ReportRepository = {
    return ReportRepositoryImpl(dataMapper: ReportDataMapperImpl())
  }()
  
  lazy var inquiryRepository: InquiryRepository = {
    return InquiryRepositoryImpl(dataMapper: InquiryDataMapperImpl())
  }()
  
  lazy var resignRepository: ResignRepository = {
    return ResignRepositoryImpl(dataMapper: ResignDataMapperImpl())
  }()
}

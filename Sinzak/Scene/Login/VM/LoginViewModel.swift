//
//  LoginVM.swift
//  Sinzak
//
//  Created by JongHoon on 2023/04/04.
//

import Alamofire
import AuthenticationServices
import Foundation
import NaverThirdPartyLogin
import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKUser
import SwiftKeychainWrapper

enum LoginState {
    case signIn
    case signUp
    case inProgress
}

protocol LoginViewModelInput {
    func kakaoButtonTapped()
    func naverButtonTapped()
    func appleButtonTapped()
    func didCompleteToSignInWithNaver()
    func controlAppleAuthorization(token: String)
}

protocol LoginViewModelOutput {
    var loginState: LoginState { get }
    var tabBarVCRelay: PublishRelay<TabBarVC> { get }
    var agreementVCRelay: PublishRelay<AgreementVC> { get }
    var showLoading: PublishRelay<Bool> { get }
    var errorHandler: PublishRelay<Error> { get }
}

protocol LoginViewModelType: ObservableObject, LoginViewModelInput, LoginViewModelOutput {}

final class LoginViewModel: LoginViewModelType {
    
    private let disposeBag = DisposeBag()
    
    let loginManager: SNSLoginManager = SNSLoginManager.shared
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    lazy var appleSignInDelegate: AppleSignInDelegate = {
        return AppleSignInDelegate(viewModel: self)
    }()
    lazy var naverSignInDelegate: NaverSignInDelegate = {
        return NaverSignInDelegate(viewModel: self)
    }()
    
    // MARK: - Output
    @Published var loginState: LoginState = .inProgress
    var tabBarVCRelay: PublishRelay<TabBarVC> = .init()
    var agreementVCRelay: PublishRelay<AgreementVC> = .init()
    var showLoading: PublishRelay<Bool> = .init()
    var errorHandler: PublishRelay<Error> = .init()
    
    // MARK: - Input
    func kakaoButtonTapped() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(
                    with: self,
                    onNext: { owner, oauthToken in
                        do {
                            try owner.authWithKakao(oauthToken: oauthToken)
                        } catch {
                            owner.errorHandler.accept(error)
                        }
                    },
                    onError: { owner, error in
                        owner.errorHandler.accept(error)
                    })
                .disposed(by: disposeBag)
            
        } else {
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(
                    with: self,
                    onNext: { owner, oauthToken in
                        do {
                            try owner.authWithKakao(oauthToken: oauthToken)
                        } catch {
                            owner.errorHandler.accept(error)
                        }
                    },
                    onError: { owner, error in
                        owner.errorHandler.accept(error)
                    })
                .disposed(by: disposeBag)
        }
    }
    
    func naverButtonTapped() {
        self.naverLoginInstance?.delegate = self.naverSignInDelegate
        self.naverLoginInstance?.requestThirdPartyLogin()
    }
    
    func appleButtonTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self.appleSignInDelegate
        authorizationController.presentationContextProvider = self.appleSignInDelegate
        authorizationController.performRequests()
    }
    
    func didCompleteToSignInWithNaver() {
        showLoading.accept(true)
        guard let accessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow(),
              accessToken,
              let accessToken = naverLoginInstance?.accessToken else { return }

        SNSLoginManager.shared.doNaverLogin(accessToken: accessToken)
            .subscribe(
                with: self,
                onSuccess: { owner, snsLoginGrant in
                    owner.showLoading.accept(false)
                    UserInfoManager.snsKind = SNS.naver.text
                    Log.debug("Access Token: \(snsLoginGrant.accessToken)")
                    Log.debug("Refresh Token: \(snsLoginGrant.refreshToken)")
                    if snsLoginGrant.joined {
                        owner.goTabBar(
                            accessToken: snsLoginGrant.accessToken,
                            refreshToken: snsLoginGrant.refreshToken
                        )
                    } else {
                        owner.goSignUp(
                            accessToken: snsLoginGrant.accessToken,
                            refreshToken: snsLoginGrant.refreshToken
                        )
                    }
                }, onFailure: { owner, error in
                    owner.errorHandler.accept(error)
                    owner.showLoading.accept(false)
                })
            .disposed(by: disposeBag)
    }
    
    func controlAppleAuthorization(token: String) {
        showLoading.accept(true)
        SNSLoginManager.shared.doAppleLogin(idToken: token)
            .subscribe(
                with: self,
                onSuccess: { owner, snsLoginGrant in
                    owner.showLoading.accept(false)
                    UserInfoManager.snsKind = SNS.apple.text
                    Log.debug("Access Token: \(snsLoginGrant.accessToken)")
                    Log.debug("Refresh Token: \(snsLoginGrant.refreshToken)")
                    SNSLoginManager.shared.getAppleClientSecret()
                    if snsLoginGrant.joined {
                        owner.goTabBar(
                            accessToken: snsLoginGrant.accessToken,
                            refreshToken: snsLoginGrant.refreshToken
                        )
                    } else {
                        owner.goSignUp(
                            accessToken: snsLoginGrant.accessToken,
                            refreshToken: snsLoginGrant.refreshToken
                        )
                    }
                }, onFailure: { owner, error in
                    owner.showLoading.accept(false)
                    owner.errorHandler.accept(error)
                })
            .disposed(by: disposeBag)
    }
}

extension LoginViewModel {
    private func authWithKakao(oauthToken: OAuthToken?) throws {
        showLoading.accept(true)
        if let token = oauthToken?.accessToken {
            Task {
                do {
                    UserInfoManager.snsKind = SNS.kakao.text
                    let snsLoginGrant = try await SNSLoginManager.shared.doKakaoLogin(accessToken: token)
                    
                    Log.debug("Access Token: \(snsLoginGrant.accessToken)")
                    Log.debug("Refresh Token: \(snsLoginGrant.refreshToken)")
                    if snsLoginGrant.joined {
                        goTabBar(
                            accessToken: snsLoginGrant.accessToken,
                            refreshToken: snsLoginGrant.refreshToken
                        )
                    } else {
                        goSignUp(
                            accessToken: snsLoginGrant.accessToken,
                            refreshToken: snsLoginGrant.refreshToken
                        )
                        showLoading.accept(false)
                    }
                } catch {
                    self.errorHandler.accept(error)
                    showLoading.accept(true)
                    throw error
                }
            }
        }
        showLoading.accept(false)
    }
    
    private func goTabBar(accessToken: String, refreshToken: String) {
        KeychainItem.saveTokenInKeychain(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        UserQueryManager.shared.fetchMyProfile()
            .observe(on: MainScheduler.instance)
            .subscribe(
                with: self,
                onSuccess: { owner, _ in
                    let vc = TabBarVC()
                    UserCommandManager.shared.getFCMToken()
                        .subscribe(
                            onSuccess: { _ in
                                Log.debug("Save FCM Token Success!")
                            },
                            onFailure: { error in
                                Log.error(error)
                            })
                        .disposed(by: owner.disposeBag)
                    owner.tabBarVCRelay.accept(vc)
                },
                onFailure: { owner, error in
                    owner.errorHandler.accept(error)
                })
            .disposed(by: disposeBag)
    }
    
    private func goSignUp(accessToken: String, refreshToken: String) {
        var onboardingUser = OnboardingUser()
        onboardingUser.accesToken = accessToken
        onboardingUser.refreshToken = refreshToken
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let vm = DefaultAgreementVM(onboardingUser: onboardingUser)
            let vc = AgreementVC(viewModel: vm)
            self.agreementVCRelay.accept(vc)
        }
    }
}

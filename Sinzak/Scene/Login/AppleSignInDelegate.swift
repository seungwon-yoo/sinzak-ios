//
//  AppleSignIn.swift
//  Sinzak
//
//  Created by 유승원 on 2023/07/15.
//

import AuthenticationServices
import UIKit
import SwiftKeychainWrapper

final class AppleSignInDelegate: NSObject {
    private let viewModel: LoginViewModel
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
}

extension AppleSignInDelegate: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let firstWindow = windowScene.windows.first else {
            assert(true)
            return ASPresentationAnchor()
        }
        
        return firstWindow
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let idToken = appleIDCredential.identityToken
            if let idToken = idToken {
                let strToken = String(decoding: idToken, as: UTF8.self)
                self.viewModel.controlAppleAuthorization(token: strToken)
            }
            let code = String(decoding: appleIDCredential.authorizationCode ?? Data(), as: UTF8.self)
            
            KeychainWrapper.standard.set(code, forKey: AppleAuth.appleAuthCode.rawValue)
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Log.error(error)
    }
}

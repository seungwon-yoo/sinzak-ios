//
//  NaverSignInDelegate.swift
//  Sinzak
//
//  Created by 유승원 on 2023/07/15.
//

import Foundation
import NaverThirdPartyLogin

final class NaverSignInDelegate: NSObject {
    private let viewModel: any LoginViewModelType
    init(viewModel: any LoginViewModelType) {
        self.viewModel = viewModel
    }
}

extension NaverSignInDelegate: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        Log.debug("네이버 로그인 성공!")
        self.viewModel.didCompleteToSignInWithNaver()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {}
    
    func oauth20ConnectionDidFinishDeleteToken() {
        Log.debug("네이버 로그아웃!")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        Log.error("에러 = \(error.localizedDescription)")
    }
}

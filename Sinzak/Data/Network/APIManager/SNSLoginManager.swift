//
//  SNSLoginManager.swift
//  Sinzak
//
//  Created by Doy Kim on 2023/03/05.
//

import Foundation
import Moya
import RxSwift
import SwiftKeychainWrapper

final class SNSLoginManager {
    private init () {}
    static let shared = SNSLoginManager()
    let provider = MoyaProvider<SNSLoginAPI>(
        callbackQueue: .global(),
        plugins: [MoyaLoggerPlugin.shared]
    )
    let disposeBag = DisposeBag()
}

// MARK: - Apple Login
extension SNSLoginManager {
    func doAppleLogin(idToken: String) -> Single<SNSLoginGrant> {
        return provider.rx.request(.apple(idToken: idToken))
            .map { response in
                
                Log.debug(response.request?.url ?? "")
                
                if !(200..<300 ~= response.statusCode) {
                    throw APIError.badStatus(code: response.statusCode)
                }
                
                do {
                    let snsLoginResultDTO = try JSONDecoder().decode(
                        SNSLoginResultDTO.self,
                        from: response.data
                    )
                    
                    guard let snsLoginGrantDTO = snsLoginResultDTO.data else {
                        throw APIError.noContent
                    }
                    return snsLoginGrantDTO.toDomain()
                } catch {
                    throw APIError.decodingError
                }
            }
            .retry(2)
    }
    
    func getAppleClientSecret() {
        provider.rx.request(.appleClientSecret)
            .map(BaseDTO<String>.self)
            .map({ secretDTO -> String in
                
                if !secretDTO.success {
                    throw APIError.errorMessage(secretDTO.message ?? "")
                }
                
                guard let clientSecret: String = secretDTO.data else {
                    throw APIError.noContent
                }
                
                KeychainWrapper.standard.set(clientSecret, forKey: AppleAuth.clientSecret.rawValue)
                return clientSecret
            })
            .subscribe(
                onSuccess: { clientSecret in
                    AppleAuthManager.shared.getAppleRefreshToken(authCode: clientSecret)
                    
                }, onFailure: { error in
                    Log.error(error)
                })
            .disposed(by: disposeBag)
    }
}

// MARK: - Kakao Login
extension SNSLoginManager {
    /// kakao 로그인
    func doKakaoLogin(accessToken: String) async throws -> SNSLoginGrant {
        var response: Response
        
        do {
            response = try await provider.rx.request(.kakao(accessToken: accessToken)).value
            Log.debug(response.request?.url ?? "")
        } catch {
            throw APIError.unknown(error)
        }
        
        if !(200..<300 ~= response.statusCode) {
            throw APIError.badStatus(code: response.statusCode)
        }
        
        do {
            let snsLoginResultDTO = try JSONDecoder().decode(
                SNSLoginResultDTO.self,
                from: response.data
            )
            
            guard let snsLoginGrantDTO = snsLoginResultDTO.data else {
                throw APIError.noContent
            }
            return snsLoginGrantDTO.toDomain()
            
        } catch {
            throw APIError.decodingError
        }
    }
}

// MARK: - Naver Login
extension SNSLoginManager {
    /// naver 로그인
    func doNaverLogin(accessToken: String) -> Single<SNSLoginGrant> {
        return provider.rx.request(.naver(accessToken: accessToken))
            .map { response in
    
                Log.debug(response.request?.url ?? "")
                
                if !(200..<300 ~= response.statusCode) {
                    throw APIError.badStatus(code: response.statusCode)
                }
                
                do {
                    let snsLoginResultDTO = try JSONDecoder().decode(
                        SNSLoginResultDTO.self,
                        from: response.data
                    )
                    
                    guard let snsLoginGrantDTO = snsLoginResultDTO.data else {
                        throw APIError.noContent
                    }
                    return snsLoginGrantDTO.toDomain()
                } catch {
                    throw APIError.decodingError
                }
            }
            .retry(2)
    }
}

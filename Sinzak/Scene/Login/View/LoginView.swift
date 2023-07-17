//
//  LoginView.swift
//  Sinzak
//
//  Created by 유승원 on 2023/06/28.
//  Copyright © 2023 Apple. All rights reserved.
//

import Combine
import SwiftUI
import AuthenticationServices

struct LoginView<T: LoginViewModelType>: View {
    // TODO: 로그인 성공했을 때 binding을 이용해서 화면 전환할 것.
    @ObservedObject var viewModel: T
    var dismissHandler: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("로그인 후에 만나볼 수 있어요")
                    .frame(width: 207, height: 90)
                    .foregroundColor(CustomColor.SwiftUI.label)
                    .font(.title_B)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                VStack(spacing: 10) {
                    Text("SNS 계정으로 간편하게 시작하기")
                        .foregroundColor(CustomColor.SwiftUI.gray80)
                        .font(.caption_R)
                    HStack(spacing: 16) {
                        Button {
                            self.viewModel.kakaoButtonTapped()
                        } label: {
                            Image("kakao_logo")
                        }
                        .frame(width: 59, height: 59)
                        Button {
                            self.viewModel.naverButtonTapped()
                        } label: {
                            Image("naver_logo")
                        }
                        .frame(width: 59, height: 59)
                        Button {
                            self.viewModel.appleButtonTapped()
                        } label: {
                            Image("apple_logo")
                        }
                        .frame(width: 59, height: 59)
                    }
                }
                .padding(.top, 185)
            }
            .padding(.top, 100)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.dismissHandler?()
                } label: {
                    Image("dismiss")
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}

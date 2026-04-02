//
//  LoginView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var viewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 36) {
                VStack(spacing: 12) {
                    Image(.appIco)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.bottom, 8)
                    
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                VStack(spacing: 24) {
                    VStack(spacing: 18) {
                        AppTextField(placeholder: "Email ID", text: $email, keyboardType: .emailAddress, autocapitalization: .never)
                        AppTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true
                        )
                    }
                    
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            showForgotPassword = true
                        }
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                    }
                }
                
                VStack(spacing: 20) {
                    AppButton(
                        title: "Sign In",
                        action: {
                            Task {
                                await viewModel.signIn(email: email, password: password)
                            }
                        },
                        isLoading: viewModel.isAuthenticating)
                    
                    HStack(spacing: 16) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                        Text("or").font(.footnote).foregroundColor(.secondary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                    }
                    
                    AppButton(title: "Sign in with Google", icon: .googleIco, action: {
                        Task { await viewModel.handleGoogleSignIn() }
                    }, style: .outline)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        showRegister = true
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                }
                .font(.subheadline)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 28)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
            .alert(
                "Error",
                isPresented: .init(
                    get: { viewModel.authError != nil
                    },
                    set: { _ in viewModel.authError = nil })
            ) {
                Button("OK") { viewModel.authError = nil }
            } message: {
                Text(viewModel.authError ?? "")
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}

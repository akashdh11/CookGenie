//
//  RegisterView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI

// MARK: View for registering a new account
struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthViewModel.self) private var viewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 36) {
            VStack(spacing: 12) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Join our culinary community")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                AppTextField(placeholder: "Full Name", text: $name, autocapitalization: .words)
                AppTextField(placeholder: "Email ID", text: $email, keyboardType: .emailAddress, autocapitalization: .never)
                AppTextField(placeholder: "Password", text: $password, isSecure: true, autocapitalization: .never)
                AppTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, autocapitalization: .never)
            }
            
            AppButton(title: "Sign Up", action: {
                guard password == confirmPassword else {
                    viewModel.authError = "Passwords do not match"
                    return
                }
                Task { await viewModel.signUp(email: email, password: password, name: name) }
            }, isLoading: viewModel.isAuthenticating)
            .padding(.top, 12)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundStyle(.secondary)
                Button("Sign In") {
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)
            }
            .font(.subheadline)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 28)
        .alert("Error", isPresented: .init(get: { viewModel.authError != nil }, set: { _ in viewModel.authError = nil })) {
            Button("OK") { viewModel.authError = nil }
        } message: {
            Text(viewModel.authError ?? "")
        }
    }
}

#Preview {
    RegisterView()
        .environment(AuthViewModel())
}

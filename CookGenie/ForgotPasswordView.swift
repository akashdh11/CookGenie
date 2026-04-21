//
//  ForgotPasswordView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI

//MARK: Forgot Password page
struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthViewModel.self) private var viewModel
    @State private var email = ""
    @State private var isSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 36) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 16) {
                    Image(systemName: "key.horizontal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Forgot Password?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your email address to receive a password reset link.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                if isSent {
                    VStack(spacing: 20) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentColor)
                        
                        Text("Link Sent!")
                            .font(.headline)
                        
                        Text("Check your inbox at \(email)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.05))
                    .cornerRadius(.cornerRadius)
                } else {
                    VStack(spacing: 24) {
                        AppTextField(placeholder: "Email Address", text: $email, keyboardType: .emailAddress, autocapitalization: .never)
                        
                        AppButton(title: "Send Reset Link", action: {
                            Task {
                                await viewModel.resetPassword(email: email)
                                if viewModel.authError == nil {
                                    withAnimation(.spring()) {
                                        isSent = true
                                    }
                                }
                            }
                        }, isLoading: viewModel.isAuthenticating)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 28)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.accentColor)
                }
            }
            .alert("Error", isPresented: .init(get: { viewModel.authError != nil }, set: { _ in viewModel.authError = nil })) {
                Button("OK") { viewModel.authError = nil }
            } message: {
                Text(viewModel.authError ?? "")
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environment(AuthViewModel())
}

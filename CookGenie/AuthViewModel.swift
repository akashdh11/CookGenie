//
//  AuthViewModel.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

@MainActor
@Observable
final class AuthViewModel {
    var currentUser: FirebaseAuth.User?
    var userName: String?
    var isAuthenticating = false
    var authError: String?

    init() {
        self.currentUser = Auth.auth().currentUser
        self.userName = self.currentUser?.displayName
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.userName = user?.displayName
            }
        }
    }

    func signIn(email: String, password: String) async {
        isAuthenticating = true
        authError = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            userName = result.user.displayName
        } catch {
            authError = error.localizedDescription
        }
        isAuthenticating = false
    }

    func signUp(email: String, password: String, name: String) async {
        isAuthenticating = true
        authError = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            self.userName = name
        } catch {
            authError = error.localizedDescription
        }
        isAuthenticating = false
    }

    func signOut(firestoreService: FirestoreService? = nil) {
        do {
            firestoreService?.stopAllListeners()

            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            currentUser = nil
            userName = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    func resetPassword(email: String) async {
        isAuthenticating = true
        authError = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            authError = error.localizedDescription
        }
        isAuthenticating = false
    }

    func handleGoogleSignIn() async {
        isAuthenticating = true
        authError = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            authError = "Could not find root view controller"
            isAuthenticating = false
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                 throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No ID Token"])
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: result.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)
            currentUser = authResult.user
            userName = authResult.user.displayName
        } catch {
            authError = error.localizedDescription
        }
        
        isAuthenticating = false
    }
}

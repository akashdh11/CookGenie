//
//  CookGenieApp.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI
import FirebaseCore

@main
struct CookGenieApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var firestoreService: FirestoreService
    @State private var recipeService: RecipeService

    init() {
        FirebaseApp.configure()
        self._authViewModel = State(wrappedValue: AuthViewModel())
        self._firestoreService = State(wrappedValue: FirestoreService())
        self._recipeService = State(wrappedValue: RecipeService())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(firestoreService)
                .environment(recipeService)
        }
    }
}

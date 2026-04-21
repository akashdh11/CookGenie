//
//  CookGenieApp.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct CookGenieApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var firestoreService: FirestoreService

    init() {
        FirebaseApp.configure()
        self._authViewModel = State(wrappedValue: AuthViewModel())
        self._firestoreService = State(wrappedValue: FirestoreService())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(firestoreService)
                .modelContainer(for: UserPreferences.self)
        }
    }
}

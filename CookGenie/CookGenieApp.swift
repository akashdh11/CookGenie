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
    
    init() {
        FirebaseApp.configure()
        self._authViewModel = State(wrappedValue: AuthViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
        }
    }
}

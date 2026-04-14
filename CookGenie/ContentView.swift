//
//  ContentView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/23/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @Environment(AuthViewModel.self) private var viewModel
    
    var body: some View {
        Group {
            if viewModel.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}

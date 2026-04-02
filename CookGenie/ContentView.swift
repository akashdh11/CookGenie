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
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            Group {
                if viewModel.currentUser != nil {
                    MainDashboardView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

struct MainDashboardView: View {
    @Environment(AuthViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "hand.sparkles.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Hello, \(viewModel.userName ?? "User")!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                AppButton(title: "Sign Out", action: {
                    viewModel.signOut()
                }, style: .outline)
                .padding(.top, 40)
            }
            .padding()
            .navigationTitle("CookGenie")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}

//
//  MainTabView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/25/26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(RecipeService.self) private var recipeService
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .tag(1)
                
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.circle.fill")
                    }
                    .tag(2)
            }
            .tint(.accentColor)

            if recipeService.isGenerating {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce.byLayer, options: .repeating)
                        Text("Conjuring your recipe...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(40)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .transition(.opacity.animation(.easeInOut))
                .zIndex(1)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthViewModel())
        .environment(RecipeService())
}

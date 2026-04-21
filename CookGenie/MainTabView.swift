//
//  MainTabView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import SwiftUI

//MARK: Tab view using .tag() to swap between the tabs
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
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
    }
}

#Preview {
    MainTabView()
        .environment(AuthViewModel())
}

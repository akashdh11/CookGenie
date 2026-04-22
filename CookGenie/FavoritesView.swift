//
//  FavoritesView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/25/26.
//

import SwiftUI
import FirebaseAuth

struct FavoritesView: View {
    @Environment(FirestoreService.self) private var firestoreService
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            Group {
                if firestoreService.favoriteRecipes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.accent.opacity(0.3))
                        Text("No Favorite Recipes")
                            .font(.title2).fontWeight(.bold)
                        Text("Tap the heart on any recipe to save it here.")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(firestoreService.favoriteRecipes) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeRow(
                                        title: recipe.title,
                                        duration: recipe.cookingTime,
                                        ingredients: recipe.ingredients.count,
                                        date: recipe.createdAt.formatted(.dateTime.month(.abbreviated).day()),
                                        icon: "heart.circle.fill"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("HomeBackground").ignoresSafeArea())
            .navigationTitle("Favorites")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .task {
                if let uid = authViewModel.currentUser?.uid {
                    firestoreService.startFavoritesListener(uid: uid)
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environment(FirestoreService())
        .environment(AuthViewModel())
}

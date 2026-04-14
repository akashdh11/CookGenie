//
//  HomeView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct HomeView: View {
    @State private var ingredients = ["Chicken", "Egg", "Onion", "Garlic"]
    @State private var showPreferences = false
    @State private var isAddingIngredient = false
    @State private var newIngredientName = ""
    @FocusState private var isTextFieldFocused: Bool

    @State private var recipeService = RecipeService()
    @State private var generatedRecipe: Recipe?
    @State private var navigateToDetail = false
    @State private var generationError: String?

    @Environment(FirestoreService.self) private var firestoreService
    @Environment(AuthViewModel.self) private var authViewModel

    // SwiftData for preferences only
    @Query private var userPreferences: [UserPreferences]
    private var currentPreferences: UserPreferences? {
        userPreferences.first(where: { $0.userId == authViewModel.currentUser?.uid })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("HomeBackground").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        ingredientSelectorCard
                        historySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                if recipeService.isGenerating {
                    loadingOverlay
                }
            }
            .sheet(isPresented: $showPreferences) {
                RecipePreferencesView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let recipe = generatedRecipe {
                    RecipeDetailView(recipe: recipe)
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .alert("Generation Failed", isPresented: .constant(generationError != nil)) {
                Button("OK") { generationError = nil }
            } message: {
                Text(generationError ?? "")
            }
            .onAppear {
                if let uid = authViewModel.currentUser?.uid {
                    firestoreService.startHistoryListener(uid: uid)
                }
            }
        }
    }

    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Conjuring your recipe...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            Text("Not sure what to\ncook tonight?")
                .font(.system(.title, design: .serif))
                .fontWeight(.bold)
                .lineSpacing(4)

            Spacer()

            Button {
                showPreferences = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .padding(12)
                        .background(Color("CardBackground"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)

                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .padding(4)
                }
            }
            .foregroundStyle(.primary)
        }
    }

    // MARK: - Ingredient Card
    private var ingredientSelectorCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .padding(10)
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("We'll conjure a recipe from your ingredients")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                FlowLayout(spacing: 8) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        TagView(title: ingredient) {
                            ingredients.removeAll(where: { $0 == ingredient })
                        }
                    }

                    if isAddingIngredient {
                        TextField("Ingredient...", text: $newIngredientName)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color("TagBackground").opacity(0.5))
                            .cornerRadius(12)
                            .focused($isTextFieldFocused)
                            .frame(width: 120)
                            .onSubmit {
                                let trimmed = newIngredientName.trimmingCharacters(in: .whitespaces)
                                if !trimmed.isEmpty {
                                    ingredients.append(trimmed)
                                }
                                newIngredientName = ""
                                isAddingIngredient = false
                            }
                    } else {
                        Button {
                            withAnimation {
                                isAddingIngredient = true
                                isTextFieldFocused = true
                            }
                        } label: {
                            Text("+ Add")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("CardBackground").opacity(0.3))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("CardBackground"))
            .cornerRadius(16)

            AppButton(title: "Generate Recipe", systemIcon: "sparkles", action: {
                generateAction()
            })
            .foregroundStyle(.white)
        }
        .padding(16)
        .background(Color("IngredientCardBackground"))
        .cornerRadius(24)
    }

    // MARK: - History Section
    private var historySection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "History", actionTitle: "See All") {}

            VStack(spacing: 12) {
                if firestoreService.historyRecipes.isEmpty {
                    Text("Generate your first recipe above!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(firestoreService.historyRecipes) { recipe in
                        NavigationLink(value: recipe) {
                            HistoryRow(
                                title: recipe.title,
                                duration: recipe.cookingTime,
                                ingredients: recipe.ingredients.count,
                                date: recipe.createdAt.formatted(.dateTime.month(.abbreviated).day()),
                                icon: "fork.knife.circle.fill"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Generation
    private func generateAction() {
        Task {
            do {
                let recipe = try await recipeService.generateRecipe(
                    ingredients: ingredients,
                    preferences: currentPreferences
                )
                self.generatedRecipe = recipe
                self.navigateToDetail = true
            } catch {
                self.generationError = error.localizedDescription
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthViewModel())
        .environment(FirestoreService())
}

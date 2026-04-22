//
//  HomeView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/25/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct HomeView: View {
    @State private var ingredients: [String] = []
    @State private var showPreferences = false
    @State private var isAddingIngredient = false
    @State private var newIngredientName = ""
    @FocusState private var isTextFieldFocused: Bool

    @State private var generatedRecipe: Recipe?
    @State private var generationError: String?

    @Environment(FirestoreService.self) private var firestoreService
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(RecipeService.self) private var recipeService
    private var recipePreferences = RecipePreferences.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    ingredientSelectorCard
                    historySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color("HomeBackground").ignoresSafeArea())
            .sheet(isPresented: $showPreferences) {
                NavigationStack{
                    RecipePreferencesView()
                        .presentationDetents([.large])
                        .navigationTitle("Recipe Preferences")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationDestination(item: $generatedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .alert("Generation Failed", isPresented: Binding(
                get: { generationError != nil },
                set: { if !$0 { generationError = nil } }
            )) {
                Button("OK") { generationError = nil }
            } message: {
                Text(generationError ?? "An unknown error occurred while conjuring your recipe.")
            }
            .task {
                if let uid = authViewModel.currentUser?.uid {
                    firestoreService.startHistoryListener(uid: uid)
                }
            }
        }
    }


    // MARK: Header
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

    // MARK: Ingredient Card
    private var ingredientSelectorCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .padding(10)
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Add your ingredients below")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption2)
                        Text("Tap the top right to set dietary preferences")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("CardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            AppButton(title: "Generate Recipe", systemIcon: "sparkles", action: {
                generateAction()
            })
            .foregroundStyle(.white)
        }
        .padding(16)
        .background(Color("IngredientCardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: History Section
    private var historySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("History")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }

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
                            RecipeRow(
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

    // MARK: Generate Button
    private func generateAction() {
        Task {
            do {
                let recipe = try await recipeService.generateRecipe(
                    ingredients: ingredients,
                    preferences: recipePreferences
                )
                self.generatedRecipe = recipe
            } catch {
                let nsError = error as NSError
                self.generationError = nsError.localizedDescription
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthViewModel())
        .environment(FirestoreService())
}

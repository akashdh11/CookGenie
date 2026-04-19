//
//  RecipeDetailView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import SwiftUI
import FirebaseAuth

struct RecipeDetailView: View {
    @Environment(FirestoreService.self) private var firestoreService
    @Environment(AuthViewModel.self) private var authViewModel

    let recipe: Recipe
    @State private var isFavorite: Bool
    @State private var selectedTab = 1

    init(recipe: Recipe) {
        self.recipe = recipe
        self._isFavorite = State(initialValue: recipe.isFavorite)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Hero
            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .foregroundStyle(.accent.opacity(0.12))
                    .padding(.top, 20)

                Text(recipe.title)
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(Color("HomeBackground"))

            // Section Picker
            Picker("Section", selection: $selectedTab) {
                Text("Detail").tag(0)
                Text("Ingredients").tag(1)
                Text("Instruction").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(uiColor: .systemBackground))
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 0.98, green: 0.93, blue: 0.80, alpha: 1)
            }

            // Sliding Content
            TabView(selection: $selectedTab) {
                detailTab.tag(0)
                ingredientsTab.tag(1)
                instructionTab.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .primary)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var shareText: String {
        let ingredientList = recipe.ingredients.map { "\($0.quantity) \($0.name)" }.joined(separator: "\n")
        return """
        \(recipe.title)

        \(recipe.description)

        Ingredients:
        \(ingredientList)

        Instructions:
        \(recipe.instructions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        """
    }

    // MARK: - Tabs

    private var detailTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)

                HStack(spacing: 12) {
                    Label(recipe.cookingTime, systemImage: "clock")
                    Label(recipe.difficulty, systemImage: "chart.bar")
                    Label("\(recipe.serves) Serves", systemImage: "person.2")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            }
            .padding(20)
        }
    }

    private var ingredientsTab: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(recipe.ingredients, id: \.name) { ingredient in
                    HStack(spacing: 14) {
                        Image(systemName: ingredient.iconName)
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(Color.accentColor.opacity(0.08))
                            .clipShape(Circle())

                        Text(ingredient.name)
                            .font(.body)

                        Spacer()

                        Text(ingredient.quantity)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    Divider().padding(.leading, 78)
                }
            }
        }
    }

    private var instructionTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(Color.accentColor)
                            .clipShape(Circle())

                        Text(step)
                            .font(.body)
                            .padding(.top, 3)
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Favorite Toggle
    private func toggleFavorite() {
        guard let uid = authViewModel.currentUser?.uid else { return }
        isFavorite.toggle()
        firestoreService.toggleFavorite(uid: uid, recipeId: recipe.id, isFavorite: isFavorite)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            title: "Indonesian Nasi Liwet",
            description: "A fragrant and savory rice dish.",
            ingredients: [RecipeIngredient(name: "Rice", quantity: "500gr")],
            instructions: ["Wash rice", "Cook in rice cooker"]
        ))
        .environment(FirestoreService())
        .environment(AuthViewModel())
    }
}

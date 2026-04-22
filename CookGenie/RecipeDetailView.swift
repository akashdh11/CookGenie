//
//  RecipeDetailView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/25/26.
//

import SwiftUI
import FirebaseAuth

struct RecipeDetailView: View {
    @Environment(FirestoreService.self) private var firestoreService
    @Environment(AuthViewModel.self) private var authViewModel
    
    let recipe: Recipe
    @State private var isFavorite: Bool
    @State private var selectedTab = 0
    @Namespace private var tabNamespace
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self._isFavorite = State(initialValue: recipe.isFavorite)
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "AccentColor")
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
        ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(recipe.title)
                    .font(.system(.title, design: .serif))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(24)
                
                
                Picker("Section", selection: $selectedTab) {
                    Text("Detail").tag(0)
                    Text("Ingredients").tag(1)
                    Text("Steps").tag(2)
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                Group {
                    if selectedTab == 0 {
                        detailTab
                    } else if selectedTab == 1 {
                        ingredientsTab
                    } else {
                        instructionTab
                    }
                }
                .transition(.opacity.animation(.easeInOut))
            }
        }
        .background(Color("HomeBackground").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .primary)
                }
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
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
    
    
    private var detailTab: some View {
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
    
    private var ingredientsTab: some View {
        VStack(spacing: 0) {
            ForEach(recipe.ingredients, id: \.name) { ingredient in
                HStack(spacing: 14) {
                    SafeIconView(systemName: ingredient.iconName)
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
    
    private var instructionTab: some View {
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

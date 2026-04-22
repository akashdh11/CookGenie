//
//  RecipePreferencesView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/26/26.
//

import SwiftUI
import FirebaseAuth

struct RecipePreferencesView: View {
    @Environment(\.dismiss) var dismiss
    private var recipePrefs = RecipePreferences.shared
    
    let timeOptions = ["Under 15 min", "Under 30 min", "Under 60 min"]
    let dietOptions = ["Vegan", "Vegetarian", "Pescatarian", "Keto", "Paleo", "Low-Carb"]
    let allergyOptions = ["Gluten", "Dairy", "Egg", "Soy", "Fish", "Peanut", "Tree Nut", "Shellfish"]
    let goalOptions = ["Eat Healthy", "Budget-Friendly", "Plan Better", "Learn to Cook", "Quick & Easy"]
    let dishTypeOptions = ["Breakfast", "Brunch", "Lunch", "Appetizers", "Snack", "Dessert", "Dinner", "Drinks"]
    
    var body: some View {
        VStack() {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    preferenceSection(title: "Time", options: timeOptions, selected: recipePrefs.selectedTime) { recipePrefs.selectedTime = $0 }
                    
                    preferenceSection(title: "Do you follow any of the following diets?", options: dietOptions, selected: recipePrefs.selectedDiet) { recipePrefs.selectedDiet = $0 }
                    
                    preferenceSection(title: "Any ingredients allergies or intolerance?", options: allergyOptions, selected: recipePrefs.selectedAllergy) { recipePrefs.selectedAllergy = $0 }
                    
                    preferenceSection(title: "What is your goal?", options: goalOptions, selected: recipePrefs.selectedGoal) { recipePrefs.selectedGoal = $0 }
                    
                    preferenceSection(title: "Dish Type", options: dishTypeOptions, selected: recipePrefs.selectedDishType) { recipePrefs.selectedDishType = $0 }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            actionButtons
        }
    }
    
    private func preferenceSection(title: String, options: [String], selected: String?, onSelect: @escaping (String?) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    SelectionChip(title: option, isSelected: selected == option) {
                        if selected == option {
                            onSelect(nil)
                        } else {
                            onSelect(option)
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                recipePrefs.clear()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                    Text("Clear All")
                }
                .font(.headline)
                .foregroundStyle(Color("ClearActionRed"))
            }
            
            AppButton(title: "Apply Filter") {
                dismiss()
            }
            .foregroundStyle(.white)
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
    }
}

#Preview {
    RecipePreferencesView()
}

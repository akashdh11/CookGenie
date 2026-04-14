//
//  RecipePreferencesView.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct RecipePreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthViewModel.self) private var authViewModel
    
    @Query private var preferences: [UserPreferences]
    
    // UI Options
    let timeOptions = ["Under 15 min", "Under 30 min", "Under 60 min"]
    let dietOptions = ["Vegan", "Vegetarian", "Pescatarian", "Keto", "Paleo", "Low-Carb"]
    let allergyOptions = ["Gluten", "Dairy", "Egg", "Soy", "Fish", "Peanut", "Tree Nut", "Shellfish"]
    let goalOptions = ["Eat Healthy", "Budget-Friendly", "Plan Better", "Learn to Cook", "Quick & Easy"]
    let dishTypeOptions = ["Breakfast", "Brunch", "Lunch", "Appetizers", "Snack", "Dessert", "Dinner", "Drinks"]
    
    var userPref: UserPreferences {
        if let existing = preferences.first(where: { $0.userId == authViewModel.currentUser?.uid }) {
            return existing
        } else {
            let new = UserPreferences(userId: authViewModel.currentUser?.uid ?? "anonymous")
            modelContext.insert(new)
            return new
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    preferenceSection(title: "Time", options: timeOptions, selected: userPref.selectedTime) { userPref.selectedTime = $0 }
                    
                    preferenceSection(title: "Do you follow any of the following diets?", options: dietOptions, selected: userPref.selectedDiet) { userPref.selectedDiet = $0 }
                    
                    preferenceSection(title: "Any ingredients allergies or intolerance?", options: allergyOptions, selected: userPref.selectedAllergy) { userPref.selectedAllergy = $0 }
                    
                    preferenceSection(title: "What is your goal?", options: goalOptions, selected: userPref.selectedGoal) { userPref.selectedGoal = $0 }
                    
                    preferenceSection(title: "Dish Type", options: dishTypeOptions, selected: userPref.selectedDishType) { userPref.selectedDishType = $0 }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            
            // Footer
            footer
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Text("Recipe Preferences")
                .font(.system(.headline, design: .serif))
                .fontWeight(.bold)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(uiColor: .systemBackground))
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
    
    private var footer: some View {
        VStack(spacing: 16) {
            Button {
                clearAll()
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
    
    private func clearAll() {
        userPref.selectedTime = nil
        userPref.selectedDiet = nil
        userPref.selectedAllergy = nil
        userPref.selectedGoal = nil
        userPref.selectedDishType = nil
    }
}


#Preview {
    RecipePreferencesView()
        .environment(AuthViewModel())
        .modelContainer(for: UserPreferences.self, inMemory: true)
}

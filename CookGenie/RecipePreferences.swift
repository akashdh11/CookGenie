//
//  RecipePreferences.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/26/26.
//

import Foundation

@Observable
class RecipePreferences {
    static let shared = RecipePreferences()
    
    private init() {}
    
    var selectedTime: String?
    var selectedDiet: String?
    var selectedAllergy: String?
    var selectedGoal: String?
    var selectedDishType: String?
    
    var isEmpty: Bool {
        selectedTime == nil &&
        selectedDiet == nil &&
        selectedAllergy == nil &&
        selectedGoal == nil &&
        selectedDishType == nil
    }
    
    func clear() {
        selectedTime = nil
        selectedDiet = nil
        selectedAllergy = nil
        selectedGoal = nil
        selectedDishType = nil
    }
}

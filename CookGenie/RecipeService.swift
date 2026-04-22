//
//  RecipeService.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/26/26.
//

import Foundation
import FirebaseFunctions
import FirebaseAuth

@Observable
final class RecipeService {
    @ObservationIgnored
    private let functions = Functions.functions(region: "us-central1")

    var isGenerating = false
    var error: String?

    func generateRecipe(ingredients: [String], preferences: RecipePreferences?) async throws -> Recipe {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        guard Auth.auth().currentUser != nil else {
            throw RecipeError.notAuthenticated
        }

        var prefDict: [String: Any] = [:]
        if let time = preferences?.selectedTime { prefDict["time"] = time }
        if let diet = preferences?.selectedDiet { prefDict["diet"] = diet }
        if let allergy = preferences?.selectedAllergy { prefDict["allergy"] = allergy }
        if let goal = preferences?.selectedGoal { prefDict["goal"] = goal }
        if let dishType = preferences?.selectedDishType { prefDict["dishType"] = dishType }

        let payload: [String: Any] = [
            "ingredients": ingredients,
            "preferences": prefDict
        ]

        let result = try await functions.httpsCallable("generateRecipe").call(payload)

        guard let data = result.data as? [String: Any],
              let recipeDict = data["recipe"] as? [String: Any],
              let recipe = Recipe(firestoreData: recipeDict) else {
            throw RecipeError.invalidResponse
        }

        return recipe
    }
}

enum RecipeError: LocalizedError {
    case notAuthenticated
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Please sign in to generate recipes."
        case .invalidResponse: return "Received an unexpected response. Please try again."
        }
    }
}

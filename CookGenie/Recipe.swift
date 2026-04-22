//
//  Recipe.swift
//  CookGenie
//
//  Created by Akash Hiremath on 3/25/26.
//

import Foundation

struct RecipeIngredient: Codable, Hashable {
    var name: String
    var quantity: String
    var iconName: String

    init(name: String, quantity: String, iconName: String = "fork.knife") {
        self.name = name
        self.quantity = quantity
        self.iconName = iconName
    }
}

struct Recipe: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var cookingTime: String
    var difficulty: String
    var serves: Int
    var isFavorite: Bool
    var ingredients: [RecipeIngredient]
    var instructions: [String]
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, cookingTime, difficulty, serves,
             isFavorite, ingredients, instructions, createdAt
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        cookingTime: String = "20 Min",
        difficulty: String = "Easy",
        serves: Int = 2,
        isFavorite: Bool = false,
        ingredients: [RecipeIngredient] = [],
        instructions: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.serves = serves
        self.isFavorite = isFavorite
        self.ingredients = ingredients
        self.instructions = instructions
        self.createdAt = createdAt
    }

    // MARK: Firestore deserialization
    init?(firestoreData data: [String: Any]) {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String else { return nil }

        self.id = id
        self.title = title
        self.description = data["description"] as? String ?? ""
        self.cookingTime = data["cookingTime"] as? String ?? ""
        self.difficulty = data["difficulty"] as? String ?? ""
        self.serves = data["serves"] as? Int ?? 2
        self.isFavorite = data["isFavorite"] as? Bool ?? false
        self.instructions = data["instructions"] as? [String] ?? []

        if let ts = data["createdAt"] as? [String: Any],
           let seconds = ts["_seconds"] as? TimeInterval {
            self.createdAt = Date(timeIntervalSince1970: seconds)
        } else {
            self.createdAt = Date()
        }

        if let rawIngredients = data["ingredients"] as? [[String: Any]] {
            self.ingredients = rawIngredients.compactMap { dict in
                guard let name = dict["name"] as? String,
                      let quantity = dict["quantity"] as? String else { return nil }
                let iconName = dict["iconName"] as? String
                return RecipeIngredient(
                    name: name,
                    quantity: quantity,
                    iconName: (iconName == nil || iconName!.isEmpty) ? "fork.knife" : iconName!
                )
            }
        } else {
            self.ingredients = []
        }
    }

    // MARK: Firestore serialization
    func toFirestoreData() -> [String: Any] {
        [
            "id": id,
            "title": title,
            "description": description,
            "cookingTime": cookingTime,
            "difficulty": difficulty,
            "serves": serves,
            "isFavorite": isFavorite,
            "ingredients": ingredients.map { ["name": $0.name, "quantity": $0.quantity, "iconName": $0.iconName] },
            "instructions": instructions
        ]
    }
}

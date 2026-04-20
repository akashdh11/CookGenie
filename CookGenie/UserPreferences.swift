//
//  UserPreferences.swift
//  CookGenie
//
//  Created by Akash Hiremath on 4/13/26.
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
    var userId: String
    var selectedTime: String?
    var selectedDiet: String?
    var selectedAllergy: String?
    var selectedGoal: String?
    var selectedDishType: String?
    
    init(userId: String) {
        self.userId = userId
    }
}


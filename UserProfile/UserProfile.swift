//
//  User.swift
//  Recipe_Tinder
//
//  Model for user data and preferences
//  Updated 2/24/26
//  Updated 3/3/26
//  COMPLETE FIX: Proper initialization with all preference fields
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable, Equatable {
    var id: String
    let userId: String
    var displayName: String?
    var email: String?
    
    var preferredCuisines: [String]
    var dietaryRestrictions: [String]
    var healthPreferences: [String]
    var dislikedIngredients: [String]
    
    var savedRecipeIds: [String]
    var dislikedRecipeIds: [String]
    
    var notificationsEnabled: Bool
    var createdAt: Date
    var lastActive: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case displayName
        case email
        case preferredCuisines
        case dietaryRestrictions
        case healthPreferences
        case dislikedIngredients
        case savedRecipeIds
        case dislikedRecipeIds
        case notificationsEnabled
        case createdAt
        case lastActive
    }
    
    init(userId: String,
         displayName: String? = nil,
         email: String? = nil,
         preferredCuisines: [String] = [],
         dietaryRestrictions: [String] = [],
         healthPreferences: [String] = [],
         dislikedIngredients: [String] = [],
         savedRecipeIds: [String] = [],
         dislikedRecipeIds: [String] = [],
         notificationsEnabled: Bool = true) {
        self.id = userId
        self.userId = userId
        self.displayName = displayName
        self.email = email
        self.preferredCuisines = preferredCuisines
        self.dietaryRestrictions = dietaryRestrictions
        self.healthPreferences = healthPreferences
        self.dislikedIngredients = dislikedIngredients
        self.savedRecipeIds = savedRecipeIds
        self.dislikedRecipeIds = dislikedRecipeIds
        self.notificationsEnabled = notificationsEnabled
        self.createdAt = Date()
        self.lastActive = Date()
    }
    
    mutating func addSavedRecipe(_ recipeId: String) {
        if !savedRecipeIds.contains(recipeId) {
            savedRecipeIds.append(recipeId)
        }
    }
    
    mutating func removeSavedRecipe(_ recipeId: String) {
        savedRecipeIds.removeAll { $0 == recipeId }
    }
    
    mutating func addDislikedRecipe(_ recipeId: String) {
        if !dislikedRecipeIds.contains(recipeId) {
            dislikedRecipeIds.append(recipeId)
        }
    }
    
    func hasSeenRecipe(_ recipeId: String) -> Bool {
        savedRecipeIds.contains(recipeId) || dislikedRecipeIds.contains(recipeId)
    }
}

extension UserProfile {
    static let collectionName = "users"
}

extension UserProfile {
    static let availableCuisines = [
        "American", "Asian", "British", "Caribbean", "Central Europe",
        "Chinese", "Eastern Europe", "French", "Greek", "Indian",
        "Italian", "Japanese", "Korean", "Kosher", "Mediterranean",
        "Mexican", "Middle Eastern", "Nordic", "South American",
        "South East Asian", "World"
    ]
    
    static let availableDietaryRestrictions = [
        "Balanced", "High-Fiber", "High-Protein", "Low-Carb",
        "Low-Fat", "Low-Sodium"
    ]
    
    static let availableHealthLabels = [
        "Vegan", "Vegetarian", "Paleo", "Dairy-Free", "Gluten-Free",
        "Wheat-Free", "Egg-Free", "Peanut-Free", "Tree-Nut-Free",
        "Soy-Free", "Fish-Free", "Shellfish-Free", "Pork-Free",
        "Red-Meat-Free", "Crustacean-Free", "Celery-Free",
        "Mustard-Free", "Sesame-Free", "Lupine-Free", "Mollusk-Free",
        "Alcohol-Free", "No oil added", "Low Sugar", "Keto-Friendly",
        "Kidney-Friendly", "Kosher", "Low Potassium", "Sugar-Conscious"
    ]
}

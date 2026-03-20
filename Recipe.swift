//  Created by Stella K on 2/3/26
//  Recipe.swift
//  Data model for recipes
//  UPDATED: Removed RecipeSearchResponse to avoid conflict with Spoonacular
//  Uodated by Stella K on 2/12/26

import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    var id: String
    var label: String
    var image: String
    var source: String
    var url: String
    var cuisineType: [String]
    var mealType: [String]
    var dishType: [String]
    var ingredientLines: [String]
    var calories: Double
    var totalTime: Double
    var dietLabels: [String]
    var healthLabels: [String]
    var yield: Int
   
    var caloriesPerServing: Int {
        Int(calories / Double(yield))
    }
    
    var prepTimeText: String {
        if totalTime > 0 {
            return "\(Int(totalTime)) mins"
        }
        return "Time not specified"
    }
    
    var cuisineText: String {
        cuisineType.first?.capitalized ?? "International"
    }
    
    init(id: String = UUID().uuidString,
         label: String,
         image: String,
         source: String,
         url: String,
         cuisineType: [String] = [],
         mealType: [String] = [],
         dishType: [String] = [],
         ingredientLines: [String],
         calories: Double,
         totalTime: Double = 0,
         dietLabels: [String] = [],
         healthLabels: [String] = [],
         yield: Int = 4) {
        self.id = id
        self.label = label
        self.image = image
        self.source = source
        self.url = url
        self.cuisineType = cuisineType
        self.mealType = mealType
        self.dishType = dishType
        self.ingredientLines = ingredientLines
        self.calories = calories
        self.totalTime = totalTime
        self.dietLabels = dietLabels
        self.healthLabels = healthLabels
        self.yield = yield
    }
}

extension Recipe {
    static let mockRecipe = Recipe(
        label: "Chicken Tikka Masala",
        image: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800",
        source: "Test Kitchen",
        url: "https://example.com",
        cuisineType: ["Indian"],
        mealType: ["dinner"],
        dishType: ["main course"],
        ingredientLines: [
            "2 lbs chicken breast",
            "1 cup yogurt",
            "2 tbsp garam masala"
        ],
        calories: 1800,
        totalTime: 45,
        dietLabels: ["High-Protein"],
        healthLabels: ["Gluten-Free"],
        yield: 4
    )
}

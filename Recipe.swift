//  Created by Stella K on 2/3/26
//  Recipe.swift
//  Data model for recipes
//  UPDATED: Removed RecipeSearchResponse to avoid conflict with Spoonacular
//  Uodated by Stella K on 2/12/26

import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let image: String
    let source: String
    let url: String
    let cuisineType: [String]
    let mealType: [String]
    let dishType: [String]
    let ingredientLines: [String]
    let calories: Double
    let totalTime: Double
    let dietLabels: [String]
    let healthLabels: [String]
    let yield: Int
    
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
        cuisineType: ["indian"],
        mealType: ["dinner"],
        dishType: ["main course"],
        ingredientLines: [
            "2 lbs chicken breast",
            "1 cup yogurt",
            "2 tbsp garam masala",
            "1 can tomato sauce",
            "1 cup heavy cream",
            "Fresh cilantro"
        ],
        calories: 1800,
        totalTime: 45,
        dietLabels: ["High-Protein"],
        healthLabels: ["Gluten-Free"],
        yield: 4
    )
    
    static let mockRecipes: [Recipe] = [
        mockRecipe,
        Recipe(
            label: "Spaghetti Carbonara",
            image: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=800",
            source: "Italian Classics",
            url: "https://example.com",
            cuisineType: ["italian"],
            mealType: ["dinner"],
            dishType: ["main course"],
            ingredientLines: [
                "1 lb spaghetti",
                "4 eggs",
                "1 cup parmesan cheese",
                "8 oz pancetta",
                "Black pepper"
            ],
            calories: 2080,
            totalTime: 30,
            yield: 4
        ),
        Recipe(
            label: "Caesar Salad",
            image: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800",
            source: "Fresh Eats",
            url: "https://example.com",
            cuisineType: ["american"],
            mealType: ["lunch"],
            dishType: ["salad"],
            ingredientLines: [
                "1 head romaine lettuce",
                "1/2 cup caesar dressing",
                "1/2 cup croutons",
                "1/4 cup parmesan cheese"
            ],
            calories: 1120,
            totalTime: 15,
            healthLabels: ["Vegetarian"],
            yield: 4
        )
    ]
}

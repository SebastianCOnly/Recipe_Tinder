//
//  SwipeInteraction.swift
//  Recipe_Tinder
//  Created by Stella K on 1/27/26
//  Updated by Stella K on 1/29/26
//  Model for tracking user swipe interactions
//

import Foundation
import FirebaseFirestore

enum SwipeDirection: String, Codable {
    case right = "liked"
    case left = "disliked"
    case up = "superLiked"
}

struct SwipeInteraction: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let recipeId: String
    let recipeLabel: String
    let direction: SwipeDirection
    let timestamp: Date
    
    let cuisineType: [String]
    let mealType: [String]
    let dishType: [String]
    let dietLabels: [String]
    let healthLabels: [String]
    
    var isLiked: Bool {
        direction == .right || direction == .up
    }
    
    init(userId: String,
         recipe: Recipe,
         direction: SwipeDirection) {
        self.userId = userId
        self.recipeId = recipe.id
        self.recipeLabel = recipe.label
        self.direction = direction
        self.timestamp = Date()
        self.cuisineType = recipe.cuisineType
        self.mealType = recipe.mealType
        self.dishType = recipe.dishType
        self.dietLabels = recipe.dietLabels
        self.healthLabels = recipe.healthLabels
    }
}

extension SwipeInteraction {
    static let collectionName = "swipeInteractions"
}

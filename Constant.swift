//  Created by Stella K on 1/29/26
//
//  App-wide constants and configuration
//

import Foundation

enum AppConstants {
    enum API {
        static let edamamAppId = "f1f15cb8"
        static let edamamAppKey = "67760485a453bd74f03d0770c6772daa"
        static let baseURL = "https://www.edamam.com/recipes"
        
        static let maxRequestsPerMinute = 10
        static let batchDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
    }
    
    enum Firebase {
        static let usersCollection = "users"
        static let swipeInteractionsCollection = "swipeInteractions"
        static let savedRecipesCollection = "savedRecipes"
    }
    
    enum UI {
        static let cardWidth: CGFloat = 350
        static let cardHeight: CGFloat = 500
        static let cardCornerRadius: CGFloat = 20
        static let swipeThreshold: CGFloat = 100
        static let rotationFactor: Double = 0.1
        
        static let cardAnimationDuration: Double = 0.3
        static let swipeAnimationDuration: Double = 0.5
    }
    
    enum Recommendation {
        static let minRecipesForCollaborativeFiltering = 10
        static let similarityThreshold: Double = 0.3
        static let engagementWeight: Double = 0.4
        static let contentSimilarityWeight: Double = 0.4
        static let collaborativeWeight: Double = 0.2
        
        static let initialBatchSize = 20
        static let refetchThreshold = 5 
    }
    
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userId = "userId"
        static let lastSyncDate = "lastSyncDate"
    }
}

enum ErrorMessages {
    static let networkError = "Unable to connect. Please check your internet connection."
    static let apiKeyMissing = "API configuration error. Please contact support."
    static let authenticationFailed = "Authentication failed. Please try again."
    static let genericError = "Something went wrong. Please try again."
}

//
//  CardsViewModel.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//    Updated by Stella K on 1/30/26

import Foundation\\
import SwiftUI

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cardModels = [CardModel]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userProfile: UserProfile?
    
    private let service: CardService
    private let refetchThreshold = 5
    
    init(service: CardService = CardService(), userProfile: UserProfile? = nil){
        self.service = service
        self.userProfile = userProfile
        Task {
            await fetchCardModels()
        }
    }
    
     func fetchCardModels() async {
        isLoading = true
        errorMessage = nil
         
        do {
            self.cardModels = try await service.fetchCardModels(for: userProfile,
                useMockData: true) //Set to false when API is ready
        } catch {
            errorMessage = handleError(error)
            print("Error fetching cards: \(error)")
        }
    }
    
    func removeCard(_ card: CardModel) {
        guard let index = cardModels.firstIndex(where: { $0.id == card.id }) else { return }
        cardModels.remove(at: index)

        if cardModels.count <= refetchThreshold {
            Task {
                await fetchMoreCards()
    }
}

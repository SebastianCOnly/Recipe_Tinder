//
//  OnboardingPreferencesView.swift
//  Recipe_Tinder
//  Created by Stella K 2/24/26
//  Preferences selection during sign-up onboarding
//

import SwiftUI

struct OnboardingPreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedHealthPreferences: Set<String> = []
    @State private var dislikedIngredients: String = ""
    @State private var currentStep = 0
    @State private var isLoading = false
    
    let totalSteps = 4
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .tint(.pink)
                    .padding()
                
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                TabView(selection: $currentStep) {
                    cuisinePreferencesStep
                        .tag(0)
                    
                    dietaryRestrictionsStep
                        .tag(1)
                    
                    healthPreferencesStep
                        .tag(2)
                    
                    dislikedIngredientsStep
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                navigationButtons
            }
            .navigationTitle("Personalize Your Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        finishOnboarding()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    
    private var cuisinePreferencesStep: some View {
        PreferenceSelectionView(
            title: "What cuisines do you enjoy?",
            subtitle: "Select all that apply",
            options: UserProfile.availableCuisines,
            selectedOptions: $selectedCuisines,
            icon: "🌍"
        )
    }
    
    private var dietaryRestrictionsStep: some View {
        PreferenceSelectionView(
            title: "Any dietary restrictions?",
            subtitle: "We'll filter recipes accordingly",
            options: UserProfile.availableDietaryRestrictions,
            selectedOptions: $selectedDietaryRestrictions,
            icon: "🥗"
        )
    }
    
    private var healthPreferencesStep: some View {
        PreferenceSelectionView(
            title: "Health preferences",
            subtitle: "Choose what matters to you",
            options: UserProfile.availableHealthLabels,
            selectedOptions: $selectedHealthPreferences,
            icon: "❤️"
        )
    }
    
    private var dislikedIngredientsStep: some View {
        VStack(spacing: 20) {
            // Icon and title
            VStack(spacing: 12) {
                Text("🚫")
                    .font(.system(size: 60))
                
                Text("Ingredients to avoid")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter ingredients you don't like, separated by commas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Disliked Ingredients")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("e.g., mushrooms, olives, cilantro", text: $dislikedIngredients, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }
            
            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    savePreferences()
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(currentStep < totalSteps - 1 ? "Next" : "Get Started!")
                            .fontWeight(.semibold)
                        if currentStep < totalSteps - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
        }
        .padding()
    }
    
    private func savePreferences() {
        guard var profile = authManager.userProfile else { return }
        
        isLoading = true
        
        profile.preferredCuisines = Array(selectedCuisines)
        profile.dietaryRestrictions = Array(selectedDietaryRestrictions)
        profile.healthPreferences = Array(selectedHealthPreferences)
        profile.dislikedIngredients = dislikedIngredients
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        Task {
            do {
                try await authManager.updateUserProfile(profile)
                isLoading = false
                finishOnboarding()
            } catch {
                isLoading = false
                print("Error saving preferences: \(error)")
            }
        }
    }
    
    private func finishOnboarding() {

        dismiss()
    }
}

struct PreferenceSelectionView: View {
    let title: String
    let subtitle: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    let icon: String
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 60))
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
        
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        PreferenceChip(
                            title: option,
                            isSelected: selectedOptions.contains(option)
                        ) {
                            toggleSelection(option)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func toggleSelection(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}

struct PreferenceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.pink : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
                )
        }
    }
}

#Preview {
    OnboardingPreferencesView()
        .environmentObject(AuthenticationManager.shared)
}

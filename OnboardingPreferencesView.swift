//
//  OnboardingPreferencesView.swift
//  Recipe_Tinder
//  Created by Stella K 2/24/26
//  Preferences selection during sign-up onboarding
//  COMPLETELY FIXED: Proper preference saving with error handling 3/5/26

import SwiftUI
import FirebaseFirestore

struct OnboardingPreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedHealthPreferences: Set<String> = []
    @State private var dislikedIngredients: String = ""
    @State private var currentStep = 0
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let totalSteps = 4
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .tint(.pink)
                    .padding()
                
                // Step indicator
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                // Content
                TabView(selection: $currentStep) {
                    cuisinePreferencesStep.tag(0)
                    dietaryRestrictionsStep.tag(1)
                    healthPreferencesStep.tag(2)
                    dislikedIngredientsStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("Personalize Your Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        skipOnboarding()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .alert("Error Saving Preferences", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
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
        print("🔥 SAVE: Starting savePreferences()")
        print("   isAuthenticated: \(authManager.isAuthenticated)")
        print("   currentUser: \(authManager.currentUser?.uid ?? "NIL")")
        print("   userProfile: \(authManager.userProfile != nil ? "EXISTS" : "NIL")")
        
        guard authManager.isAuthenticated, let userId = authManager.currentUser?.uid else {
            print("❌ SAVE: Not authenticated!")
            errorMessage = "You are not signed in. Please restart the app."
            showError = true
            return
        }
        
        print("✅ SAVE: User authenticated: \(userId)")
        
        isLoading = true
        
        if authManager.userProfile == nil {
            print("🚨 EMERGENCY: Profile is nil, creating emergency profile...")
            
            Task {
                do {
                    let cuisines = Array(selectedCuisines)
                    let dietary = Array(selectedDietaryRestrictions)
                    let health = Array(selectedHealthPreferences)
                    let ingredients = dislikedIngredients
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    
                    print("📊 EMERGENCY: Creating profile with preferences:")
                    print("   Cuisines: \(cuisines)")
                    print("   Dietary: \(dietary)")
                    print("   Health: \(health)")
                    
                    let profileData: [String: Any] = [
                        "id": userId,
                        "userId": userId,
                        "displayName": authManager.currentUser?.displayName ?? "",
                        "email": authManager.currentUser?.email ?? "",
                        "preferredCuisines": cuisines,
                        "dietaryRestrictions": dietary,
                        "healthPreferences": health,
                        "dislikedIngredients": ingredients,
                        "savedRecipeIds": [],
                        "dislikedRecipeIds": [],
                        "notificationsEnabled": true,
                        "createdAt": Timestamp(date: Date()),
                        "lastActive": Timestamp(date: Date())
                    ]
                    
                    print("💾 EMERGENCY: Writing directly to Firestore...")
                    
                    try await Firestore.firestore()
                        .collection("users")
                        .document(userId)
                        .setData(profileData, merge: true)
                    
                    print("✅ EMERGENCY: Saved successfully!")
                    
                    await authManager.loadUserProfile(userId: userId)
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    
                    await MainActor.run {
                        print("🔍 EMERGENCY: After reload, profile is: \(authManager.userProfile != nil ? "SET" : "STILL NIL")")
                        isLoading = false
                        finishOnboarding()
                    }
                    
                } catch {
                    print("❌ EMERGENCY: Failed!")
                    print("   Error: \(error)")
                    
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Emergency save failed. Error: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
            return
        }
        
        print("✅ SAVE: Profile exists, using normal save")
        normalSavePreferences()
    }
    
    private func normalSavePreferences() {
        guard var profile = authManager.userProfile else {
            print("❌ NORMAL SAVE: Profile became nil!")
            errorMessage = "Profile error. Please try again."
            showError = true
            return
        }
        
        print("✅ NORMAL SAVE: Proceeding with normal save")
        
        let cuisines = Array(selectedCuisines)
        let dietary = Array(selectedDietaryRestrictions)
        let health = Array(selectedHealthPreferences)
        let ingredients = dislikedIngredients
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        print("📊 NORMAL SAVE: Preferences:")
        print("   Cuisines: \(cuisines)")
        print("   Dietary: \(dietary)")
        print("   Health: \(health)")
        
        profile.preferredCuisines = cuisines
        profile.dietaryRestrictions = dietary
        profile.healthPreferences = health
        profile.dislikedIngredients = ingredients
        
        Task {
            do {
                print("💾 NORMAL SAVE: Calling updateUserProfile...")
                try await authManager.updateUserProfile(profile)
                
                print("✅ NORMAL SAVE: Success!")
                
                await MainActor.run {
                    isLoading = false
                    finishOnboarding()
                }
                
            } catch {
                print("❌ NORMAL SAVE: Failed!")
                print("   Error: \(error)")
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func skipOnboarding() {
        print("⏭️ SKIP: User skipped onboarding")
        finishOnboarding()
    }
    
    private func finishOnboarding() {
        print("🏁 FINISH: Onboarding complete")
        print("   Final cuisines: \(authManager.userProfile?.preferredCuisines ?? [])")
        print("   Final dietary: \(authManager.userProfile?.dietaryRestrictions ?? [])")
        print("   Final health: \(authManager.userProfile?.healthPreferences ?? [])")
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
            print("➖ Deselected: \(option). Total: \(selectedOptions.count)")
        } else {
            selectedOptions.insert(option)
            print("➕ Selected: \(option). Total: \(selectedOptions.count)")
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

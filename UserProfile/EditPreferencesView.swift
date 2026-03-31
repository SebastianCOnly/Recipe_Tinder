//
//  EditPreferencesView.swift
//  Recipe_Tinder
//
//  Edit user preferences from profile tab
//  Created Stella K 2/24/26

import SwiftUI

struct EditPreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedHealthPreferences: Set<String> = []
    @State private var dislikedIngredientsText: String = ""
    @State private var isLoading = false
    @State private var showingSaveSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PreferenceMultiSelectSection(
                        title: "Preferred Cuisines",
                        options: UserProfile.availableCuisines,
                        selectedOptions: $selectedCuisines
                    )
                } header: {
                    Label("Cuisine Preferences", systemImage: "globe")
                } footer: {
                    Text("Select cuisines you enjoy")
                }
                
                Section {
                    PreferenceMultiSelectSection(
                        title: "Dietary Restrictions",
                        options: UserProfile.availableDietaryRestrictions,
                        selectedOptions: $selectedDietaryRestrictions
                    )
                } header: {
                    Label("Dietary Restrictions", systemImage: "leaf")
                } footer: {
                    Text("Recipes will be filtered accordingly")
                }
                
                Section {
                    PreferenceMultiSelectSection(
                        title: "Health Preferences",
                        options: UserProfile.availableHealthLabels,
                        selectedOptions: $selectedHealthPreferences
                    )
                } header: {
                    Label("Health Preferences", systemImage: "heart")
                } footer: {
                    Text("Choose health labels that matter to you")
                }
                
                Section {
                    TextField("e.g., mushrooms, olives, cilantro",
                             text: $dislikedIngredientsText,
                             axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Label("Disliked Ingredients", systemImage: "xmark.circle")
                } footer: {
                    Text("Separate multiple ingredients with commas")
                }
            }
            .navigationTitle("Edit Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        savePreferences()
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Preferences Saved!", isPresented: $showingSaveSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your preferences have been updated successfully.")
            }
            .onAppear {
                loadCurrentPreferences()
            }
        }
    }
    
    private func loadCurrentPreferences() {
        guard let profile = authManager.userProfile else { return }
        
        selectedCuisines = Set(profile.preferredCuisines)
        selectedDietaryRestrictions = Set(profile.dietaryRestrictions)
        selectedHealthPreferences = Set(profile.healthPreferences)
        dislikedIngredientsText = profile.dislikedIngredients.joined(separator: ", ")
    }
    
    private func savePreferences() {
        guard var profile = authManager.userProfile else { return }
        
        isLoading = true
        
        profile.preferredCuisines = Array(selectedCuisines)
        profile.dietaryRestrictions = Array(selectedDietaryRestrictions)
        profile.healthPreferences = Array(selectedHealthPreferences)
        profile.dislikedIngredients = dislikedIngredientsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        Task {
            do {
                try await authManager.updateUserProfile(profile)
                isLoading = false
                showingSaveSuccess = true
            } catch {
                isLoading = false
                print("Error saving preferences: \(error)")
            }
        }
    }
}

struct PreferenceMultiSelectSection: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    
    var body: some View {
        ForEach(options, id: \.self) { option in
            Button {
                toggleSelection(option)
            } label: {
                HStack {
                    Text(option)
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedOptions.contains(option) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.pink)
                            .fontWeight(.semibold)
                    }
                }
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

#Preview {
    EditPreferencesView()
        .environmentObject(AuthenticationManager.shared)
}

//
//  DietaryPreferencesView.swift
//  Recipe_Tinder
//
//  View for editing dietary preferences from profile
//  Created Stella K 3/17/2026

import SwiftUI
import FirebaseFirestore

struct DietaryPreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDietary: Set<String> = []
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("🥗")
                    .font(.system(size: 60))
                
                Text("Dietary Restrictions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(selectedDietary.count) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Dietary Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(UserProfile.availableDietaryRestrictions, id: \.self) { dietary in
                        PreferenceChip(
                            title: dietary,
                            isSelected: selectedDietary.contains(dietary)
                        ) {
                            toggleDietary(dietary)
                        }
                    }
                }
                .padding()
            }
            
            // Save Button
            Button {
                savePreferences()
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isSaving)
            .padding()
        }
        .navigationTitle("Dietary Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPreferences()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Dietary preferences saved!")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func toggleDietary(_ dietary: String) {
        if selectedDietary.contains(dietary) {
            selectedDietary.remove(dietary)
        } else {
            selectedDietary.insert(dietary)
        }
    }
    
    private func loadPreferences() {
        print("📥 DIETARY: Loading preferences")
        
        guard let profile = authManager.userProfile else {
            print("❌ DIETARY: No profile!")
            return
        }
        
        print("✅ DIETARY: Loaded \(profile.dietaryRestrictions.count) items")
        selectedDietary = Set(profile.dietaryRestrictions)
    }
    
    private func savePreferences() {
        guard let userId = authManager.currentUser?.uid else {
            errorMessage = "Not signed in"
            showError = true
            return
        }
        
        isSaving = true
        let dietary = Array(selectedDietary)
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .setData([
                        "dietaryRestrictions": dietary,
                        "lastActive": Timestamp(date: Date())
                    ], merge: true)
                
                await authManager.loadUserProfile(userId: userId)
                
                await MainActor.run {
                    isSaving = false
                    showSuccess = true
                }
                
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to save"
                    showError = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DietaryPreferencesView()
            .environmentObject(AuthenticationManager.shared)
    }
}

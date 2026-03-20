//
//  HealthPreferencesView.swift
//  Recipe_Tinder
//
//  View for editing health preferences from profile
//  Created by Stella K 3/17/26

import SwiftUI
import FirebaseFirestore

struct HealthPreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedHealth: Set<String> = []
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("❤️")
                    .font(.system(size: 60))
                
                Text("Health Preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(selectedHealth.count) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(UserProfile.availableHealthLabels, id: \.self) { health in
                        PreferenceChip(
                            title: health,
                            isSelected: selectedHealth.contains(health)
                        ) {
                            toggleHealth(health)
                        }
                    }
                }
                .padding()
            }
            
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
        .navigationTitle("Health Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPreferences()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Health preferences saved successfully!")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func toggleHealth(_ health: String) {
        if selectedHealth.contains(health) {
            selectedHealth.remove(health)
        } else {
            selectedHealth.insert(health)
        }
    }
    
    private func loadPreferences() {
        print("📥 HEALTH: Loading preferences")
        
        guard let profile = authManager.userProfile else {
            print("❌ HEALTH: No profile!")
            return
        }
        
        print("✅ HEALTH: Loaded \(profile.healthPreferences.count) items")
        selectedHealth = Set(profile.healthPreferences)
    }
    
    private func savePreferences() {
        guard let userId = authManager.currentUser?.uid else {
            errorMessage = "Not signed in"
            showError = true
            return
        }
        
        isSaving = true
        let health = Array(selectedHealth)
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .setData([
                        "healthPreferences": health,
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
        HealthPreferencesView()
            .environmentObject(AuthenticationManager.shared)
    }
}

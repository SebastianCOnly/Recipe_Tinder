//
//  CuisinePreferencesView.swift
//  Recipe_Tinder
//
//  View for editing cuisine preferences from profile creatd by Stella K 3/17/26
//

import SwiftUI
import FirebaseFirestore

struct CuisinePreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCuisines: Set<String> = []
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("🌍")
                    .font(.system(size: 60))
                
                Text("Cuisine Preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(selectedCuisines.count) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(UserProfile.availableCuisines, id: \.self) { cuisine in
                        PreferenceChip(
                            title: cuisine,
                            isSelected: selectedCuisines.contains(cuisine)
                        ) {
                            toggleCuisine(cuisine)
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
        .navigationTitle("Cuisine Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPreferences()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Cuisines saved successfully!")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func toggleCuisine(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }
    
    private func loadPreferences() {
        print("📥 CUISINE: Loading preferences")
        
        guard let profile = authManager.userProfile else {
            print("❌ CUISINE: No profile!")
            return
        }
        
        print("✅ CUISINE: Loaded \(profile.preferredCuisines.count) items")
        selectedCuisines = Set(profile.preferredCuisines)
    }
    
    private func savePreferences() {
        guard let userId = authManager.currentUser?.uid else {
            errorMessage = "Not signed in"
            showError = true
            return
        }
        
        isSaving = true
        let cuisines = Array(selectedCuisines)
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .setData([
                        "preferredCuisines": cuisines,
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
        CuisinePreferencesView()
            .environmentObject(AuthenticationManager.shared)
    }
}

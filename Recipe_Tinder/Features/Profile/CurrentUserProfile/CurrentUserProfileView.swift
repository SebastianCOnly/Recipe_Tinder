//
//  CurrentUserProfileView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 2/6/26.
//  Updated by Stella K 2/24/26

import SwiftUI

struct CurrentUserProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    let user: User
    
    @State private var showingEditPreferences = false
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                CurrentUserProfileHeaderView(user: user)
                    .listRowBackground(Color.clear)
                
                Section {
                    Button {
                        showingEditPreferences = true
                    } label: {
                        HStack {
                            Label("Dietary Preferences", systemImage: "leaf.fill")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if let profile = authManager.userProfile {
                                let count = profile.preferredCuisines.count +
                                           profile.dietaryRestrictions.count +
                                           profile.healthPreferences.count
                                
                                if count > 0 {
                                    Text("\(count) selected")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Preferences")
                }
                
                Section("Account Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(authManager.userProfile?.displayName ?? user.username)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authManager.userProfile?.email ?? "Not set")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Your Activity") {
                    HStack {
                        Label("Saved Recipes", systemImage: "heart.fill")
                        Spacer()
                        Text("\(authManager.userProfile?.savedRecipeIds.count ?? 0)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Recipes Swiped", systemImage: "hand.point.up.left.fill")
                        Spacer()
                        Text("\(totalSwipes)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Settings") {
                    Toggle(isOn: .constant(true)) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    .tint(.pink)
                }
                
                Section("Legal") {
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Text("Terms of Service")
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text("Privacy Policy")
                    }
                }
                
                Section {
                    Button("Logout") {
                        showingSignOutAlert = true
                    }
                    .foregroundStyle(.red)
                    
                    Button("Delete Account") {
                        showingDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditPreferences) {
                EditPreferencesView()
                    .environmentObject(authManager)
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all your data. This action cannot be undone.")
            }
        }
    }
    
    private var totalSwipes: Int {
        guard let profile = authManager.userProfile else { return 0 }
        return profile.savedRecipeIds.count + profile.dislikedRecipeIds.count
    }
    
    private func signOut() {
        do {
            try authManager.signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    private func deleteAccount() {
        Task {
            do {
                try await authManager.deleteAccount()
            } catch {
                print("Error deleting account: \(error)")
            }
        }
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("""
                Welcome to Recipe Tinder!
                
                By using our app, you agree to these terms of service.
                
                1. Use of Service
                Recipe Tinder provides a platform for discovering recipes through a swipe-based interface.
                
                2. User Accounts
                You are responsible for maintaining the confidentiality of your account credentials.
                
                3. Content
                All recipe content is sourced from third-party APIs and their respective owners.
                
                4. Privacy
                We take your privacy seriously. Please review our Privacy Policy for details on how we handle your data.
                
                5. Modifications
                We reserve the right to modify these terms at any time.
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("""
                Recipe Tinder Privacy Policy
                
                1. Information We Collect
                - Account information (email, display name)
                - Recipe preferences and dietary restrictions
                - Recipe interaction data (likes, dislikes)
                
                2. How We Use Your Information
                - To provide personalized recipe recommendations
                - To improve our service
                - To communicate with you about updates
                
                3. Data Storage
                Your data is securely stored using Firebase services.
                
                4. Data Sharing
                We do not sell or share your personal information with third parties.
                
                5. Your Rights
                You have the right to:
                - Access your data
                - Delete your account
                - Export your data
                
                6. Contact Us
                For privacy-related questions, please contact us through the app.
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CurrentUserProfileView(user: MockData.users[0])
        .environmentObject(AuthenticationManager.shared)
}

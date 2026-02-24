//
//  AuthenticationRootView.swift
//  Recipe_Tinder
//
//  Created by Stella K on 1/29/26
//  Root view that manages authentication state
//
//  UPDATED: Handles onboarding flow properly 2/24/26
//

import SwiftUI

struct AuthenticationRootView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var isCheckingProfile = true
    @State private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if isCheckingProfile {
                    ProgressView("Loading...")
                } else if needsOnboarding && !hasCompletedOnboarding {
                    OnboardingPreferencesView()
                        .environmentObject(authManager)
                        .onDisappear {
                            hasCompletedOnboarding = true
                        }
                } else {
                    MainTabView()
                        .environmentObject(authManager)
                }
            } else {
                SignInView()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, newValue in
            if newValue {
                checkProfile()
            } else {
                isCheckingProfile = true
                hasCompletedOnboarding = false
            }
        }
        .onChange(of: authManager.userProfile) { _, newProfile in
            if newProfile != nil {
                isCheckingProfile = false
            }
        }
        .task {
            if authManager.isAuthenticated {
                checkProfile()
            }
        }
    }
    
    private var needsOnboarding: Bool {
        guard let profile = authManager.userProfile else {
            return true
        }
        
        return profile.preferredCuisines.isEmpty &&
               profile.dietaryRestrictions.isEmpty &&
               profile.healthPreferences.isEmpty
    }
    
    private func checkProfile() {
        print("DEBUG: Checking profile...")
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                if authManager.userProfile != nil {
                    isCheckingProfile = false
                    print("DEBUG: Profile loaded. Needs onboarding: \(needsOnboarding)")
                } else {
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 more second
                        await MainActor.run {
                            isCheckingProfile = false
                            print("DEBUG: Profile check complete. Needs onboarding: \(needsOnboarding)")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AuthenticationRootView()
}

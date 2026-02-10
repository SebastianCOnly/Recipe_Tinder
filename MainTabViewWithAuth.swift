//  MainTabView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/27/26
//  Enhanced by Stella K on 2/10/26 - Added auth support and complete tabs
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CardStackView()
                .tabItem {
                    Label("Discover", systemImage: selectedTab == 0 ? "flame.fill" : "flame")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: selectedTab == 1 ? "magnifyingglass" : "magnifyingglass")
                }
                .tag(1)
            
            SavedRecipesView()
                .tabItem {
                    Label("Saved", systemImage: selectedTab == 2 ? "heart.fill" : "heart")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(.pink)
    }
}

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCuisine: String?
    @State private var selectedMealType: String?
    
    let cuisines = ["All", "Italian", "Mexican", "Asian", "American", "Mediterranean", "Indian"]
    let mealTypes = ["All", "Breakfast", "Lunch", "Dinner", "Snack"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search recipes...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cuisine")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(cuisines, id: \.self) { cuisine in
                                        Button {
                                            selectedCuisine = cuisine
                                        } label: {
                                            Text(cuisine)
                                                .font(.subheadline)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedCuisine == cuisine ? Color.pink : Color(.systemGray6))
                                                .foregroundColor(selectedCuisine == cuisine ? .white : .primary)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Meal Type")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(mealTypes, id: \.self) { mealType in
                                        Button {
                                            selectedMealType = mealType
                                        } label: {
                                            Text(mealType)
                                                .font(.subheadline)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedMealType == mealType ? Color.pink : Color(.systemGray6))
                                                .foregroundColor(selectedMealType == mealType ? .white : .primary)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Search for Recipes")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Use the search bar and filters above to find specific recipes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

struct SavedRecipesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            Group {
                if let profile = authManager.userProfile,
                   !profile.savedRecipeIds.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(profile.savedRecipeIds, id: \.self) { recipeId in
                                SavedRecipeCard(recipeId: recipeId)
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        
                        Text("No Saved Recipes Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Swipe right on recipes you love to save them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {

                        } label: {
                            Text("Start Discovering")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.pink)
                                .cornerRadius(25)
                        }
                    }
                }
            }
            .navigationTitle("Saved Recipes")
        }
    }
}

struct SavedRecipeCard: View {
    let recipeId: String
    
    var body: some View {
        HStack(spacing: 12) {

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Recipe Title")
                    .font(.headline)
                
                Text("Cuisine • Time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("XXX cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                if let user = authManager.currentUser {
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.pink)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName ?? "User")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text(user.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if let profile = authManager.userProfile {
                    Section("My Recipe Stats") {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                            Text("Saved Recipes")
                            Spacer()
                            Text("\(profile.savedRecipeIds.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "hand.thumbsdown.fill")
                                .foregroundColor(.gray)
                            Text("Passed Recipes")
                            Spacer()
                            Text("\(profile.dislikedRecipeIds.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Preferences") {
                    NavigationLink {
                        PreferencesView()
                    } label: {
                        Label("Dietary Preferences", systemImage: "leaf")
                    }
                    
                    NavigationLink {
                        Text("Cuisine Preferences")
                    } label: {
                        Label("Cuisine Preferences", systemImage: "globe")
                    }
                    
                    NavigationLink {
                        Text("Health Preferences")
                    } label: {
                        Label("Health Preferences", systemImage: "heart.text.square")
                    }
                }
                
                Section("Settings") {
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        Text("About")
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.circle")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAccountAlert = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        try? await authManager.deleteAccount()
                    }
                }
            } message: {
                Text("This will permanently delete your account and all your data. This action cannot be undone.")
            }
        }
    }
}

struct PreferencesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedRestrictions: Set<String> = []
    
    var body: some View {
        List {
            Section("Dietary Restrictions") {
                ForEach(UserProfile.availableDietaryRestrictions, id: \.self) { restriction in
                    Button {
                        if selectedRestrictions.contains(restriction) {
                            selectedRestrictions.remove(restriction)
                        } else {
                            selectedRestrictions.insert(restriction)
                        }
                    } label: {
                        HStack {
                            Text(restriction)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedRestrictions.contains(restriction) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.pink)
                            }
                        }
                    }
                }
            }
            
            Section {
                Button("Save Preferences") {
                    Task {
                        await savePreferences()
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.pink)
            }
        }
        .navigationTitle("Dietary Preferences")
        .onAppear {
            if let profile = authManager.userProfile {
                selectedRestrictions = Set(profile.dietaryRestrictions)
            }
        }
    }
    
    private func savePreferences() async {
        guard var profile = authManager.userProfile else { return }
        profile.dietaryRestrictions = Array(selectedRestrictions)
        try? await authManager.updateUserProfile(profile)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager.shared)
}

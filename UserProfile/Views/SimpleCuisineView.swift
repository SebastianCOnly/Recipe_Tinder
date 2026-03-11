//
//  SimpleCuisineView.swift
//  Created by Stella K 3/10/26

import SwiftUI
import FirebaseFirestore

struct SimpleCuisineView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    let allCuisines = ["American", "Asian", "British", "Caribbean", "Chinese", 
                       "French", "Greek", "Indian", "Italian", "Japanese", 
                       "Korean", "Mediterranean", "Mexican", "Thai", "Vietnamese"]
    
    @State private var selected: [String] = []
    @State private var saving = false
    
    var body: some View {
        VStack {
            Text("🌍 Cuisines").font(.largeTitle).padding()
            
            Text("\(selected.count) selected").foregroundColor(.gray)
            
            List {
                ForEach(allCuisines, id: \.self) { cuisine in
                    Button {
                        toggle(cuisine)
                    } label: {
                        HStack {
                            Text(cuisine)
                                .foregroundColor(.primary)
                            Spacer()
                            if selected.contains(cuisine) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.pink)
                            }
                        }
                    }
                }
            }
            
            Button("Save") {
                save()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            .disabled(saving)
        }
        .onAppear {
            load()
        }
    }
    
    func toggle(_ cuisine: String) {
        if let index = selected.firstIndex(of: cuisine) {
            selected.remove(at: index)
        } else {
            selected.append(cuisine)
        }
        print("✓ \(cuisine) - Total: \(selected.count)")
    }
    
    func load() {
        if let prefs = authManager.userProfile?.preferredCuisines {
            selected = prefs
            print("📥 Loaded: \(prefs)")
        }
    }
    
    func save() {
        guard let uid = authManager.currentUser?.uid else { return }
        saving = true
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .updateData(["preferredCuisines": selected])
                
                await authManager.loadUserProfile(userId: uid)
                print("✅ Saved: \(selected)")
                
                await MainActor.run {
                    saving = false
                    dismiss()
                }
            } catch {
                print("❌ Error: \(error)")
                await MainActor.run { saving = false }
            }
        }
    }
}

//
//  SimpleHealthView.swift
//  Created by Stella K 3/10/26
//

import SwiftUI
import FirebaseFirestore

struct SimpleHealthView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    let allHealth = ["Vegan", "Vegetarian", "Paleo", "Dairy-Free", "Gluten-Free",
                     "Wheat-Free", "Egg-Free", "Soy-Free", "Fish-Free", 
                     "Shellfish-Free", "Tree-Nut-Free", "Peanut-Free"]
    
    @State private var selected: [String] = []
    @State private var saving = false
    
    var body: some View {
        VStack {
            Text("❤️ Health").font(.largeTitle).padding()
            
            Text("\(selected.count) selected").foregroundColor(.gray)
            
            List {
                ForEach(allHealth, id: \.self) { health in
                    Button {
                        toggle(health)
                    } label: {
                        HStack {
                            Text(health)
                                .foregroundColor(.primary)
                            Spacer()
                            if selected.contains(health) {
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
    
    func toggle(_ health: String) {
        if let index = selected.firstIndex(of: health) {
            selected.remove(at: index)
        } else {
            selected.append(health)
        }
        print("✓ \(health) - Total: \(selected.count)")
    }
    
    func load() {
        if let prefs = authManager.userProfile?.healthPreferences {
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
                    .updateData(["healthPreferences": selected])
                
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

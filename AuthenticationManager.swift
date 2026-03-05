//
//  AuthenticationManager.swift
//  Recipe_Tinder
//  Updated by Stella K 2/17/26
//  FIXED: Updated for current Firebase Auth API
//  Updated 2/24/26
//  UPDATED: Fixed delete account flow to prevent onboarding loop
//  updated 3/3/26

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case userNotFound
    case networkError
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknownError(let message):
            return message
        }
    }
}

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var currentUser: FirebaseAuth.User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isDeletingAccount = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if let user = user, !(self?.isDeletingAccount ?? false) {
                    await self?.loadUserProfile(userId: user.uid)
                }
            }
        }
    }
    
    func signUp(email: String, password: String, displayName: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔥 SIGNUP: Creating Firebase Auth user...")
            
            let result = try await auth.createUser(withEmail: email, password: password)
            
            print("✅ SIGNUP: Auth user created: \(result.user.uid)")
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            print("✅ SIGNUP: Display name set")
            
            let profile = UserProfile(
                userId: result.user.uid,
                displayName: displayName,
                email: email,
                preferredCuisines: [],
                dietaryRestrictions: [],
                healthPreferences: [],
                dislikedIngredients: [],
                savedRecipeIds: [],
                dislikedRecipeIds: []
            )
            
            print("📊 SIGNUP: Profile object created")
            print("💾 SIGNUP: Saving to Firestore...")
            
            try await createUserProfile(profile)
            
            print("✅ SIGNUP: Saved to Firestore")
            
            self.currentUser = result.user
            self.userProfile = profile
            
            print("✅ SIGNUP: Local state set")
            print("🔍 SIGNUP: userProfile is now: \(self.userProfile != nil ? "SET" : "NIL")")
            
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            print("✅ SIGNUP: Sign-up complete!")
            
            isLoading = false
            
        } catch let error as NSError {
            print("❌ SIGNUP: Failed!")
            print("   Error: \(error)")
            isLoading = false
            throw mapAuthError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        guard !password.isEmpty else {
            throw AuthError.weakPassword
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            
            self.currentUser = result.user
            await loadUserProfile(userId: result.user.uid)
            
            isLoading = false
            
        } catch let error as NSError {
            isLoading = false
            throw mapAuthError(error)
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            
            self.currentUser = nil
            self.userProfile = nil
            self.isAuthenticated = false
            
        } catch {
            throw AuthError.unknownError("Failed to sign out")
        }
    }
    
    func resetPassword(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            isLoading = false
        } catch let error as NSError {
            isLoading = false
            throw mapAuthError(error)
        }
    }
    
    func deleteAccount() async throws {
        guard let user = currentUser else {
            throw AuthError.userNotFound
        }
        
        isDeletingAccount = true
        isLoading = true
        
        do {
            try await db.collection(UserProfile.collectionName)
                .document(user.uid)
                .delete()
            
            let interactions = try await db.collection(SwipeInteraction.collectionName)
                .whereField("userId", isEqualTo: user.uid)
                .getDocuments()
            
            for document in interactions.documents {
                try await document.reference.delete()
            }
            
            try await user.delete()
            
            self.currentUser = nil
            self.userProfile = nil
            self.isAuthenticated = false
            
            isLoading = false
            isDeletingAccount = false
            
        } catch let error as NSError {
            isLoading = false
            isDeletingAccount = false
            throw mapAuthError(error)
        }
    }
    
    private func createUserProfile(_ profile: UserProfile) async throws {
        print("💾 CREATE: Creating user profile...")
        print("   User ID: \(profile.userId)")
        
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(profile)
            
            print("📊 CREATE: Encoded data keys: \(data.keys)")
            
            try await db.collection(UserProfile.collectionName)
                .document(profile.userId)
                .setData(data, merge: false)
            
            print("✅ CREATE: Profile created in Firestore")
            
            let doc = try await db.collection(UserProfile.collectionName)
                .document(profile.userId)
                .getDocument()
            
            if doc.exists {
                print("✅ CREATE: Verified - document exists in Firestore")
            } else {
                print("❌ CREATE: WARNING - Document not found after creation!")
            }
            
        } catch {
            print("❌ CREATE: Failed to create profile!")
            print("   Error: \(error)")
            throw error
        }
    }
    
    func loadUserProfile(userId: String) async {
        print("🔄 LOAD: Loading profile for \(userId)")
        
        for attempt in 1...3 {
            print("🔄 LOAD: Attempt \(attempt) of 3")
            
            do {
                let document = try await db.collection(UserProfile.collectionName)
                    .document(userId)
                    .getDocument()
                
                if document.exists {
                    print("✅ LOAD: Document found!")
                    
                    let loadedProfile = try document.data(as: UserProfile.self)
                    
                    await MainActor.run {
                        self.userProfile = loadedProfile
                        print("✅ LOAD: Profile loaded successfully")
                        print("   Cuisines: \(loadedProfile.preferredCuisines)")
                    }
                    
                    return
                    
                } else {
                    print("⚠️ LOAD: Document doesn't exist (attempt \(attempt))")
                    
                    if attempt < 3 {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                    } else {
                        print("⚠️ LOAD: Creating default profile...")
                        
                        let profile = UserProfile(
                            userId: userId,
                            displayName: currentUser?.displayName,
                            email: currentUser?.email
                        )
                        
                        try await createUserProfile(profile)
                        
                        await MainActor.run {
                            self.userProfile = profile
                            print("✅ LOAD: Default profile created")
                        }
                    }
                }
                
            } catch {
                print("❌ LOAD: Error on attempt \(attempt): \(error)")
                
                if attempt < 3 {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                } else {
                    print("❌ LOAD: All attempts failed")
                }
            }
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        print("🔥 UPDATE: updateUserProfile called")
        
        guard let userId = currentUser?.uid else {
            print("❌ UPDATE: No current user!")
            throw AuthError.userNotFound
        }
        
        print("✅ UPDATE: User ID: \(userId)")
        print("📊 UPDATE: Preferences to save:")
        print("   Cuisines: \(profile.preferredCuisines)")
        print("   Dietary: \(profile.dietaryRestrictions)")
        print("   Health: \(profile.healthPreferences)")
        
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(profile)
            
            print("💾 UPDATE: Writing to Firestore...")
            
            try await db.collection(UserProfile.collectionName)
                .document(userId)
                .setData(data, merge: true)
            
            print("✅ UPDATE: Firestore write successful!")
            
            await MainActor.run {
                self.userProfile = profile
                print("✅ UPDATE: Local profile updated")
                print("🔍 UPDATE: Verification - cuisines: \(self.userProfile?.preferredCuisines ?? [])")
            }
            
        } catch {
            print("❌ UPDATE: Failed!")
            print("   Error: \(error)")
            throw error
        }
    }
    
    private func mapAuthError(_ error: NSError) -> AuthError {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .unknownError(error.localizedDescription)
        }
        
        switch code {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .wrongPassword:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .networkError
        default:
            return .unknownError(error.localizedDescription)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}

//
//  AuthenticationManager.swift
//  Recipe_Tinder
//  Updated by Stella K 2/17/26
//  FIXED: Updated for current Firebase Auth API
//  Updated 2/24/26

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
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
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
            let result = try await auth.createUser(withEmail: email, password: password)
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            let profile = UserProfile(
                userId: result.user.uid,
                displayName: displayName,
                email: email
            )

            print("DEBUG AUTH: Creating profile: \(profile)")
            try await createUserProfile(profile)

            self.currentUser = result.user
            self.userProfile = profile
            print("DEBUG AUTH: Profile set. Cuisines: \(profile.preferredCuisines.count)")
            print("DEBUG AUTH: isAuthenticated: \(self.isAuthenticated)")
            
            try await createUserProfile(profile)
            
            self.currentUser = result.user
            self.userProfile = profile
            
            isLoading = false
            
        } catch let error as NSError {
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
            
        } catch let error as NSError {
            isLoading = false
            throw mapAuthError(error)
        }
    }
    
    private func createUserProfile(_ profile: UserProfile) async throws {
        try db.collection(UserProfile.collectionName)
            .document(profile.userId)
            .setData(from: profile)
    }
    
    func loadUserProfile(userId: String) async {
        do {
            let document = try await db.collection(UserProfile.collectionName)
                .document(userId)
                .getDocument()
            
            if document.exists {
                self.userProfile = try document.data(as: UserProfile.self)
            } else {
                // Create default profile if doesn't exist
                let profile = UserProfile(
                    userId: userId,
                    displayName: currentUser?.displayName,
                    email: currentUser?.email
                )
                try await createUserProfile(profile)
                self.userProfile = profile
            }
        } catch {
            print("Error loading user profile: \(error.localizedDescription)")
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let userId = currentUser?.uid else {
            throw AuthError.userNotFound
        }
        
        try db.collection(UserProfile.collectionName)
            .document(userId)
            .setData(from: profile)
        
        self.userProfile = profile
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

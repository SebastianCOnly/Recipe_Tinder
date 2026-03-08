//
//  SignUpView.swift
//  Created by Stella K on 2/17/26
//  New user registration interface
//  UPDATED: Now shows onboarding after sign-up 2/24/26

import SwiftUI

struct SignUpView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        headerView
                        
                        signUpForm
                        
                        signInLink
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.pink)
            
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Join Recipe Tinder to discover your next favorite meal")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private var signUpForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Display Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your name", text: $displayName)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter your email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Create a password", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                
                if !password.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(password.count >= 6 ? .green : .red)
                            .font(.caption)
                        Text("At least 6 characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Confirm your password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                
                if !confirmPassword.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(password == confirmPassword ? .green : .red)
                            .font(.caption)
                        Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Button {
                Task {
                    await signUp()
                }
            } label: {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.pink : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!isFormValid || authManager.isLoading)
        }
        .padding(.horizontal)
    }
    
    private var signInLink: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(.secondary)
            
            Button {
                dismiss()
            } label: {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
            }
        }
        .font(.subheadline)
        .padding(.top, 16)
    }
    
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func signUp() async {
        do {
            try await authManager.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignUpView()
}

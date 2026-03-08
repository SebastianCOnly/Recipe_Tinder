//
//  SignUpView.swift
//  Created by Stella K on 2/17/26
//  New user registration interface
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        signUpForm
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Account")
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
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.pink)
            
            Text("Join Recipe Tinder")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start discovering amazing recipes")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    private var signUpForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Your name", text: $displayName)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("your@email.com", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                
                if !email.isEmpty && !authManager.isValidEmail(email) {
                    Text("Please enter a valid email")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("At least 6 characters", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                
                if !password.isEmpty && !authManager.isValidPassword(password) {
                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Re-enter password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                
                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundColor(.red)
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
                        Text("Create Account")
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
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        authManager.isValidEmail(email) &&
        authManager.isValidPassword(password) &&
        password == confirmPassword
    }
    
    private func signUp() async {
        do {
            try await authManager.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignUpView()
}

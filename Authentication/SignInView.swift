//
//  SignInView.swift
//  Recipe_Tinder
//
//  Created by Stella K on 2/12/26
//  User sign in interface
//

import SwiftUI

struct SignInView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @State private var showingSignUp = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo/Header
                        headerView
                        
                        // Sign In Form
                        signInForm
                        
                        // Forgot Password
                        forgotPasswordButton
                        
                        // Sign Up Link
                        signUpLink
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
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
                .font(.system(size: 80))
                .foregroundStyle(.pink)
            
            Text("Recipe Tinder")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Discover your next favorite meal")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
        .padding(.bottom, 40)
    }
    
    private var signInForm: some View {
        VStack(spacing: 16) {
            // Email field
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
                
                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
            }
            
            Button {
                Task {
                    await signIn()
                }
            } label: {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
        }
        .padding(.horizontal)
    }
    
    private var forgotPasswordButton: some View {
        Button {
            showingForgotPassword = true
        } label: {
            Text("Forgot Password?")
                .font(.subheadline)
                .foregroundColor(.pink)
        }
        .padding(.top, 8)
    }
    
    private var signUpLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.secondary)
            
            Button {
                showingSignUp = true
            } label: {
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
            }
        }
        .font(.subheadline)
        .padding(.top, 32)
    }
    
    private func signIn() async {
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
}

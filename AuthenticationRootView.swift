//  AuthenticationRootView.swift
//  Recipe_Tinder
//
//  Created by Stella K on 2/10/26
//  Root view that manages authentication state
//

import SwiftUI

struct AuthenticationRootView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                SignInView()
            }
        }
    }
}

#Preview {
    AuthenticationRootView()
}

//
//  Recipe_TinderApp.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/27/26.
//    Edited by Stella K on 2/10/26

import SwiftUI
import FirebaseCore

@main
struct Recipe_TinderApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            AuthenticationRootView()
        }
    }
}

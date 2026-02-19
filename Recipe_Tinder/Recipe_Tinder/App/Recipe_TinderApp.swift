//
//  Recipe_TinderApp.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/27/26.
//    Edited by Stella K on 2/10/26
//   Updated by Stella K on 2/19/26

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Recipe_TinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthenticationRootView()
        }
    }
}

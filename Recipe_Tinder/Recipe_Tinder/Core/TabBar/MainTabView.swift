//
//  MainTabView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/27/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView{
            CardStackView()
                .tabItem{ Image (systemName: "flame")}
                .tag(0)
            
            Text("Search View")
                .tabItem{ Image (systemName: "magnifyingglass")}
                .tag(1)
            
            Text("Profile View")
                .tabItem{ Image (systemName: "person")}
                .tag(2)
        }
        .tint(.primary)
    }
}

#Preview {
    MainTabView()
}

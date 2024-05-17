//
//  TabView.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MainMenuView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Games")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}



//
//  Settings.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Form {
            Toggle(isOn: $isDarkMode) {
                Text("Dark Mode")
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

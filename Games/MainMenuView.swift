//
//  ContentView.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

struct MainMenuView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView { // Wrap the entire content in NavigationView
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.7, green: 0.85, blue: 1.0, opacity: 1.0), Color.white]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer().frame(height: 50)
                    Text("Choose a Game")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    LazyVGrid(columns: columns, spacing: 20) {
                        NavigationLink(destination: CheckersView()) {
                            Image("Checkers")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                        }
                        NavigationLink(destination: TicTacToeView()) {
                            Image("TicTacToe")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                        }
                        NavigationLink(destination: ConnectFourView()) {
                            Image("Connect4")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                        }
                        NavigationLink(destination: GuessTheNumber()) {
                            Image("Guess")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                        }
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

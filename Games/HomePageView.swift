//
//  HomePageView.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.7, green: 0.85, blue: 1.0, opacity: 1.0), Color.white]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer().frame(height: 100)
                Image("AlphaGames") // Replace with your logo image name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("Welcome to Alpha Games")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                Text("by Luis Rios and Axel Ramos")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(.top, 5)
                
                Spacer()
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

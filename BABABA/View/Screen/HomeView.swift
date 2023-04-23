//
//  HomeView.swift
//  BABABA
//
//  Created by Snow on 2023/01/13.
//

import SwiftUI

struct HomeView: View {
    
    init() {
        UITabBar.appearance().backgroundColor = .white
    }
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            // MARK: TabView With Recent Post's And Profile Tabs and etc
            TabView {
                CreateButtonView()
                    .tabItem {
                        Image("HomeButton")
                        Text("HOME")
                    }
                
                ShopView()
                    .tabItem {
                        Image("ShopButton")
                        Text("SHOP")
                    }

                MatchingView()
                    .tabItem {
                        Image("MatchingButton")
                    }
                
                StudyView()
                    .tabItem {
                        Image("StudyButton")
                        Text("STUDY")
                    }
                
                ProfileView()
                    .tabItem {
                        Image("ProfileButton")
                        Text("PROFILE")
                    }
                
            }
            // Changing Tab Lable Tint to Black
            .tint(.black)

        } else {
            VStack {
                VStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, alignment: .center)
                    Text("BABABA")
                        .font(.custom("BreeSerif-Regular", size: 45))
                    Text("Basketball With More Freedom.")
                        .font(.custom("Comfortaa-Light", size: 20))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.4)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isActive = true
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

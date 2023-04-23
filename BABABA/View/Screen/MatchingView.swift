//
//  MatchingView.swift
//  BABABA
//
//  Created by Snow on 2023/01/18.
//

import SwiftUI

struct MatchingView: View {
    
    @State private var showStreetball: Bool = false
    @State private var showOneOnOne: Bool = false
    @State private var showBasketball: Bool = false
    
    
    var body: some View {
        
        NavigationStack {
            Button {
                showStreetball.toggle()
            } label: {
                Image("Streetball")
                    .cornerRadius(10)
            }
            
            Button {
                showOneOnOne.toggle()
            } label: {
                Image("OneOnOneHalf")
                    .cornerRadius(10)
            }
            
            Button {
                showBasketball.toggle()
            } label: {
                Image("Basketball")
                    .cornerRadius(10)
            }
            
        }
        .fullScreenCover(isPresented: $showStreetball) {
            MatchingStreetballView {_ in
                
            }
        }
        .fullScreenCover(isPresented: $showOneOnOne) {
            MatchingOneOnOneView {_ in
                
            }
                    
        }
        .fullScreenCover(isPresented: $showBasketball) {
            MatchingBasketballView {_ in
                
            }
        }
        .overlay {
            VStack {
                Spacer()
                Spacer()
                Text("Streetball")
                    .font(.custom("BIZUDPGothic-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Spacer()
                Text("One-ON-One")
                    .font(.custom("BIZUDPGothic-Bold", size: 17))
                    .foregroundColor(.white)
                Spacer()
                Text("Basketball")
                    .font(.custom("BIZUDPGothic-Bold", size: 18))
                    .padding(.bottom, 40)
                Spacer()
                Spacer()
            }
        }
    }
}



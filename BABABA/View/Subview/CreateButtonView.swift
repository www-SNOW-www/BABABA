//
//  GameView.swift
//  BABABA
//
//  Created by Snow on 2023/01/14.
//

import SwiftUI

struct CreateButtonView: View {
    
    @State private var createNewGame: Bool = false
    @State private var recentsGames: [Game] = []
    
    var body: some View {
        NavigationStack {
            ReusableGameView(games: $recentsGames)
                .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewGame.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding(15)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }
                    }
                })
                .navigationTitle("WHAT'S NEW TODAY")
                .navigationBarTitleDisplayMode(.inline)
        }
            .fullScreenCover(isPresented: $createNewGame) {
                CreateNewGameView { game in
                    // Adding Created game at the Top of the Recent Games
                    recentsGames.insert(game, at: 0)
                } 
            }
    }
}

struct CreateButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateButtonView()
    }
}

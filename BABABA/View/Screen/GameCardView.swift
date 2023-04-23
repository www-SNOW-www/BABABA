//
//  GameCardView.swift
//  BABABA
//
//  Created by Snow on 2023/01/15.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct GameCardView: View {
    var game: Game
    // Callbacks
    var onUpdate: (Game) -> ()
    var onDelete: () -> ()
    // View Properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration?
    @State private var show: Bool = false
    
    var body: some View {
        NavigationStack {
            Button {
                show.toggle()
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Game Image If Any
                    if let gameImageURL = game.imageURL {
                        GeometryReader {
                            let size = $0.size
                            WebImage(url: gameImageURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .frame(height: 200)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            HStack {
                                WebImage(url: game.userProfileURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                
                                Text(game.userName)
                                    .font(.custom("BIZUDPGothic-Regular", size: 12))
                            }
                            Spacer()
                            GameInteraction()
                        }
                        
                        VStack(alignment: .leading) {
                            Text(game.titleText)
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .padding(.bottom, 2)
                            
                            Text("Time: 2023/02/\(game.date)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                            
                            Text("Place: \(game.placeText)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                            
                            Text("Style: \(game.playStyleText)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                            
                            Text(game.publishedDate.formatted(date: .numeric, time: .shortened))
                                .font(.custom("BIZUDPGothic-Regular", size: 8))
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        .padding(.horizontal, 15)
                    }
                }
                .hAlign(.leading)
            }
        }
        .fullScreenCover(isPresented: $show) {
            ShowGameView(game:game)
        }
        
        
        .overlay(alignment: .bottomTrailing, content: {
            // Displaying Delete Button (if it's Author of that game)
            if game.userUID == userUID {
                Menu {
                    Button("Delete Game", role: .destructive, action: deleteGame)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        
        .onAppear {
            // Adding Only Once
            if docListener == nil {
                guard let gameID = game.id else { return }
                docListener = Firestore.firestore().collection("Games").document(gameID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            // Document Updated
                            // Fetching Updated Document
                            if let updateGame = try? snapshot.data(as: Game.self) {
                                onUpdate(updateGame)
                            }
                        } else {
                            // Document Deleted
                            onDelete()
                        }
                    }
                })
            }
        }
        
        .onDisappear {
            // MARK: Applying SnapShot Listner Only When the Game is Available on the Screen
            // Else Removing the Listner (It saves unwanted live updates from the games which was swiped away from the screen)
            if let docListener {
                docListener.remove()
                self.docListener = nil
            }
        }
    }
    
    // MARK: Like Interaction
    @ViewBuilder
    func GameInteraction() -> some View {
        HStack(spacing: 6) {
            Button(action: likeGame) {
                Image(systemName: game.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(game.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical, 8)
    }
    
    // Liking Game
    func likeGame() {
        Task {
            guard let gameID = game.id else { return }
            if game.likedIDs.contains(userUID) {
                // Removing User ID From the Array
                try await Firestore.firestore().collection("Games").document(gameID).updateData(["likedIDs": FieldValue.arrayRemove([userUID])])
            } else {
                // Adding User ID To Liked Array and Removing our ID from Disliked Array (if Added in Prior)
                try await Firestore.firestore().collection("Games").document(gameID).updateData(["likedIDs": FieldValue.arrayUnion([userUID])])
            }
        }
    }
    
    // Deleting Game
    func deleteGame() {
        Task {
            // Step 1: Delete Image from Firebase Storage if present
            do {
                if game.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Game_Images").child(game.imageReferenceID).delete()
                }
                // Step 2: Delete Firebase Document
                guard let gameID = game.id else { return }
                try await Firestore.firestore().collection("Games").document(gameID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}



//
//  ShowGameView.swift
//  BABABA
//
//  Created by Snow on 2023/01/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ShowGameView: View {
    var game: Game
    @Environment(\.dismiss) private var dismiss
    @State private var gameDate: String = ""
    @State private var gameTitleText: String = ""
    @State private var gameImageDate: Data?
    @State private var gamePlaceText: String = "Yoyogi Park"
    @State private var gamePlayStyleText: String = "Streetball"
    @State private var gameDocumentText: String = ""
    // Stored User Data From UserDefaulys(AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    var body: some View {
        
        // Back
        HStack {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
            }
            .hAlign(.leading)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)

        // Game Info
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                // Game Image If Any
                if let gameImageURL = game.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: gameImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                    }
                    .frame(height: 200)
                    .padding(.vertical, 25)
                }
                    
                
                // Game Content
                VStack(alignment: .leading) {
                    HStack {
                        WebImage(url: game.userProfileURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                        
                        Text(game.titleText)
                            .font(.custom("BIZUDPGothic-Regular", size: 16))
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        Image("PlayStyle")
                            .opacity(0.7)
                        Text(game.playStyleText)
                            .font(.custom("BIZUDPGothic-Regular", size: 13))
                    }
                    .padding(.vertical, 8)
                    Divider()
                    
                    VStack {
                        HStack {
                            Image("Date")
                            Text("2023/02/\(game.date)")
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                        }
                        HStack {
                            Text("15:00 - 18:00")
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                        }
                    }
                    .padding(.vertical, 8)
                    Divider()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image("Location")
                            Text(game.placeText)
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                        }
                        
                        HStack {
                            
                            if game.placeText == PlaceNameText[0] {
                                Text(PlaceLocationText[0])
                                    .font(.custom("BIZUDPGothic-Regular", size: 10))
                            } else if game.placeText == PlaceNameText[1] {
                                Text(PlaceLocationText[1])
                                    .font(.custom("BIZUDPGothic-Regular", size: 10))
                            } else if game.placeText == PlaceNameText[2] {
                                Text(PlaceLocationText[2])
                                    .font(.custom("BIZUDPGothic-Regular", size: 10))
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.vertical, 8)
                    Divider()
                    
                    HStack {
                        Image("Details")
                        if game.documentText == "" {
                            Text("Nothing")
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        } else {
                            Text(game.documentText)
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                        }
                    }
                    .padding(.vertical, 8)
                    Divider()
                    
                    HStack {
                        VStack {
                            Text("Host")
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                            WebImage(url: game.userProfileURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Guest")
                                .font(.custom("BIZUDPGothic-Regular", size: 13))
                            Text("\(game.attendIDs.count)")
                                .font(.custom("BIZUDPGothic-Bold", size: 13))
                                .frame(width: 25, height: 25)
                        }
                        
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        
        // Join in
        Button(action: attendGame) {
            Text(game.attendIDs.contains(userUID) ? "CANCEL" : "ATTEND")
        }
        .fontWeight(.medium)
        .foregroundColor(.white)
        .hAlign(.center)
        .fillView(.pink)
        .padding(.vertical, 10)
        .padding(.horizontal, 30)
        .background {
            Rectangle()
                .fill(.gray.opacity(0.05))
                .ignoresSafeArea()
        }
    }
    
    // Liking Game
    func attendGame() {
        Task {
            guard let gameID = game.id else { return }
            if game.attendIDs.contains(userUID) {
                // Removing User ID From the Array
                try await Firestore.firestore().collection("Games").document(gameID).updateData(["attendIDs": FieldValue.arrayRemove([userUID])])
            } else {
                // Adding User ID To Liked Array and Removing our ID from Disliked Array (if Added in Prior)
                try await Firestore.firestore().collection("Games").document(gameID).updateData(["attendIDs": FieldValue.arrayUnion([userUID])])
            }
        }
    }
}



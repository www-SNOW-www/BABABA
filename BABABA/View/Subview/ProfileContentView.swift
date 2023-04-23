//
//  ProfileContentView.swift
//  BABABA
//
//  Created by Snow on 2023/01/13.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ProfileContentView: View {
    var user: User
    @State private var showData = false
    @State private var fetchedGames: [Game] = []
    @State private var fetchedMatches: [Match] = []
    @State private var fetchedStreetballs: [Streetball] = []
    @State private var fetchedOneOnOnes: [OneOnOne] = []
    @State private var fetchedBasketballs: [Basketball] = []
    // Stored User Data From UserDefaulys(AppStorage)
    @AppStorage("user_UID") private var userUID: String = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                VStack(spacing: 12) {
                    WebImage(url: user.userProfileURL).placeholder {
                        // MARK: Placeholder Image
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    Text(user.username)
                        .font(.custom("Comfortaa-Light", size: 30))
                        .padding(.top, 10)
                    
                    HStack {
                        Button(action: followUser) {
                            Text(user.followIDs.contains(userUID) ? "CANCEL" : "FOLLOW")
                            Text("\(user.followIDs.count)")
                        }
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(.black)
                        }
                        
                        Button {
                            self.showData.toggle()
                        } label: {
                            Image(systemName: "list.dash.header.rectangle")
                        }
                        .sheet(isPresented: $showData) {
                            DataView(user: user)
                        }
                    }
                    
                    Text("YOUR GAMES")
                        .font(.custom("BIZUDPGothic-Regular", size: 12))
                    
                    ReusableGameView(basedOnUID: true, uid: user.userUID, games: $fetchedGames)
                    ReusableMatchView(basedOnUID: true, uid: user.userUID, matches: $fetchedMatches)
                    ReusableStreetballView(basedOnUID: true, uid: user.userUID, streetballs: $fetchedStreetballs)
                    ReusableBasketballView(basedOnUID: true, uid: user.userUID, basketballs: $fetchedBasketballs)
                    ReusableOneOnOneView(basedOnUID: true, uid: user.userUID, oneOnOnes: $fetchedOneOnOnes)
                }
                
            }
        }
        
        
    }
    
    func followUser() {
        Task {
            guard let userID = user.id else { return }
            if user.followIDs.contains(userUID) {
                // Removing User ID From the Array
                try await Firestore.firestore().collection("Users").document(userID).updateData(["followIDs": FieldValue.arrayRemove([userUID])])
            } else {
                // Adding User ID To Liked Array and Removing our ID from Disliked Array (if Added in Prior)
                try await Firestore.firestore().collection("Users").document(userID).updateData(["followIDs": FieldValue.arrayUnion([userUID])])
            }
        }
    }
}

struct DataView: View {
    @Environment(\.dismiss) var dismiss
    var user: User
    @AppStorage("user_UID") private var userUID: String = ""
    var body: some View {
        Text("YOUR DATA")
            .fontWeight(.bold)
        
        VStack(spacing: 12) {
            WebImage(url: user.userProfileURL).placeholder {
                // MARK: Placeholder Image
                Image("NullProfile")
                    .resizable()
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            Text(user.username)
                .font(.custom("Comfortaa-Light", size: 30))
                .padding(.top, 10)
        }
        .padding(.vertical, 35)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("GP")
                    .fontDesign(.monospaced)
                Spacer()
                Text("40gp")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
            HStack {
                Text("PTS")
                    .fontDesign(.monospaced)
                Spacer()
                Text("40pts")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
            HStack {
                Text("REB")
                    .fontDesign(.monospaced)
                Spacer()
                Text("50reb")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
            HStack {
                Text("AST")
                    .fontDesign(.monospaced)
                Spacer()
                Text("70ast")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
        }
        .padding(.horizontal, 15)
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("STL")
                    .fontDesign(.monospaced)
                Spacer()
                Text("10stl")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
            HStack {
                Text("BLK")
                    .fontDesign(.monospaced)
                Spacer()
                Text("20blk")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
            HStack {
                Text("FG%")
                    .fontDesign(.monospaced)
                Spacer()
                Text("50.1%")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
            
            HStack {
                Text("3P%")
                    .fontDesign(.monospaced)
                Spacer()
                Text("30.8%")
                    .font(.custom("Comfortaa-Light", size: 20))
            }
            Divider()
        }
        .padding(.all, 15)
        
//        Button("CLOSE") { dismiss() }
    }
}

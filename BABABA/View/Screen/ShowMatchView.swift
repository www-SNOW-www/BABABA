//
//  ShowMatchView.swift
//  BABABA
//
//  Created by Snow on 2023/01/28.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ShowMatchView: View {
    var match: Match
    @Environment(\.dismiss) private var dismiss
    @State private var matchDate: String = ""
    @State private var matchImageDate: Data?
    @State private var matchPlaceText: String = "Yoyogi Park"
    @State private var matchPlayStyleText: String = "Streetball"
    @State private var data: [String] = []
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

        // Match Info
        ScrollView(.vertical, showsIndicators: false) {
            // Match Image
            if match.playStyleText == "Streetball" {
                Image("Streetball")
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottom) {
                        Text("Streetball")
                            .font(.custom("BIZUDPGothic-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
            } else if match.playStyleText == "One-ON-One" {
                Image("OneOnOne")
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottom) {
                        Text("One-ON-One")
                            .font(.custom("BIZUDPGothic-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
            } else if match.playStyleText == "Basketball" {
                Image("Basketball")
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottom) {
                        Text("Basketball")
                            .font(.custom("BIZUDPGothic-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
            }

            
            // Match Content
            VStack(alignment: .leading) {

                // PlayStyle
                HStack {
                    Image("PlayStyle")
                        .opacity(0.7)
                    Text(match.playStyleText)
                        .font(.custom("BIZUDPGothic-Regular", size: 13))
                }
                .padding(.vertical, 8)
                Divider()
                
                // Date
                VStack {
                    HStack {
                        Image("Date")
                        Text("2023/02/\(match.date)")
                            .font(.custom("BIZUDPGothic-Regular", size: 13))
                    }
                    HStack {
                        Text("15:00 - 18:00")
                            .font(.custom("BIZUDPGothic-Regular", size: 13))
                    }
                }
                .padding(.vertical, 8)
                Divider()
                
                // Place
                VStack(alignment: .leading) {
                    HStack {
                        Image("Location")
                        Text(match.placeText)
                            .font(.custom("BIZUDPGothic-Regular", size: 13))
                    }
                    
                    HStack {
                        
                        if match.placeText == PlaceNameText[0] {
                            Text(PlaceLocationText[0])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        } else if match.placeText == PlaceNameText[1] {
                            Text(PlaceLocationText[1])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        } else if match.placeText == PlaceNameText[2] {
                            Text(PlaceLocationText[2])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        }
                    }
                    .padding(.horizontal, 25)
                }
                .padding(.vertical, 8)
                Divider()
                
                // Member
                HStack {
                    Image("Member")
                    ForEach(data, id: \.self) { item in
                        if let url = URL(string: item) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.vertical, 8)
                .onAppear {
                    if match.playStyleText == "Streetball" {
                        let db = Firestore.firestore().collection("Matches")
                        let searchInputDate = match.date
                        let searchInputPlace = match.placeText
                        db.whereField("playStyleText", isEqualTo: "Streetball").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).order(by: "publishedDate", descending: true).limit(to: 6).getDocuments { (snapshot, error) in
                            if error == nil {
                                if let snap = snapshot {
                                    for document in snap.documents {
                                        self.data.append(document.data()["userProfileURL"] as! String)
                                    }
                                }
                            }
                        }
                    } else if match.playStyleText == "One-ON-One" {
                        let db = Firestore.firestore().collection("Matches")
                        let searchInputDate = match.date
                        let searchInputPlace = match.placeText
                        db.whereField("playStyleText", isEqualTo: "One-ON-One").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).order(by: "publishedDate", descending: true).limit(to: 6).getDocuments { (snapshot, error) in
                            if error == nil {
                                if let snap = snapshot {
                                    for document in snap.documents {
                                        self.data.append(document.data()["userProfileURL"] as! String)
                                    }
                                }
                            }
                        }
                    } else if match.playStyleText == "Basketball" {
                        let db = Firestore.firestore().collection("Matches")
                        let searchInputDate = match.date
                        let searchInputPlace = match.placeText
                        db.whereField("playStyleText", isEqualTo: "Basketball").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).order(by: "publishedDate", descending: true).limit(to: 6).getDocuments { (snapshot, error) in
                            if error == nil {
                                if let snap = snapshot {
                                    for document in snap.documents {
                                        self.data.append(document.data()["userProfileURL"] as! String)
                                    }
                                }
                            }
                        }
                    }

                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        
        // Matching Button
        Button(action: decideMatch) {
            Text("MATCHING CONFIRMED")
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
    
    func decideMatch() {
        let db = Firestore.firestore()
        let searchInputDate = match.date
        let searchInputPlace = match.placeText
        db.collection("Matches").whereField("playStyleText", isEqualTo: "Streetball").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).getDocuments { (snapshot, error) in
            if error != nil {
                // handle the error
            } else {
                let groupID: String = UUID().uuidString
                for document in snapshot!.documents {
                    var data = document.data()
                    data["groupID"] = groupID
                    db.collection("Streetballs").addDocument(data: data) { error in
                        if error != nil {
                            // handle the error
                        } else {
                            document.reference.delete()
                        }
                    }
                }
            }
        }
        
        db.collection("Matches").whereField("playStyleText", isEqualTo: "Basketball").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).getDocuments { (snapshot, error) in
            if error != nil {
                // handle the error
            } else {
                let groupID: String = UUID().uuidString
                for document in snapshot!.documents {
                    var data = document.data()
                    data["groupID"] = groupID
                    db.collection("Basketballs").addDocument(data: data) { error in
                        if error != nil {
                            // handle the error
                        } else {
                            document.reference.delete()
                        }
                    }
                }
            }
        }
        
        db.collection("Matches").whereField("playStyleText", isEqualTo: "One-ON-One").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).getDocuments { (snapshot, error) in
            if error != nil {
                // handle the error
            } else {
                let groupID: String = UUID().uuidString
                for document in snapshot!.documents {
                    var data = document.data()
                    data["groupID"] = groupID
                    db.collection("OneOnOnes").addDocument(data: data) { error in
                        if error != nil {
                            // handle the error
                        } else {
                            document.reference.delete()
                        }
                    }
                }
            }
        }
    }
}


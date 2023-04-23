//
//  ShowStreetballView.swift
//  BABABA
//
//  Created by Snow on 2023/02/03.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ShowStreetballView: View {
    var streetball: Streetball
    @Environment(\.dismiss) private var dismiss
    @State private var streetballDate: String = ""
    @State private var streetballImageDate: Data?
    @State private var streetballPlaceText: String = "Yoyogi Park"
    @State private var streetballPlayStyleText: String = "Streetball"
    @State private var data: [String] = []
    var dataFetched = false
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
            Image("Streetball")
                .resizable()
                .scaledToFill()
                .overlay(alignment: .bottom) {
                    Text("Streetball")
                        .font(.custom("BIZUDPGothic-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
            
            // Match Content
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Successful Matching!")
                        .font(.custom("BIZUDPGothic-Bold", size: 18))
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.pink)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 8)
                Divider()
                
                // PlayStyle
                HStack {
                    Image("PlayStyle")
                        .opacity(0.7)
                    Text(streetball.playStyleText)
                        .font(.custom("BIZUDPGothic-Regular", size: 13))
                }
                .padding(.vertical, 8)
                Divider()
                
                // Date
                VStack {
                    HStack {
                        Image("Date")
                        Text("2023/02/\(streetball.date)")
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
                        Text(streetball.placeText)
                            .font(.custom("BIZUDPGothic-Regular", size: 13))
                    }
                    
                    HStack {
                        
                        if streetball.placeText == PlaceNameText[0] {
                            Text(PlaceLocationText[0])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        } else if streetball.placeText == PlaceNameText[1] {
                            Text(PlaceLocationText[1])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        } else if streetball.placeText == PlaceNameText[2] {
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
                    let db = Firestore.firestore().collection("Streetballs")
                    db.whereField("userUID", isEqualTo: userUID).getDocuments { QuerySnapshot, err in
                        if err == nil {
                            if let snap = QuerySnapshot {
                                for document in snap.documents {
                                    print(document.data())
                                    let groupID = document.data()["groupID"] as? String
                                    print("groupID")
                                    let streetballid = document.documentID
                                    if streetballid == streetball.id {
                                        if ( groupID != nil ) {
                                            db.whereField("groupID", isEqualTo: groupID ?? "").getDocuments { QuerySnapshot, err in
                                                if err == nil {
                                                    if let snap = QuerySnapshot {
                                                        for document in snap.documents {
                                                            print("groupMember")
                                                            
                                                            print(document.data())
                                                            self.data.append(document.data()["userProfileURL"] as! String)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }
                    
//                    db.whereField("playStyleText", isEqualTo: "Streetball").whereField("placeText", isEqualTo: searchInputPlace).whereField("date", isEqualTo: searchInputDate).order(by: "publishedDate", descending: true).limit(to: 3).getDocuments { (snapshot, error) in
//                        if error == nil {
//                            if let snap = snapshot {
//                                for document in snap.documents {
//                                    self.data.append(document.data()["userProfileURL"] as! String)
//                                }
//                            }
//                        }
//                    }
//                    
//                    var count = 1
//                    db.getDocuments() { (querySnapshot, err) in
//                        if let err = err {
//                            print("Error getting documents: \(err)")
//                        } else {
//                            for document in querySnapshot!.documents {
//                                let data = document.data()
//                                // Firebaseから取り出したデータに番号を付ける
//                                _ = data.mapValues { (value) -> Any in
//                                    if value is String {
//                                        return "\(count). \(value)"
//                                    }
//                                    return value
//                                }
//                                // 番号を付けたデータを画面に表示するなどの処理を行う
//                                // ...
//                                count += 1
//                            }
//                        }
//                    }

                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

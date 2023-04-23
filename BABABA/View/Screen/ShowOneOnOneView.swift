//
//  ShowOneOnOneView.swift
//  BABABA
//
//  Created by Snow on 2023/03/06.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ShowOneOnOneView: View {
    var oneOnOne: OneOnOne
    @Environment(\.dismiss) private var dismiss
    @State private var oneOnOneDate: String = ""
    @State private var oneOnOneImageDate: Data?
    @State private var oneOnOnePlaceText: String = "Yoyogi Park"
    @State private var oneOnOnePlayStyleText: String = "OneOnOne"
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
            Image("OneOnOne")
                .resizable()
                .scaledToFill()
                .overlay(alignment: .bottom) {
                    Text("One-ON-One")
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
                    Text(oneOnOne.playStyleText)
                        .font(.custom("BIZUDPGothic-Regular", size: 13))
                }
                .padding(.vertical, 8)
                Divider()
                
                // Date
                VStack {
                    HStack {
                        Image("Date")
                        Text("2023/02/\(oneOnOne.date)")
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
                        Text(oneOnOne.placeText)
                            .font(.custom("BIZUDPGothic-Regular", size: 13))
                    }
                    
                    HStack {
                        
                        if oneOnOne.placeText == PlaceNameText[0] {
                            Text(PlaceLocationText[0])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        } else if oneOnOne.placeText == PlaceNameText[1] {
                            Text(PlaceLocationText[1])
                                .font(.custom("BIZUDPGothic-Regular", size: 10))
                        } else if oneOnOne.placeText == PlaceNameText[2] {
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
                    let db = Firestore.firestore().collection("OneOnOnes")
                    db.whereField("userUID", isEqualTo: userUID).getDocuments { QuerySnapshot, err in
                        if err == nil {
                            if let snap = QuerySnapshot {
                                for document in snap.documents {
                                    print(document.data())
                                    let groupID = document.data()["groupID"] as? String
                                    print("groupID")
                                    let oneOnOneid = document.documentID
                                    if oneOnOneid == oneOnOne.id {
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

                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

//
//  StreetballCardView.swift
//  BABABA
//
//  Created by Snow on 2023/02/03.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct DecidedStreetballView: View {
    
    var streetball: Streetball
    // Callbacks
    var onUpdate: (Streetball) -> ()
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

                    VStack(alignment: .leading) {
                        
                        // Match Title
                        HStack {
                            Text("Random Match:")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                            // if playstyle color change
                            Text(streetball.playStyleText)
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.white)
                                .fillView(.brown)
                            
                            Spacer()
                            
                            Text("DECIDED")
                                .font(.custom("BIZUDPGothic-Bold", size: 11))
                                .foregroundColor(.black)
                                .gBorder(2, .black)
                        }
                        .padding(.bottom, 5)
                        
                        // Match Info
                        VStack(alignment: .leading) {
                            Text("Time: 2023/02/\(streetball.date)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                            
                            Text("Place: \(streetball.placeText)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                            
                            Text(streetball.publishedDate.formatted(date: .numeric, time: .shortened))
                                .font(.custom("BIZUDPGothic-Regular", size: 8))
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        
                    }
                    .padding(.horizontal, 15)
                }
                .hAlign(.leading)
            }
        }
        .fullScreenCover(isPresented: $show) {
            ShowStreetballView(streetball: streetball)
        }
        
        
        .overlay(alignment: .bottomTrailing, content: {
            // Displaying Delete Button (if it's Author of that game)
            if streetball.userUID == userUID {
                Menu {
                    Button("Delete Match", role: .destructive, action: deleteStreetball)
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
                guard let streetballID = streetball.id else { return }
                docListener = Firestore.firestore().collection("Streetballs").document(streetballID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            // Document Updated
                            // Fetching Updated Document
                            if let updateStreetball = try? snapshot.data(as: Streetball.self) {
                                onUpdate(updateStreetball)
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
    // Deleting Match
    func deleteStreetball() {
        Task {
            // Step 1: Delete Image from Firebase Storage if present
            do {
                if streetball.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Streetball_Images").child(streetball.imageReferenceID).delete()
                }
                // Step 2: Delete Firebase Document
                guard let streetballID = streetball.id else { return }
                try await Firestore.firestore().collection("Streetballs").document(streetballID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

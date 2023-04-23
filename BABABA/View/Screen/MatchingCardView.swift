//
//  MatchingCardView.swift
//  BABABA
//
//  Created by Snow on 2023/01/27.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct MatchingCardView: View {
    
    var match: Match
    // Callbacks
    var onUpdate: (Match) -> ()
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
                            if match.playStyleText == "Streetball" {
                                Text(match.playStyleText)
                                    .font(.custom("BIZUDPGothic-Regular", size: 12))
                                    .textSelection(.enabled)
                                    .foregroundColor(.white)
                                    .fillView(.brown)
                            } else if match.playStyleText == "One-ON-One" {
                                Text("OneOnOne")
                                    .font(.custom("BIZUDPGothic-Regular", size: 12))
                                    .textSelection(.enabled)
                                    .foregroundColor(.white)
                                    .fillView(.black)
                            } else if match.playStyleText == "Basketball" {
                                Text(match.playStyleText)
                                    .font(.custom("BIZUDPGothic-Regular", size: 12))
                                    .textSelection(.enabled)
                                    .foregroundColor(.white)
                                    .fillView(.blue)
                            }

                            
                            Spacer()
                            
                            Text("UNDECIDED")
                                .font(.custom("BIZUDPGothic-Bold", size: 11))
                                .textSelection(.enabled)
                                .foregroundColor(.white)
                                .fillView(.pink)
                        }
                        .padding(.bottom, 5)
                        
                        // Match Info
                        VStack(alignment: .leading) {
                            Text("Time: 2023/02/\(match.date)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                            
                            Text("Place: \(match.placeText)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                            
                            Text(match.publishedDate.formatted(date: .numeric, time: .shortened))
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
                ShowMatchView(match: match)
        }
        
        
        .overlay(alignment: .bottomTrailing, content: {
            // Displaying Delete Button (if it's Author of that game)
            if match.userUID == userUID {
                Menu {
                    Button("Delete Match", role: .destructive, action: deleteMatch)
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
                guard let matchID = match.id else { return }
                docListener = Firestore.firestore().collection("Matches").document(matchID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            // Document Updated
                            // Fetching Updated Document
                            if let updateMatch = try? snapshot.data(as: Match.self) {
                                onUpdate(updateMatch)
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
    func deleteMatch() {
        Task {
            // Step 1: Delete Image from Firebase Storage if present
            do {
                if match.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Match_Images").child(match.imageReferenceID).delete()
                }
                // Step 2: Delete Firebase Document
                guard let matchID = match.id else { return }
                try await Firestore.firestore().collection("Matches").document(matchID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

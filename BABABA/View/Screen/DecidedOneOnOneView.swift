//
//  DecidedOneOnOneView.swift
//  BABABA
//
//  Created by Snow on 2023/03/06.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct DecidedOneOnOneView: View {
    
    var oneOnOne: OneOnOne
    // Callbacks
    var onUpdate: (OneOnOne) -> ()
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
                            Text("OneOnOne")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.white)
                                .fillView(.black)
                            
                            Spacer()
                            
                            Text("DECIDED")
                                .font(.custom("BIZUDPGothic-Bold", size: 11))
                                .foregroundColor(.black)
                                .gBorder(2, .black)
                        }
                        .padding(.bottom, 5)
                        
                        // Match Info
                        VStack(alignment: .leading) {
                            Text("Time: 2023/02/\(oneOnOne.date)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                            
                            Text("Place: \(oneOnOne.placeText)")
                                .font(.custom("BIZUDPGothic-Regular", size: 12))
                                .textSelection(.enabled)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                            
                            Text(oneOnOne.publishedDate.formatted(date: .numeric, time: .shortened))
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
            ShowOneOnOneView(oneOnOne: oneOnOne)
        }
        
        
        .overlay(alignment: .bottomTrailing, content: {
            // Displaying Delete Button (if it's Author of that game)
            if oneOnOne.userUID == userUID {
                Menu {
                    Button("Delete Match", role: .destructive, action: deleteOneOnOne)
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
                guard let oneOnOneID = oneOnOne.id else { return }
                docListener = Firestore.firestore().collection("OneOnOnes").document(oneOnOneID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            // Document Updated
                            // Fetching Updated Document
                            if let updateOneOnOne = try? snapshot.data(as: OneOnOne.self) {
                                onUpdate(updateOneOnOne)
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
    func deleteOneOnOne() {
        Task {
            // Step 1: Delete Image from Firebase Storage if present
            do {
                if oneOnOne.imageReferenceID != "" {
                    try await Storage.storage().reference().child("OneOnOne_Images").child(oneOnOne.imageReferenceID).delete()
                }
                // Step 2: Delete Firebase Document
                guard let oneOnOneID = oneOnOne.id else { return }
                try await Firestore.firestore().collection("OneOnOnes").document(oneOnOneID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


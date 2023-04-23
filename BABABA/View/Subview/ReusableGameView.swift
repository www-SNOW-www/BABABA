//
//  ReusableGameView.swift
//  BABABA
//
//  Created by Snow on 2023/01/14.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableGameView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var games: [Game]
    // View Properties
    @State private var isFetching: Bool = true
    // Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                if isFetching {
                    //                    ProgressView()
                    //                        .padding(.top, 30)
                } else {
                    if games.isEmpty {
                        // No Game's Found on Firestore
                    } else {
                        // Displaying Game's
                        Games()
                    }
                }
            }
            .padding(.horizontal, 15)
        }
        .refreshable {
            // Scroll to Refresh
            // Disbaling Refresh for UID based Game's
            guard !basedOnUID else { return }
            isFetching = true
            games = []
            // Reseting Pagination Doc
            paginationDoc = nil
            await fetchGames()
        }
        .task {
            // Fetching For One Time
            guard games.isEmpty else { return }
            await fetchGames()
        }
    }
    
    
    
    // Displaying Fetched Game's
    @ViewBuilder
    func Games() -> some View {
        ForEach(games) { game in
            GameCardView(game: game) { updateGame in
                // Updating Game in the Array
                if let index = games.firstIndex(where: { game in
                    game.id == updateGame.id
                }) {
                    games[index].likedIDs = updateGame.likedIDs
                    games[index].attendIDs = updateGame.attendIDs
                }
            } onDelete: {
                // Removing Game From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    games.removeAll { game.id == $0.id }
                }
            }
            //            .onAppear {
            //                // When Last Game Appears, Fetching New Game (If There)
            //                if game.id == games.last?.id && paginationDoc != nil {
            //                    games = []
            //
            //                    Task { await fetchGames() }
            //                }
            //            }
            Divider()
        }
    }
    
    // Fetching Game's
    func fetchGames() async {
        do {
            var query: Query!
            // Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Games")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Games")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            
            // New Query For UID Based Document Fetch
            // Simply Filter the Game's Which is not belongs to this UID
            if basedOnUID {
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            let docs = try await query.getDocuments()
            let fetchedGames = docs.documents.compactMap { doc -> Game? in
                try? doc.data(as: Game.self)
            }
            
            let docsAttend = try await Firestore.firestore().collection("Games").whereField("attendIDs", arrayContains: uid).getDocuments()
            
            // last fetched !!!!
            let fetchedAttend = docsAttend.documents.compactMap { doc -> Game? in
                try? doc.data(as: Game.self)
            }
            print(fetchedGames.count)
            print("fetchedGames"+(fetchedAttend+fetchedGames).count.description)
            
            await MainActor.run(body: {
                // + fetchedAttend
                games.append(contentsOf: fetchedGames)
                let filterAttend = fetchedAttend.filter {
                    !games.map { $0.id }.contains( $0.id )
                }
                games.append(contentsOf: filterAttend)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }

    }
}

struct ReusableGameView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

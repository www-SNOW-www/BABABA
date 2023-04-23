//
//  ReusableMatchView.swift
//  BABABA
//
//  Created by Snow on 2023/01/28.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableMatchView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var matches: [Match]
    // View Properties
    @State private var isFetching: Bool = true
    // Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {

                } else {
                    if matches.isEmpty {
                        // No Match's Found on Firestore

                    } else {
                        // Displaying Match's
                        Matches()
                    }
                }
            }
            .padding(.horizontal, 15)
        }
        .refreshable {
            // Scroll to Refresh
            // Disbaling Refresh for UID based Match's
            guard !basedOnUID else { return }
            isFetching = true
            matches = []
            // Reseting Pagination Doc
            paginationDoc = nil
            await fetchMatches()
        }
        .task {
            // Fetching For One Time
            guard matches.isEmpty else { return }
            await fetchMatches()
        }
    }
    
    func Matches() -> some View {
        ForEach(matches) { match in
            MatchingCardView(match: match) { updateMatch in
                // Updating Game in the Array
                if let index = matches.firstIndex(where: { match in
                    match.id == updateMatch.id
                }) {
                    matches[index].likedIDs = updateMatch.likedIDs
                }
            } onDelete: {
                // Removing Game From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    matches.removeAll { match.id == $0.id }
                }
            }
            .onAppear {
                // When Last Game Appears, Fetching New Game (If There)
                if match.id == matches.last?.id && paginationDoc != nil {
                    Task { await fetchMatches() }
                }
            }
            Divider()
        }
    }
    
    func fetchMatches() async {
        do {
            var query: Query!
            // Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Matches")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Matches")
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
            let fetchedMatches = docs.documents.compactMap { doc -> Match? in
                try? doc.data(as: Match.self)
            }
            await MainActor.run(body: {
                matches.append(contentsOf: fetchedMatches)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusableMatchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

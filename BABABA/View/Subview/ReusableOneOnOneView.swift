//
//  ReusableOneOnOneView.swift
//  BABABA
//
//  Created by Snow on 2023/03/06.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableOneOnOneView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var oneOnOnes: [OneOnOne]
    // View Properties
    @State private var isFetching: Bool = true
    // Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {

                } else {
                    if oneOnOnes.isEmpty {
                    } else {
                        // Displaying Match's
                        OneOnOnes()
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
            oneOnOnes = []
            // Reseting Pagination Doc
            paginationDoc = nil
            await fetchOneOnOnes()
        }
        .task {
            // Fetching For One Time
            guard oneOnOnes.isEmpty else { return }
            await fetchOneOnOnes()
        }
    }
    
    func OneOnOnes() -> some View {
        ForEach(oneOnOnes) { oneOnOne in
            DecidedOneOnOneView(oneOnOne: oneOnOne) { updateOneOnOne in
                // Updating Game in the Array
                if let index = oneOnOnes.firstIndex(where: { oneOnOne in
                    oneOnOne.id == updateOneOnOne.id
                }) {
                    oneOnOnes[index].likedIDs = updateOneOnOne.likedIDs
                }
            } onDelete: {
                // Removing Game From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    oneOnOnes.removeAll { oneOnOne.id == $0.id }
                }
            }
            .onAppear {
                // When Last Game Appears, Fetching New Game (If There)
                if oneOnOne.id == oneOnOnes.last?.id && paginationDoc != nil {
                    Task { await fetchOneOnOnes() }
                }
            }
            Divider()
        }
    }
    
    func fetchOneOnOnes() async {
        do {
            var query: Query!
            // Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("OneOnOnes")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("OneOnOnes")
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
            let fetchedOneOnOnes = docs.documents.compactMap { doc -> OneOnOne? in
                try? doc.data(as: OneOnOne.self)
            }
            await MainActor.run(body: {
                oneOnOnes.append(contentsOf: fetchedOneOnOnes)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusableOneOnOneView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

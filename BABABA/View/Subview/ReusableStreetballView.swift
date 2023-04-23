//
//  ReusableStreetballView.swift
//  BABABA
//
//  Created by Snow on 2023/02/03.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableStreetballView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var streetballs: [Streetball]
    // View Properties
    @State private var isFetching: Bool = true
    // Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {

                } else {
                    if streetballs.isEmpty {
                    } else {
                        // Displaying Match's
                        Streetballs()
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
            streetballs = []
            // Reseting Pagination Doc
            paginationDoc = nil
            await fetchStreetballs()
        }
        .task {
            // Fetching For One Time
            guard streetballs.isEmpty else { return }
            await fetchStreetballs()
        }
    }
    
    func Streetballs() -> some View {
        ForEach(streetballs) { streetball in
            DecidedStreetballView(streetball: streetball) { updateStreetball in
                // Updating Game in the Array
                if let index = streetballs.firstIndex(where: { streetball in
                    streetball.id == updateStreetball.id
                }) {
                    streetballs[index].likedIDs = updateStreetball.likedIDs
                }
            } onDelete: {
                // Removing Game From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    streetballs.removeAll { streetball.id == $0.id }
                }
            }
            .onAppear {
                // When Last Game Appears, Fetching New Game (If There)
                if streetball.id == streetballs.last?.id && paginationDoc != nil {
                    Task { await fetchStreetballs() }
                }
            }
            Divider()
        }
    }
    
    func fetchStreetballs() async {
        do {
            var query: Query!
            // Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Streetballs")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Streetballs")
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
            let fetchedStreetballs = docs.documents.compactMap { doc -> Streetball? in
                try? doc.data(as: Streetball.self)
            }
            await MainActor.run(body: {
                streetballs.append(contentsOf: fetchedStreetballs)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusableStreetballView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


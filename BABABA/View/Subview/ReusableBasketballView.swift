//
//  ReusableBasketball.swift
//  BABABA
//
//  Created by Snow on 2023/03/05.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableBasketballView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var basketballs: [Basketball]
    // View Properties
    @State private var isFetching: Bool = true
    // Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {

                } else {
                    if basketballs.isEmpty {
                    } else {
                        // Displaying Match's
                        Basketballs()
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
            basketballs = []
            // Reseting Pagination Doc
            paginationDoc = nil
            await fetchBasketballs()
        }
        .task {
            // Fetching For One Time
            guard basketballs.isEmpty else { return }
            await fetchBasketballs()
        }
    }
    
    func Basketballs() -> some View {
        ForEach(basketballs) { basketball in
            DecidedBasketballView(basketball: basketball) { updateBasketball in
                // Updating Game in the Array
                if let index = basketballs.firstIndex(where: { basketball in
                    basketball.id == updateBasketball.id
                }) {
                    basketballs[index].likedIDs = updateBasketball.likedIDs
                }
            } onDelete: {
                // Removing Game From the Array
                withAnimation(.easeInOut(duration: 0.25)) {
                    basketballs.removeAll { basketball.id == $0.id }
                }
            }
            .onAppear {
                // When Last Game Appears, Fetching New Game (If There)
                if basketball.id == basketballs.last?.id && paginationDoc != nil {
                    Task { await fetchBasketballs() }
                }
            }
            Divider()
        }
    }
    
    func fetchBasketballs() async {
        do {
            var query: Query!
            // Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Basketballs")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Basketballs")
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
            let fetchedBasketballs = docs.documents.compactMap { doc -> Basketball? in
                try? doc.data(as: Basketball.self)
            }
            await MainActor.run(body: {
                basketballs.append(contentsOf: fetchedBasketballs)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusableBasketballView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  MatchingBasketball.swift
//  BABABA
//
//  Created by Snow on 2023/03/03.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct MatchingBasketballView: View {
    var onMatch: (Match) -> ()
    // Game Properties
    @State private var matchDate: String = ""
    @State private var matchTitleText: String = ""
    @State private var matchImageDate: Data?
    @State private var matchPlaceText: String = "Yoyogi Park"
    @State private var matchPlayStyleText: String = "Basketball"
    @State private var matchDocumentText: String = ""
    // Stored User Data From UserDefaulys(AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    // View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var showKeyboard: Bool
    @State var index = 0
    
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
        
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                
                // MARK: Image
                Image("Basketball")
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottom) {
                        Text("Basketball")
                            .font(.custom("BIZUDPGothic-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
                
                // MARK: Contents
                VStack(alignment : .leading) {
                    
                    // MARK: Style Info
                    HStack(alignment: .top) {
                        Image("Details")
                        Text(PlayStyleInfoText[2])
                            .font(.custom("BIZUDPGothic-Regular", size: 15))
                            .lineSpacing(5)
                    }
                    .padding(.vertical, 20)
                    Divider()
                    
                    // MARK: Date
                    VStack(alignment : .leading) {
                        HStack {
                            Image("Date")
                            Text("Choose a day")
                                .font(.custom("BIZUDPGothic-Regular", size: 15))
                        }
                        
                        HStack {
                            Text("Y")
                                .font(.caption)
                            Text("2023")
                                .frame(width: 50, height: 20)
                                .gBorder(0.5, .black)
                            Text("M")
                                .font(.caption)
                            Text("03")
                                .frame(height: 20)
                                .gBorder(0.5, .black)
                            Text("D")
                                .font(.caption)
                            TextField("09", text: $matchDate, axis: .vertical)
                                .focused($showKeyboard)
                                .frame(height: 20)
                                .gBorder(0.5, .black)
                            Text("T")
                                .font(.caption)
                            Text("15")
                                .frame(height: 20)
                                .gBorder(0.5, .black)
                        }
                    }
                    .padding(.vertical, 20)
                    Divider()
                    
                    // MARK: Place
                    TabView(selection: self.$index) {
                        ForEach(0...2, id: \.self) { index in
                            VStack {
                                Image("Place\(index)")
                                    .resizable()
                                    .cornerRadius(15)
                                    .overlay(Text(PlaceNameText[index]).font(.custom("BIZUDPGothic-Regular", size: 15)).foregroundColor(.white).padding(10).underline(), alignment: .bottomLeading)
                                
                            }
                        }
                    }
                    .frame(height: 223)
                    .tabViewStyle(PageTabViewStyle())
                    .padding(.vertical, 10)
                    
                    TabView(selection: self.$index) {
                        ForEach(0...2, id: \.self) { index in
                            VStack {
                                HStack(alignment: .top) {
                                    Image("Info")
                                    Text(PlaceInfoText[index])
                                        .font(.custom("BIZUDPGothic-Regular", size: 15))
                                        .lineSpacing(5)
                                }
                            }
                        }
                    }
                    .frame(minHeight: 200)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    VStack(alignment : .leading) {
                        
                        HStack {
                            Image("Info") // ← Change the pic
                            Text("Location:")
                                .font(.custom("BIZUDPGothic-Regular", size: 15))
                            Image("Smile")
                            Text("Claen:")
                                .font(.custom("BIZUDPGothic-Regular", size: 15))
                            Image("Star")
                            Text("People:")
                                .font(.custom("BIZUDPGothic-Regular", size: 15))
                            Image("PeopleTwo")
                        }
                        
                        HStack {
                            Image("Location")
                            Text("Pick a place")
                                .font(.custom("BIZUDPGothic-Regular", size: 15))
                            DropDown (
                                content: PlaceNameText, selection: $matchPlaceText, activeTint: .primary.opacity(0.2), inActiveTint: .black.opacity(0.8), dynamic: true
                            )
                            .foregroundColor(.white)
                            .frame(width: 200)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 45)
                    Divider()
                }
                .padding(12)
            }
        }
        .vAlign(.top)
        // Loading View
        .overlay {
            LoadingView(show: $isLoading)
        }
        
        // Matching Button
        Button(action: createMatch) {
            Text("MATCHING")
        }
        .disableWithOpacity(matchDate == "")
        .fontWeight(.medium)
        .foregroundColor(.white)
        .hAlign(.center)
        .fillView(.pink)
        .padding(.vertical, 10)
        .padding(.horizontal, 30)
        .background {
            Rectangle()
                .fill(.gray.opacity(0.05))
                .ignoresSafeArea()
        }
    }
    
    func createMatch() {
        
        isLoading = true
        showKeyboard = false
        
        Task {
            do {
                guard let profileURL = profileURL else { return }
                // Step 1: Uploading Image If any
                // Used to delete the Game (Later shown in the Video)
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Match_Images").child(imageReferenceID)
                if let matchImageDate {
                    let _ = try await storageRef.putDataAsync(matchImageDate)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    // Step 3: Create Game Object With Image Id And URL
                    let match = Match(date: matchDate, titleText: matchTitleText, placeText: matchPlaceText, playStyleText: matchPlayStyleText, documentText: matchDocumentText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(match)
                } else {
                    // Step 2: Directly Game Text Data to Firebase (Since there is no Images Present)
                    let match = Match(date: matchDate, titleText: matchTitleText, placeText: matchPlaceText, playStyleText: matchPlayStyleText, documentText: matchDocumentText, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(match)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase( _ match: Match) async throws {
        // Writing Document to Firebase FireStore
        let doc = Firestore.firestore().collection("Matches").document()
        let _ = try doc.setData(from: match, completion: { error in
            if error == nil {
                // Game Successfully Stored at Firebase
                isLoading = false
                var updateMatch = match
                updateMatch.id = doc.documentID
                onMatch(updateMatch)
                dismiss()
            }
        })
    }
    
    // MARK: Displaying Errors as Alert
    func setError( _ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct MatchingBasketballView_Previews: PreviewProvider {
    static var previews: some View {
        MatchingBasketballView { _ in
            
        }
    }
}

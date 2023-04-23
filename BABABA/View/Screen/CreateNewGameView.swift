//
//  CreateNewGameView.swift
//  BABABA
//
//  Created by Snow on 2023/01/14.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct CreateNewGameView: View {
    // Callbacks
    var onGame: (Game) -> ()
    // Game Properties
    @State private var gameDate: String = ""
    @State private var gameTitleText: String = ""
    @State private var gameImageDate: Data?
    @State private var gamePlaceText: String = "Yoyogi Park"
    @State private var gamePlayStyleText: String = "Streetball"
    @State private var gameDocumentText: String = ""
    // Stored User Data From UserDefaulys(AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    // View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoitem: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool
    @State var index = 0
    
    var body: some View {
        
        VStack {
            // MARK: Menu
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .fontDesign(.monospaced)
                        .foregroundColor(.black)
                }
                .hAlign(.leading)
                
                Button(action: createGame) {
                    Text("Create")
                        .font(.callout)
                        .fontDesign(.monospaced)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                }
                .disableWithOpacity(gameTitleText == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                
                // MARK: Image
                VStack(spacing: 15) {
                    
                    HStack {
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                        }
                        
                        Button("Done") {
                            showKeyboard = false
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .photosPicker(isPresented: $showImagePicker, selection: $photoitem)
                    .onChange(of: photoitem) { newValue in
                        if let newValue {
                            Task {
                                if let rawImageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: rawImageData), let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                                    //  UI Must be done on Main Thread
                                    await MainActor.run(body: {
                                        gameImageDate = compressedImageData
                                        photoitem = nil
                                    })
                                }
                            }
                        }
                    }
                    .alert(errorMessage, isPresented: $showError, actions: {})
                    
                    if let gameImageDate, let image = UIImage(data: gameImageDate) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                // Delete Button
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.gameImageDate = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .padding()
                                            .font(.title)
                                            .tint(.white)
                                    }
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                
                // MARK: Contents
                VStack(alignment : .leading) {
                    
                    // MARK: Title
                    VStack {
                        HStack {
                            Image("Title")
                            TextField("Enter a title", text: $gameTitleText)
                                .font(.custom("BIZUDPGothic-Regular", size: 15))
                                .frame(height: 20)
                                .textContentType(.emailAddress)
                                .gBorder(0.5, .black)
                        }
                    }
                    .padding(.vertical, 20)
                    Divider()
                    
                    // MARK: Play Style
                    HStack {
                        Image("PlayStyle")
                            .opacity(0.7)
                        Text("Choose a playstyle")
                            .font(.custom("BIZUDPGothic-Regular", size: 15))
                        DropDown (
                            content: ["Streetball","One-ON-One","Basketball"], selection: $gamePlayStyleText, activeTint: .primary.opacity(0.2), inActiveTint: .black.opacity(0.8), dynamic: true
                        )
                        .foregroundColor(.white)
                        .frame(width: 150)
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
                            TextField("09", text: $gameDate, axis: .vertical)
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
                                content: PlaceNameText, selection: $gamePlaceText, activeTint: .primary.opacity(0.2), inActiveTint: .black.opacity(0.8), dynamic: true
                            )
                            .foregroundColor(.white)
                            .frame(width: 200)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 25)
                    Divider()
                }
                
                // MARK: Text
                HStack {
                    Image("Details")
                    TextField("Write a document", text: $gameDocumentText)
                        .frame(height: 40)
                        .textContentType(.emailAddress)
                        .gBorder(0.5, .black)
                }
                .padding(.vertical, 8)
            }
            .padding(12)
        }
        .vAlign(.top)
        // Loading View
        .overlay {
            LoadingView(show: $isLoading)
        }
    }
    
    
    
    
    // MARK: Game Content To Firebase
    func createGame() {
        
        isLoading = true
        showKeyboard = false
        
        Task {
            do {
                guard let profileURL = profileURL else { return }
                // Step 1: Uploading Image If any
                // Used to delete the Game (Later shown in the Video)
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Game_Images").child(imageReferenceID)
                if let gameImageDate {
                    let _ = try await storageRef.putDataAsync(gameImageDate)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    // Step 3: Create Game Object With Image Id And URL
                    let game = Game(date: gameDate, titleText: gameTitleText, placeText: gamePlaceText, playStyleText: gamePlayStyleText, documentText: gameDocumentText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(game)
                } else {
                    // Step 2: Directly Game Text Data to Firebase (Since there is no Images Present)
                    let game = Game(date: gameDate, titleText: gameTitleText, placeText: gamePlaceText, playStyleText: gamePlayStyleText, documentText: gameDocumentText, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(game)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase( _ game: Game) async throws {
        // Writing Document to Firebase FireStore
        let doc = Firestore.firestore().collection("Games").document()
        let _ = try doc.setData(from: game, completion: { error in
            if error == nil {
                // Game Successfully Stored at Firebase
                isLoading = false
                var updateGame = game
                updateGame.id = doc.documentID
                onGame(updateGame)
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

struct CreateNewGameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewGameView { _ in
            
        }
    }
}



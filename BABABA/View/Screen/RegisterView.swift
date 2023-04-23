//
//  RegisterView.swift
//  BABABA
//
//  Created by Snow on 2023/01/13.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

// MARK: Register View
struct RegisterView: View {
    
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userProfilePicData: Data?
    // MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    
    var body: some View {
        VStack(spacing: 10){
            Text("Register")
                .font(.largeTitle)
                .fontDesign(.monospaced)
                .hAlign(.leading)
                .padding(.top, 25)
            
            //MARK: For Smaller Size Optimization
            ScrollView(.vertical, showsIndicators: false) {
                HelperView()
                
                // MARK: Register Button
                Button("Already have an account?") {
                    dismiss()
                }
                .font(.body)
                .fontDesign(.monospaced)
                .foregroundColor(.gray)
                .padding(.top,10)
            }

        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            // MARK: Extracting UIImage From PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else{ return }
                        // MARK: UI Must be Updated on Main Thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch { }
                }
            }
        }
        
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        
        VStack(spacing: 12) {
            
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $userName)
                .frame(height: 40)
                .textContentType(.emailAddress)
                .border(2, .black)
                .fontDesign(.monospaced)
                .padding(.top, 25)
            
            TextField("Email", text: $emailID)
                .frame(height: 40)
                .textContentType(.emailAddress)
                .border(2, .black)
                .fontDesign(.monospaced)
                .padding(.top, 25)
            
            SecureField("Password", text: $password)
                .frame(height: 40)
                .textContentType(.emailAddress)
                .border(2, .black)
                .fontDesign(.monospaced)
                .padding(.top, 25)
            
            Button(action: registerUser) {
                // MARK: Login Button
                Text("SIGN UP")
                    .fontWeight(.semibold)
                    .frame(height: 35)
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableWithOpacity(userName == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top, 15)
        }
    }
    
    func registerUser() {
        
        isLoading = true
        closeKeyboard()
        
        Task {
            do {
                // Step 1:Creating Firebase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // Step 2: Uploading Profile Photo Into Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                // Step 3: Downloading Photo URL
                let downloadURL = try await storageRef.downloadURL()
                // Step 4: Creating a User Firestore Object
                let user = User(username: userName, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL )
                // Step 5: Saving user Doc into Firestore Database
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        // MARK: Print Saved Successfully
                        print("Saved Successfully")
                        userNameStored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                        
                    }
                })
            } catch {
                // MARK: Deleting Created Account In Case of Failure
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError( _ error: Error) async {
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
    
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

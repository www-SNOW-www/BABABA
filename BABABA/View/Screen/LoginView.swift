//
//  LoginView.swift
//  BABABA
//
//  Created by Snow on 2023/01/11.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    // MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMesssage: String = ""
    @State var isLoading: Bool = false
    // MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        
        VStack(spacing: 10){
            Text("Log in")
                .font(.largeTitle)
                .fontDesign(.monospaced)
                .hAlign(.leading)
                .padding(.top, 25)
            
            
            VStack(spacing: 12) {
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
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontDesign(.monospaced)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
                    // MARK: Login Button
                    Text("LOG IN")
                        .fontWeight(.semibold)
                        .frame(height: 35)
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 15)
            }
            
            // MARK: Register Button
            Button("Don't have an account?") {
                createAccount.toggle()
            }
            .font(.body)
            .fontDesign(.monospaced)
            .foregroundColor(.gray)
            .padding(.top,10)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        
        // MARK: Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        
        // MARK: Displaying Alert
        .alert(errorMesssage, isPresented: $showError, actions: {})
    }
    
    func loginUser() {
        
        isLoading = true
        closeKeyboard()
        
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: If User if Found then Fetching User Data From Firestore
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        // MARK: UI Updating Must be Run On Main Thread
        await MainActor.run(body: {
            // Setting UserDefaults data and Changing App's Auth Status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func resetPassword() {
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error) async {
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMesssage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}



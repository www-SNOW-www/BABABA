//
//  ProfileView.swift
//  BABABA
//
//  Created by Snow on 2023/01/13.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    
    // MARK: My Profile Data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let myProfile {
                    ProfileContentView(user: myProfile)
                        .refreshable {
                            // MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("MY PROFILE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // MARK: Two Actions
                        // 1. Logout
                        // 2. Delete Account
                        Button("Logout", action: logOutUser)
                        
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
        }
        .task {
            // This Modifer is like onAppear
            // So Fetching for the First Time Only
            if myProfile != nil { return }
            // MARK: Initial Fetch
            await fetchUserData()
        }
    }
    
    // MARK: Fetching User Data
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else { return }
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    // MARK: Logging User Out
    func logOutUser() {
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    func deleteAccount() {
        
        isLoading = true
        
        Task {
            do {
                
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                // Step 1: First Deleting Profile Image Storage
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                // Step 2: Deleting Firestore User Document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                // Final Step: Deleting Auth Account and Setting log Status to False
                try await Auth.auth().currentUser?.delete()
                logStatus = false
                
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: Setting Error
    func setError(_ error: Error) async {
        // MARK: UI Must be run on Main Thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


//
//  BABABAApp.swift
//  BABABA
//
//  Created by Snow on 2023/01/11.
//

import SwiftUI
import Firebase

@main
struct BABABAApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  ContentView.swift
//  BABABA
//
//  Created by Snow on 2023/01/11.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        // MARK: Redirecting User Based on Log Status
        if logStatus {
            HomeView()
        } else {
            IntroView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

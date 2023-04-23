//
//  StartView.swift
//  BABABA
//
//  Created by Snow on 2023/01/17.
//

import SwiftUI

struct StartView: View {
    
    @State var createAccount: Bool = false
    @State var loginAccount: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, alignment: .center)
                Text("BABABA")
                    .font(.custom("BreeSerif-Regular", size: 45))
            }
            
            Spacer()
            
            HStack {
                
                Button("LOG IN") {
                    loginAccount.toggle()
                }
                .fontWeight(.medium)
                .frame(height: 30)
                .foregroundColor(.black)
                .hAlign(.center)
                .gBorder(2, .black)
                
                Button("REGISTER") {
                    createAccount.toggle()
                }
                .fontWeight(.medium)
                .frame(height: 30)
                .foregroundColor(.white)
                .hAlign(.center)
                .fillView(.black)
                
                // MARK: Register&Login View VIA Sheets
                .fullScreenCover(isPresented: $loginAccount) {
                    LoginView()
                }
                
                .fullScreenCover(isPresented: $createAccount) {
                    RegisterView()
                }
            }
        }
        .padding(15)
    }
}



struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

//
//  ContentView.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    SettingsView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticationUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

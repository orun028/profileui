//
//  ContentView.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import SwiftUI
import Firebase

enum AuthenticationState {
    case authentication
    case loading
    case authenticated
}

class AuthView: ObservableObject {
    @Published var authenticationState: AuthenticationState = .loading
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            if let _ = user {
                self.authenticationState = .authenticated
            } else {
                self.authenticationState = .authentication
            }
        }
    }
    
    func stopListening() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

struct ContentView: View {
    @StateObject var authView = AuthView()
    
    var body: some View {
        Group {
            switch authView.authenticationState {
            case .authentication:
                NavigationStack {
                    AuthenticationView()
                }
            case .loading:
                NavigationStack {
                    ProgressView()
                }
            case .authenticated:
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .onAppear {
            authView.listen()
        }
        .onDisappear {
            authView.stopListening()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

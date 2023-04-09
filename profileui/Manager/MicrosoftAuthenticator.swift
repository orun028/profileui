//
//  MicrosoftAuthenticator.swift
//  profileui
//
//  Created by Admin on 09/04/2023.
//

import Firebase
import SafariServices

class MicrosoftAuthenticator: ObservableObject {
    @Published var isAuthenticating = false
    @Published var error: Error?
    
    private var provider: OAuthProvider {
        return OAuthProvider(providerID: "microsoft.com")
    }
    
    func authenticate() {
        isAuthenticating = true
        
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                self.error = error
                self.isAuthenticating = false
                return
            }
            
            guard let credential = credential else {
                self.error = NSError(domain: "com.example.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                self.isAuthenticating = false
                return
            }
            
            if let authURL = credential.provider?.credentialRepresentation()?.authURL {
                let safariVC = SFSafariViewController(url: authURL)
                
                UIApplication.shared.windows.first?.rootViewController?.present(safariVC, animated: true, completion: nil)
            }
            
            Auth.auth().signIn(with: credential) { result, error in
                self.isAuthenticating = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                // User is signed in with Microsoft and Firebase.
            }
        }
    }
}


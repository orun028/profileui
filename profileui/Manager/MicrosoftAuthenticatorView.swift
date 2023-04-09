import SwiftUI
import Firebase
import AuthenticationServices

struct MicrosoftAuthenticatorView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ASWebAuthenticationSession {
        let provider = OAuthProvider(providerID: "microsoft.com")
        provider.scopes = ["User.Read"]
        let authSession = ASWebAuthenticationSession(url: provider.oauthRequestURL(), callbackURLScheme: "YOUR_CALLBACK_URL_SCHEME") { (callbackURL, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let callbackURL = callbackURL else {
                print("No callback URL provided")
                return
            }
            
            let credential = provider.credential(withProviderID: provider.providerID, accessToken: nil, idToken: nil, rawNonce: nil, profile: nil, email: nil)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                print("Successfully authenticated with Microsoft")
            }
        }
        
        return authSession
    }
    
    func updateUIViewController(_ uiViewController: ASWebAuthenticationSession, context: Context) {
        // Do nothing
    }
}

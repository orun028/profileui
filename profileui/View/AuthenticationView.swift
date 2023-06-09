//
//  AuthenticationView.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
 
    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idTokden = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        let tokens = GoogleSignInResultModel(idToken: idTokden, accessToken: accessToken, name: name, email: email)
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInMicrosoft(provider: OAuthProvider) async throws {
        provider.customParameters = [
            "prompt": "login",
        ]
        provider.scopes = ["user.read"]
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                print("Error getting Microsoft credential: \(error.localizedDescription)")
                return
            }
            guard let credential = credential else {
                print("No credential")
                return
            }
            Task {
                let authDataResult = try await AuthenticationManager.shared.signIn(credential: credential)
                try await UserManager.shared.createNewUser(user: DBUser(auth: authDataResult))
            }
        }
    }
}

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    var provider = OAuthProvider(providerID: "microsoft.com")
    
    var body: some View {
        VStack {
            Text("Welcome to ProfireUI")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Sign in")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button{
                Task {
                    do {
                        try await viewModel.signInGoogle()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Label(
                    title: { Text("Sign in with Google") },
                    icon: {
                        Image("google")
                        .resizable()
                        .frame(width: 30, height: 30)
                    }
                )
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(Color.black)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
            Spacer().frame(height: 20)
            Button{
                Task {
                    do {
                        try await viewModel.signInMicrosoft(provider: provider)
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Label(
                    title: { Text("Sign in with Microsoft") },
                    icon: {
                        Image("microsoft")
                        .resizable()
                        .frame(width: 30, height: 30)
                    }
                )
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(Color.black)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
        }
        .padding(40)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}

//
//  SettingsView.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import SwiftUI
import LocalAuthentication
import CoreLocation

@MainActor
final class SettingViewModel: ObservableObject {
    @Published var showAlert = false
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticationUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func checkFaceID() throws -> Bool {
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authorize with touch id!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let alert = UIAlertController(title: "Success", message: "Authentication successful", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                        
                        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                                rootViewController.present(alert, animated: true, completion: nil)
                            }
                    }
                    return
                } else {
                    if let error = error {
                        print("Authentication failed \(error)")
                    } else {
                        print("Authentication failed")
                    }
                }
            }
            return false
        }
        else {
            //let alert = UIAlertController(title: "Unavailable", message: "You cant use this feature", preferredStyle: .alert)
            //alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            return false
        }
    }
}
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = SettingViewModel()
    
    var body: some View {
       
        VStack {
            if let user = viewModel.user {
                HStack(alignment: .top) {
                    Image("300-9")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: -1) {
                        Text("\(user.email!)")
                            .font(.headline)
                            .padding(.bottom, 1)
                        
                        Text("ID: \(user.userId.uppercased())")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Admin")
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .background(.green)
                            .cornerRadius(3)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            }
            
            List{
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.logOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                Section {
                    Button {
                        Task{
                            do {
                                let success = try viewModel.checkFaceID()
                                print(success)
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Check Face ID")
                    }
                    
                    NavigationLink(destination: MapView(showSignInView: $showSignInView)) {
                        Text("Check the current location")
                    }
                    
                    NavigationLink(destination: CameraView()) {
                        Text("Check camera")
                    }
                    
                }
            }
            .background(.white)
            .padding(.top)
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}

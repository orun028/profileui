//
//  SettingsView.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import SwiftUI
import LocalAuthentication
import CoreLocation
import SystemConfiguration.CaptiveNetwork

@MainActor
final class SettingViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticationUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
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
                            try AuthenticationManager.shared.signOut()
                        } catch {
                            print(error)
                        }
                    }
                }
                Section {
                    Button {
                        Task{
                            do {
                                try Utilities.shared.checkFaceID()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Check Face ID")
                            .foregroundColor(.gray)
                    }
                    
                    Button {
                        let type = Utilities.shared.getNetworkType()
                        let ssid = Utilities.shared.getWiFiSsid()
//                        let publicIP = Utilities.shared.getPublicIPAddress()
                        Utilities.shared.showAlert(title: "Infomation network", message: "\(type): \(ssid ?? "")")
                    } label: {
                        Text("Show infomation network")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink(destination: MapView()) {
                        Text("Check the current location")
                    }
                    
                    NavigationLink(destination: CameraView()) {
                        Text("Check QR-Code")
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
        SettingsView()
    }
}

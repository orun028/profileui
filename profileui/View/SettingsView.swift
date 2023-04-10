//
//  SettingsView.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import SwiftUI
import LocalAuthentication
import MapKit
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
    @State private var ssid: String?
    @State private var faceidState = false
    @State private var isShowingScanner = false
    @State private var qrcode = ""
    @StateObject var mapViewModel = MapViewModel()
    
    init() {
        ssid = Utilities.shared.getWiFiSsid()
    }
    
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
                .padding()
            }
            Text("Wifi SSID: \(ssid ?? "None")")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Text("QR-code: \(qrcode)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
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
                                faceidState = try Utilities.shared.checkFaceID()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Check Face ID")
                            .foregroundColor(.gray)
                    }
                    NavigationLink(destination: MapView(), label: {
                        Text("Map view")
                    })
                    Button  {
                        Task{
                            self.isShowingScanner = true
                        }
                    } label: {
                        Text("Check-in")
                    }
                }

            }
            .background(.white)
            .padding(.top)
        }
        .onAppear(perform: {
            mapViewModel.locationManager.requestWhenInUseAuthorization()
        })
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationBarTitle("Settings")
        .sheet(isPresented: $isShowingScanner, onDismiss: {
            // Handle what happens when the scanner is dismissed (e.g. save the scanned code)
            Task {
                do {
                    try await self.saveScannedCode()
                } catch {
                    print(error)
                }
                
            }
        }) {
            QRCodeScanner(scannedCode: self.$qrcode)
        }
    }
    
    func saveScannedCode() async throws {
        
        let pinlocation = try await LocationManager.shared.getLocation(locationid: "1")
        if pinlocation.qrcode == qrcode {
            print("ok qrcode")
            let location2 = CLLocationCoordinate2D(latitude: Double(pinlocation.latitude)!, longitude: Double(pinlocation.longitude)!)
            mapViewModel.showLineDeviceToAnnotation(annotationCoordinate: location2)
            let locationcount = mapViewModel.locationToPin
            print("ok pin \(String(describing: locationcount))")
            if locationcount! < 1000 {
                print("ok 1000")
                if let userdata = viewModel.user {
                    let request = DBRequest(userId: userdata.userId, email: userdata.email, dateCreated: Date(), location: nil)
                    try await RequestManager.shared.setRequest(request: request)
                    Utilities.shared.showAlert(title: "Success", message: "Check-in successful")
                }
            }
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

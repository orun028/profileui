//
//  ViewTest.swift
//  profileui
//
//  Created by Admin on 05/04/2023.
//

import SwiftUI
import CoreLocation

struct ViewTest: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showSignInView: Bool
    @StateObject var viewModel = MapViewModel()
    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack{
            
    }
    
}

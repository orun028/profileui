//
//  LocationsViewModel.swift
//  profileui
//
//  Created by Admin on 05/04/2023.
//

import MapKit
import SwiftUI

class LocationViewModel: ObservableObject {
    
    // All loaded locations
    @Published var locations: [Location]
    
}

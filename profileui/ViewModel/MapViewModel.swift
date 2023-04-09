//
//  MapViewModel.swift
//  profileui
//
//  Created by Admin on 05/04/2023.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    @Published var permissionDenied = false
    
    @Published var locationToPin: Double!
    @Published var location: CLLocation!
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            ()
        }
    }
    
    func showLineDeviceToAnnotation(annotationCoordinate: CLLocationCoordinate2D) {
        if (location != nil) {
            
            print("Location: \(location.coordinate.latitude)")
            let annotationLocation  = CLLocation(latitude: annotationCoordinate.latitude, longitude: annotationCoordinate.longitude)
            print("Pin: \(annotationCoordinate.latitude)")
            
            let distanceInMeters = annotationLocation.distance(from: location)
            self.locationToPin = distanceInMeters / 1000
        } else {
            print("No location")
        }
        
    }
    
    func focusLocation(){
        guard let _ = region else { return }
        print("Focus_location: \(region.span.latitudeDelta)")
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 0.01, longitudinalMeters: 0.01)
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
}

//
//  MapView.swift
//  profileui
//
//  Created by Admin on 05/04/2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MapViewModel()
    // Lets put a defaut distance of 1 = 1km = 1000m
    // 0.1 to 100m -> 0.01 -> 10m
    let distance: Double = 0.05 // unit km = 10m
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 10.7507409, longitude: 106.7128363), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        ZStack{
            MapUIView(region: region, distance: distance)
                .environmentObject(viewModel)
                .ignoresSafeArea()
            
            VStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.secondary)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                    Spacer()
                
                VStack{

                    Button(action: viewModel.focusLocation, label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.secondary)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
                .padding(.bottom)
                
                CardMapView(region: region, distance: distance)
                    .transition(.move(edge: .bottom))
            }
            .frame(maxWidth: .infinity)
            
        }
        .alert(isPresented: $viewModel.permissionDenied, content: {
            Alert(
                title: Text("Permission Denied"),
                message: Text("Please Enable Permission In App Settings"),
                  dismissButton: .default(Text("Goto Settings")) {
                      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
        })
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CardMapView: View {
    let region: MKCoordinateRegion
    let distance: Double
    @StateObject var viewModel = MapViewModel()
    @State var locationToPin: Double = 0
    @State var time: Date!
    
    var body: some View {
        VStack{
            
            HStack {
                Text("MY DEVICE: \(Int(locationToPin*1000))M/\(Int(distance*1000))M")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .frame(alignment: .leading)
                    .padding(.top, 10)
                if Int(locationToPin*1000) != 0 {
                    if Int(locationToPin*1000) < Int(distance*1000) {
                        Text("OK")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .frame(alignment: .leading)
                            .padding(.top, 10)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12){
                HStack {
                    Text("Pin")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Home (\(region.center.latitude),\(region.center.longitude))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.top)
                .padding(.horizontal)

                    HStack {
                        Text("Device")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        if (viewModel.location != nil) {
                            Text("\(viewModel.location.coordinate.latitude),\(viewModel.location.coordinate.longitude)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            }
                    }
                    .padding()
              
                
            }
            .frame(minHeight: 50)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            
            Button {
                if (viewModel.location != nil) {
                    viewModel.showLineDeviceToAnnotation(annotationCoordinate: region.center)
                    locationToPin = viewModel.locationToPin
                }
                
            } label: {
                Text("CHECK DEVICE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .opacity(viewModel.location != nil ? 1 : 0.6)
                
            }
        }
        .padding()
        .padding(.bottom, 16)
        .background(.white)
        .cornerRadius(12)
        
    }
}

struct MapUIView: UIViewRepresentable {
    
    let region: MKCoordinateRegion
    let distance: Double

    let locationManager = CLLocationManager()
    var locationPermissionGranted: Bool = false
    
    @EnvironmentObject var viewModel: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return MapUIView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = viewModel.mapView
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        // Add the annotation to the map
        let annotation = MapAnnotation(coordinate: region.center, title: "Home", subtitle: "This is where I am")
        mapView.addAnnotation(annotation)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)

//        let circle = MKCircle(center: region.center, radius: distance * 1000)
//        let mapRect = circle.boundingMapRect
//
//        view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
//        view.addOverlay(circle)
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation.isKind(of: MKUserLocation.self) { return nil }
            else {
                
                let annotationPin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationPin.markerTintColor = UIColor(named: "MapColor")
                annotationPin.animatesWhenAdded = true
                annotationPin.canShowCallout = true
                return annotationPin
            }
        }
        
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            guard let circleOverlay = overlay as? MKCircle else {
//                return MKOverlayRenderer()
//            }
//            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
//            circleRenderer.fillColor = UIColor(named: "MapZoneColor")
//            circleRenderer.strokeColor = UIColor(named: "MapColor")
//            circleRenderer.lineWidth = 1.5
//            return circleRenderer
//        }

    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

class MapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

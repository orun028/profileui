//
//  LocationManager.swift
//  profileui
//
//  Created by Admin on 10/04/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBLocation: Codable {
    let locationid: String
    let latitude: String
    let longitude: String
    let qrcode: String
    
    init(locationid: String, latitude: String, longitude: String, qrcode: String) {
        self.locationid = locationid
        self.latitude = latitude
        self.longitude = longitude
        self.qrcode = qrcode
    }
}

final class LocationManager {
    static let shared = LocationManager()
    private init() {}
    
    private let collection = Firestore.firestore().collection("locations")
    
    private func useDocumnet(locationid: String) -> DocumentReference {
        collection.document(locationid)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func setLocation(location: DBLocation) async throws {
        try useDocumnet(locationid: location.locationid).setData(from: location, merge: false, encoder: encoder)
    }
    
    func getLocation(locationid: String) async throws -> DBLocation {
        try await useDocumnet(locationid: locationid).getDocument(as: DBLocation.self, decoder: decoder)
    }
    
}

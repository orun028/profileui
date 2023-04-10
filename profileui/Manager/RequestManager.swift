//
//  RequestManager.swift
//  profileui
//
//  Created by Admin on 10/04/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBRequest: Codable {
    let userId: String
    let email: String?
    let dateCreated: Date?
    let location: String?
    
    init(userId: String, email: String?, dateCreated: Date?, location: String?) {
        self.userId = userId
        self.email = email
        self.dateCreated = dateCreated
        self.location = location
    }
}

final class RequestManager {
    static let shared = RequestManager()
    private init() {}
    
    private let collection = Firestore.firestore().collection("requests")
    
    private func useDocumnet(userId: String) -> DocumentReference {
        collection.document(userId)
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
    
    func setRequest(request: DBRequest) async throws {
        try useDocumnet(userId: request.userId).setData(from: request, merge: false, encoder: encoder)
    }
    
}

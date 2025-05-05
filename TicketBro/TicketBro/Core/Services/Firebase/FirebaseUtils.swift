//
//  FirebaseUtils.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import Firebase
import Firebase

// Конвертация Firestore GeoPoint в нашу GeoPoint и обратно
extension Cinema.GeoPoint {
    init(firebaseGeoPoint: GeoPoint) {
        self.latitude = firebaseGeoPoint.latitude
        self.longitude = firebaseGeoPoint.longitude
    }
    
    func toFirebaseGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
}

// Расширение для Timestamp
extension Date {
    // Конвертация из Firestore Timestamp в Date
    init(timestamp: Timestamp) {
        self = timestamp.dateValue()
    }
    
    // Конвертация из Date в Firestore Timestamp
    func toTimestamp() -> Timestamp {
        return Timestamp(date: self)
    }
}

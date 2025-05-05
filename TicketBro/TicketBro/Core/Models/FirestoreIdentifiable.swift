//
//  FirestoreIdentifiable.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Models/Protocols/Identifiable.swift
import Foundation

protocol FirestoreIdentifiable {
    var id: String? { get set }
    
    // Метод для получения ID документа, гарантирующий, что ID не пустой
    func safeID() throws -> String
}

extension FirestoreIdentifiable {
    func safeID() throws -> String {
        guard let id = id, !id.isEmpty else {
            throw ModelError.missingID
        }
        return id
    }
}

// Ошибки, связанные с моделями
enum ModelError: Error {
    case missingID
    case invalidData
    case notFound
    case parseError
}
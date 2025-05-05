//
//  Promotion.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Models/Promotion.swift
import Foundation
import FirebaseFirestore

struct Promotion: Identifiable, Codable {
    @DocumentID var id: String? // ID акции в Firebase
    var title: String
    var description: String
    var imageURL: String
    var startDate: Date
    var endDate: Date
    var discountPercentage: Double? // Процент скидки, если применимо
    var discountAmount: Double? // Фиксированная сумма скидки, если применимо
    var promoCode: String? // Промокод, если применимо
    var applicableMovieIds: [String]? // IDs фильмов, к которым применима акция
    var applicableCinemaIds: [String]? // IDs кинотеатров, к которым применима акция
    var isActive: Bool = true // Активна ли акция
}

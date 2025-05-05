//
//  SeatRow.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Models/SeatRow.swift
import Foundation

struct SeatRow: Identifiable, Codable {
    var id = UUID().uuidString
    var rowNumber: Int
    var seats: [Seat]
}

struct Seat: Identifiable, Codable {
    var id = UUID().uuidString
    var seatNumber: Int
    var seatType: SeatType
    var isAvailable: Bool = true
    
    enum SeatType: String, Codable {
        case standard = "standard"
        case vip = "vip"
        case wheelchair = "wheelchair"
        case loveSeat = "love_seat"
    }
}
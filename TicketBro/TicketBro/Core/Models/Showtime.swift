//
//  Showtime.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Models/Showtime.swift
import Foundation
import FirebaseFirestore

struct Showtime: Identifiable, Codable {
    @DocumentID var id: String? // ID сеанса в Firebase
    var movieId: String // ID фильма
    var cinemaId: String // ID кинотеатра
    var hallId: String // ID зала
    var startTime: Date // Дата и время начала сеанса
    var endTime: Date // Дата и время окончания сеанса
    var format: Movie.MovieFormat // Формат показа
    var language: String
    var subtitles: String?
    var priceCategories: [PriceCategory] // Категории цен для разных типов мест
    var availableSeats: Int // Количество доступных мест
    var totalSeats: Int // Общее количество мест
    var isActive: Bool = true // Активен ли сеанс
    
    struct PriceCategory: Codable {
        var seatType: Seat.SeatType
        var price: Double
    }
}

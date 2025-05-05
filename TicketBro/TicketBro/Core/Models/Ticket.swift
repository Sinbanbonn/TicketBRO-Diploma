//
//  Ticket.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import Foundation
import FirebaseFirestore

struct Ticket: Identifiable, Codable {
    @DocumentID var id: String? // ID билета в Firebase
    var userId: String // ID пользователя
    var sessionId: String // ID сеанса
    var movieId: String // ID фильма
    var cinemaId: String // ID кинотеатра
    var hallId: String // ID зала
    var row: Int // Номер ряда
    var seat: Int // Номер места
    var price: Double // Цена билета
    var purchaseDate: Date // Дата и время покупки
    var sessionDate: Date // Дата и время сеанса
    var status: Status // Статус билета
    var paymentId: String? // ID платежа
    var paymentMethod: String // Метод оплаты
    
    // Вычисляемые свойства для отображения
    var movieTitle: String = ""
    var moviePosterURL: String = ""
    var cinemaName: String = ""
    var hallName: String = ""
    var format: MovieFormat = ._2D
    
    var canCancel: Bool {
        // Можно отменить билет не позднее чем за 3 часа до сеанса
        return sessionDate > Date().addingTimeInterval(3 * 60 * 60)
    }
    
    // Статус билета
    enum Status: String, Codable {
        case active = "active" // Активный
        case used = "used" // Использованный
        case expired = "expired" // Просроченный
        case cancelled = "cancelled" // Отмененный
        
        var localizedTitle: String {
            switch self {
            case .active:
                return "Активен"
            case .used:
                return "Использован"
            case .expired:
                return "Просрочен"
            case .cancelled:
                return "Отменен"
            }
        }
    }
    
    // Формат билета
    enum MovieFormat: String, Codable {
        case _2D = "2d"
        case _3D = "3d"
        case imax = "imax"
        case _4DX = "4dx"
        case screenX = "screen_x"
        case dolbyAtmos = "dolby_atmos"
    }
    
    // Статический метод для создания заглушки
    static var placeholder: Ticket {
        let ticket = Ticket(
            id: "placeholder",
            userId: "user1",
            sessionId: "session1",
            movieId: "movie1",
            cinemaId: "cinema1",
            hallId: "hall1",
            row: 10,
            seat: 15,
            price: 450.0,
            purchaseDate: Date().addingTimeInterval(-86400), // Вчера
            sessionDate: Date().addingTimeInterval(86400), // Завтра
            status: .active,
            paymentId: "payment1",
            paymentMethod: "Банковская карта"
        )
        
        // Заполняем вычисляемые свойства для отображения
        var placeholderTicket = ticket
        placeholderTicket.movieTitle = "Название фильма"
        placeholderTicket.moviePosterURL = ""
        placeholderTicket.cinemaName = "Название кинотеатра"
        placeholderTicket.hallName = "VIP зал"
        placeholderTicket.format = ._3D
        
        return placeholderTicket
    }
}

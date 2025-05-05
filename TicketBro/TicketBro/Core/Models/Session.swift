//
//  Session.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Модель сеанса фильма (Session.swift)
import Foundation
import FirebaseFirestore

struct Session: Identifiable, Codable {
    @DocumentID var id: String? // ID сеанса в Firebase
    var movieId: String // ID фильма
    var cinemaId: String // ID кинотеатра
    var hallId: String // ID зала
    var date: Date // Дата и время сеанса
    var price: Double // Базовая цена билета
    var format: MovieFormat // Формат показа
    var isActive: Bool = true // Активен ли сеанс
    var soldSeats: [SoldSeat] = [] // Проданные места
    
    // Формат сеанса
    enum MovieFormat: String, Codable {
        case _2D = "2d"
        case _3D = "3d"
        case imax = "imax"
        case _4DX = "4dx"
        case screenX = "screen_x"
        case dolbyAtmos = "dolby_atmos"
    }
    
    // Структура для проданных мест
    struct SoldSeat: Codable, Equatable {
        var row: Int // Номер ряда
        var seat: Int // Номер места
        var ticketId: String // ID билета
        
        // Реализация протокола Equatable
        static func == (lhs: SoldSeat, rhs: SoldSeat) -> Bool {
            return lhs.row == rhs.row && lhs.seat == rhs.seat
        }
    }
    
    // Вычисляемые свойства
    var isSoldOut: Bool {
        // Проверяем, все ли места в зале проданы
        // Для реализации нужно знать вместимость зала
        // Пока возвращаем заглушку
        return false
    }
    
    var isPast: Bool {
        return date < Date()
    }
    
    // Проверка, продано ли место
    func isSeatSold(row: Int, seat: Int) -> Bool {
        return soldSeats.contains(where: { $0.row == row && $0.seat == seat })
    }
    
    // Добавление проданного места
    mutating func addSoldSeat(row: Int, seat: Int, ticketId: String) {
        if !isSeatSold(row: row, seat: seat) {
            soldSeats.append(SoldSeat(row: row, seat: seat, ticketId: ticketId))
        }
    }
    
    // Удаление проданного места
    mutating func removeSoldSeat(row: Int, seat: Int) {
        soldSeats.removeAll(where: { $0.row == row && $0.seat == seat })
    }
}


// Расширение для Session
extension Session {
    // Для корректной навигации и отображения
    static var placeholder: Session {
        Session(
            id: "placeholder",
            movieId: "moviePlaceholder",
            cinemaId: "cinemaPlaceholder",
            hallId: "1",
            date: Date().addingTimeInterval(60*60*24), // завтра
            price: 350.0,
            format: ._2D,
            isActive: true,
            soldSeats: []
        )
    }
    
    // Все возможные форматы для отображения
    static let allFormats: [MovieFormat] = [._2D, ._3D, .imax, ._4DX, .screenX, .dolbyAtmos]
}

// Дополнение к определению MovieFormat для возможности перебора всех вариантов
extension Session.MovieFormat: CaseIterable {
    public static var allCases: [Session.MovieFormat] {
        return [._2D, ._3D, .imax, ._4DX, .screenX, .dolbyAtmos]
    }
}

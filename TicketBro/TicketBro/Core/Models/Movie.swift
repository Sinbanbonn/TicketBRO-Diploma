//
//  Movie.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import Foundation
import FirebaseFirestore

struct Movie: Identifiable, Codable {
    @DocumentID var id: String? // ID фильма в Firebase
    var title: String
    var originalTitle: String? // Название на языке оригинала
    var year: Int
    var duration: Int // Длительность в минутах
    var genres: [String]
    var description: String
    var posterURL: String // URL постера
    var backdropURL: String? // URL фонового изображения
    var trailerURL: String? // URL трейлера
    var director: String
    var cast: [String]
    var rating: Double // Рейтинг фильма (от 0 до 10)
    var ageRestriction: String // Возрастное ограничение
    var releaseDate: Date
    var endScreeningDate: Date? // Дата окончания показа
    var language: String
    var subtitles: String?
    var format: [MovieFormat] // Форматы показа фильма
    
    enum MovieFormat: String, Codable {
        case _2D = "2d"
        case _3D = "3d"
        case imax = "imax"
        case _4DX = "4dx"
        case screenX = "screen_x"
        case dolbyAtmos = "dolby_atmos"
    }
}

extension Movie {
    // Получает UIImage для постера
    func getPosterImage() -> UIImage? {
        // Пробуем загрузить из ассетов
        if let assetImage = UIImage(named: posterURL) {
            return assetImage
        }
        
        // Если не нашли в ассетах, пробуем SF Symbol
        return UIImage(systemName: posterURL) ?? UIImage(systemName: "film.fill")
    }
    
    // Получает UIImage для фонового изображения
    func getBackdropImage() -> UIImage? {
        guard let backdropURL = backdropURL else { return nil }
        
        // Пробуем загрузить из ассетов
        if let assetImage = UIImage(named: backdropURL) {
            return assetImage
        }
        
        // Если не нашли в ассетах, пробуем SF Symbol
        return UIImage(systemName: backdropURL) ?? UIImage(systemName: "photo.fill")
    }
}

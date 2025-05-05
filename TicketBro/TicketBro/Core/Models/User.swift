//
//  User.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//
import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String? // ID пользователя в Firebase
    var email: String
    var name: String
    var phoneNumber: String?
    var avatar: String? // URL изображения профиля
    var registrationDate: Date
    var favoriteMovies: [String] = [] // IDs избранных фильмов
    var favoriteCinemas: [String] = [] // IDs избранных кинотеатров
    var ticketIds: [String] = [] // IDs купленных билетов
    
    // Конструктор по умолчанию для Codable
    init() {
        self.email = ""
        self.name = ""
        self.registrationDate = Date()
    }
    
    // Конструктор для создания нового пользователя
    init(email: String, name: String, phoneNumber: String? = nil, avatar: String? = nil) {
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.avatar = avatar
        self.registrationDate = Date()
    }
    
    // Конструктор для создания пользователя с ID
    init(id: String, email: String, name: String, phoneNumber: String? = nil, avatar: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.avatar = avatar
        self.registrationDate = Date()
    }
}

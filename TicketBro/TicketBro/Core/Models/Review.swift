//
//  Review.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Models/Review.swift
import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String? // ID отзыва в Firebase
    var userId: String // ID пользователя
    var userName: String // Имя пользователя
    var movieId: String? // ID фильма (если отзыв о фильме)
    var cinemaId: String? // ID кинотеатра (если отзыв о кинотеатре)
    var rating: Double // Оценка от 1 до 5
    var comment: String // Текст отзыва
    var date: Date // Дата отзыва
    var likes: Int = 0 // Количество лайков
    var photoURLs: [String] = [] // URL фото от пользователя
}

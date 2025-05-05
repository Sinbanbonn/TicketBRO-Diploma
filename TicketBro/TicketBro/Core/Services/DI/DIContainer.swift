// DIContainer.swift - обновленная версия
import Foundation
import Firebase

// Класс для управления зависимостями в приложении
class DIContainer {
    // Сервисы Firebase
    let authService: FirebaseAuthService
    let userService: UserService
    let storageService: StorageService
    
    // Сервисы для работы с моделями
    let cinemaService: FirestoreService<Cinema>
    let movieService: FirestoreService<Movie>
    let sessionService: FirestoreService<Session> // Добавляем сервис для сеансов
    let showtimeService: FirestoreService<Showtime>
    let ticketService: FirestoreService<Ticket>
    let paymentService: FirestoreService<Payment>
    let reviewService: FirestoreService<Review>
    let promotionService: FirestoreService<Promotion>
    
    // Инициализация контейнера с созданием всех необходимых сервисов
    init() {
        // Инициализируем сервисы Firebase
        self.authService = FirebaseAuthService()
        self.storageService = StorageService()
        self.userService = UserService()
        
        // Инициализируем сервисы для моделей данных
        self.cinemaService = FirestoreService<Cinema>(collectionPath: "cinemas")
        self.movieService = FirestoreService<Movie>(collectionPath: "movies")
        self.sessionService = FirestoreService<Session>(collectionPath: "sessions") // Инициализируем сервис для сеансов
        self.showtimeService = FirestoreService<Showtime>(collectionPath: "showtimes")
        self.ticketService = FirestoreService<Ticket>(collectionPath: "tickets")
        self.paymentService = FirestoreService<Payment>(collectionPath: "payments")
        self.reviewService = FirestoreService<Review>(collectionPath: "reviews")
        self.promotionService = FirestoreService<Promotion>(collectionPath: "promotions")
    }
}

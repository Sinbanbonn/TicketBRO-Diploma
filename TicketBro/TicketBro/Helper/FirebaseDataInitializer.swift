//
//  FirebaseDataInitializer.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import Firebase
import FirebaseFirestore

// Класс для добавления тестовых данных в Firebase
class FirebaseDataInitializer {
    private let db = Firestore.firestore()
    
    // Главный метод инициализации - максимально упрощенный
    func initializeAppDataSimplified() {
        print("🔄 Начинаем инициализацию тестовых данных...")
        
        // Шаг 1: Добавляем кинотеатры
        addTestCinemas { success in
            if success {
                // Шаг 2: Добавляем фильмы
                self.addTestMovies { success in
                    if success {
                        // Шаг 3: Добавляем сеансы
                        self.addTestShowtimes { success in
                            if success {
                                print("✅ Все тестовые данные успешно добавлены в Firebase")
                                
                                // Проверяем наличие данных
                                self.checkDataExists()
                            } else {
                                print("❌ Не удалось добавить сеансы")
                            }
                        }
                    } else {
                        print("❌ Не удалось добавить фильмы")
                    }
                }
            } else {
                print("❌ Не удалось добавить кинотеатры")
            }
        }
    }
    
    // Добавление тестовых кинотеатров
    private func addTestCinemas(completion: @escaping (Bool) -> Void) {
        print("🔄 Добавляем тестовые кинотеатры...")
        
        // Простая проверка, чтобы не добавлять дубликаты
        db.collection("cinemas").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка при проверке кинотеатров: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Если уже есть кинотеатры, не добавляем новые
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                print("ℹ️ Кинотеатры уже существуют в базе данных")
                completion(true)
                return
            }
            
            // Создаем 2 простых кинотеатра
            let cinemas = [
                [
                    "name": "Октябрь",
                    "address": "ул. Новый Арбат, 24, Москва",
                    "description": "Один из старейших кинотеатров Москвы с богатой историей.",
                    "photoURLs": ["building"],
                    "location": [
                        "latitude": 55.752259,
                        "longitude": 37.586407
                    ],
                    "rating": 4.7,
                    "halls": [
                        [
                            "name": "Зал 1",
                            "capacity": 100,
                            "hallType": "standard",
                            "features": ["3d"]
                        ],
                        [
                            "name": "Зал 2",
                            "capacity": 150,
                            "hallType": "vip",
                            "features": ["comfort_seats"]
                        ]
                    ],
                    "amenities": ["Паркинг", "Кафе"],
                    "contactPhone": "+7 (495) 123-45-67",
                    "contactEmail": "info@cinema.ru",
                    "workingHours": [
                        "monday": ["open": "10:00", "close": "22:00"],
                        "tuesday": ["open": "10:00", "close": "22:00"],
                        "wednesday": ["open": "10:00", "close": "22:00"],
                        "thursday": ["open": "10:00", "close": "22:00"],
                        "friday": ["open": "10:00", "close": "23:00"],
                        "saturday": ["open": "10:00", "close": "23:00"],
                        "sunday": ["open": "10:00", "close": "22:00"]
                    ]
                ],
                [
                    "name": "Формула Кино",
                    "address": "ул. Ленина, 15, Москва",
                    "description": "Современный кинотеатр с комфортными залами.",
                    "photoURLs": ["film.circle"],
                    "location": [
                        "latitude": 55.751244,
                        "longitude": 37.618423
                    ],
                    "rating": 4.5,
                    "halls": [
                        [
                            "name": "Зал 1",
                            "capacity": 120,
                            "hallType": "standard",
                            "features": ["3d"]
                        ],
                        [
                            "name": "IMAX",
                            "capacity": 200,
                            "hallType": "imax",
                            "features": ["3d", "comfort_seats"]
                        ]
                    ],
                    "amenities": ["Паркинг", "Кафе", "VIP-зал"],
                    "contactPhone": "+7 (495) 987-65-43",
                    "contactEmail": "info@formulakino.ru",
                    "workingHours": [
                        "monday": ["open": "10:00", "close": "22:00"],
                        "tuesday": ["open": "10:00", "close": "22:00"],
                        "wednesday": ["open": "10:00", "close": "22:00"],
                        "thursday": ["open": "10:00", "close": "22:00"],
                        "friday": ["open": "10:00", "close": "23:00"],
                        "saturday": ["open": "10:00", "close": "23:00"],
                        "sunday": ["open": "10:00", "close": "22:00"]
                    ]
                ]
            ]
            
            // Счетчик завершенных операций
            var completedOperations = 0
            var successfulOperations = 0
            
            for cinema in cinemas {
                let cinemaRef = self.db.collection("cinemas").document()
                cinemaRef.setData(cinema) { error in
                    completedOperations += 1
                    
                    if let error = error {
                        print("❌ Ошибка при добавлении кинотеатра: \(error.localizedDescription)")
                    } else {
                        print("✅ Кинотеатр \(cinema["name"] ?? "без имени") успешно добавлен с ID: \(cinemaRef.documentID)")
                        successfulOperations += 1
                    }
                    
                    // Когда все операции завершены
                    if completedOperations == cinemas.count {
                        completion(successfulOperations > 0)
                    }
                }
            }
        }
    }
    
    // Добавление тестовых фильмов
    // Добавление тестовых фильмов
    private func addTestMovies(completion: @escaping (Bool) -> Void) {
        print("🔄 Добавляем тестовые фильмы...")
        
        // Простая проверка, чтобы не добавлять дубликаты
        db.collection("movies").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка при проверке фильмов: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Если уже есть фильмы, не добавляем новые
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                print("ℹ️ Фильмы уже существуют в базе данных")
                completion(true)
                return
            }
            
            // Текущая дата для расчета релизов
            let now = Date()
            let calendar = Calendar.current
            
            // Создаем 3 простых фильма
            let movies = [
                [
                    "title": "Мстители: Финал",
                    "originalTitle": "Avengers: Endgame",
                    "year": 2025,
                    "duration": 180,
                    "genres": ["Фантастика", "Боевик", "Приключения"],
                    "description": "После разрушительных событий команда Мстителей собирается вместе, чтобы исправить ущерб...",
                    "posterURL": "film.fill", // Системное изображение
                    "backdropURL": "photo",   // Системное изображение
                    "trailerURL": "https://example.com/trailer1",
                    "director": "Энтони Руссо, Джо Руссо",
                    "cast": ["Роберт Дауни мл.", "Крис Эванс", "Скарлетт Йоханссон"],
                    "rating": 9.2,
                    "ageRestriction": "12+",
                    "releaseDate": now,
                    "endScreeningDate": calendar.date(byAdding: .day, value: 30, to: now),
                    "language": "Русский",
                    "format": ["2d", "3d", "imax"]
                ],
                // Другие фильмы...
            ]
            
            // Продолжение кода...
        }
    }
    
    // Добавление тестовых сеансов
    private func addTestShowtimes(completion: @escaping (Bool) -> Void) {
        print("🔄 Добавляем тестовые сеансы...")
        
        // Простая проверка, чтобы не добавлять дубликаты
        db.collection("showtimes").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Ошибка при проверке сеансов: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Если уже есть сеансы, не добавляем новые
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                print("ℹ️ Сеансы уже существуют в базе данных")
                completion(true)
                return
            }
            
            // Сначала получим все кинотеатры и фильмы
            self.getAllCinemasAndMovies { cinemas, movies, success in
                if !success || cinemas.isEmpty || movies.isEmpty {
                    print("❌ Не удалось получить данные о кинотеатрах и фильмах")
                    completion(false)
                    return
                }
                
                print("ℹ️ Успешно получены данные: \(cinemas.count) кинотеатров и \(movies.count) фильмов")
                
                var showtimes: [[String: Any]] = []
                let calendar = Calendar.current
                let now = Date()
                
                // Для каждого кинотеатра и фильма создаем сеансы
                for cinema in cinemas {
                    guard let cinemaId = cinema["id"] as? String,
                          let halls = cinema["halls"] as? [[String: Any]] else {
                        continue
                    }
                    
                    for movie in movies {
                        guard let movieId = movie["id"] as? String else { continue }
                        
                        // Для каждого зала создаем несколько сеансов
                        for (index, hall) in halls.enumerated() {
                            guard let hallName = hall["name"] as? String else { continue }
                            
                            // Создаем сеансы на ближайшие 7 дней
                            for day in 0..<7 {
                                guard let date = calendar.date(byAdding: .day, value: day, to: now) else { continue }
                                
                                // Сеансы в разное время дня
                                let times = [10, 12, 15, 18, 20, 22]
                                for hour in times {
                                    var components = calendar.dateComponents([.year, .month, .day], from: date)
                                    components.hour = hour
                                    components.minute = 0
                                    
                                    guard let startTime = calendar.date(from: components) else { continue }
                                    
                                    // Здесь для простоты используем простое добавление длительности для расчета времени окончания
                                    let duration = movie["duration"] as? Int ?? 120
                                    guard let endTime = calendar.date(byAdding: .minute, value: duration, to: startTime) else { continue }
                                    
                                    // Создаем сеанс
                                    let showtime: [String: Any] = [
                                        "movieId": movieId,
                                        "cinemaId": cinemaId,
                                        "hallId": "hall_\(index + 1)",  // Простой уникальный ID для зала
                                        "hallName": hallName,
                                        "startTime": startTime,
                                        "endTime": endTime,
                                        "format": "2d",
                                        "language": "Русский",
                                        "priceCategories": [
                                            ["seatType": "standard", "price": 400],
                                            ["seatType": "vip", "price": 700]
                                        ],
                                        "availableSeats": 100,
                                        "totalSeats": 100,
                                        "isActive": true
                                    ]
                                    
                                    showtimes.append(showtime)
                                }
                            }
                        }
                    }
                }
                
                print("ℹ️ Подготовлено \(showtimes.count) сеансов для добавления")
                
                // Ограничим количество сеансов для тестирования
                if showtimes.count > 30 {
                    showtimes = Array(showtimes.prefix(30))
                    print("ℹ️ Ограничиваем количество сеансов до 30 для тестирования")
                }
                
                // Счетчик завершенных операций
                var completedOperations = 0
                var successfulOperations = 0
                
                // Добавляем сеансы в базу данных
                for showtime in showtimes {
                    let showtimeRef = self.db.collection("showtimes").document()
                    showtimeRef.setData(showtime) { error in
                        completedOperations += 1
                        
                        if let error = error {
                            print("❌ Ошибка при добавлении сеанса: \(error.localizedDescription)")
                        } else {
                            print("✅ Сеанс для фильма ID: \(showtime["movieId"] ?? "?") успешно добавлен")
                            successfulOperations += 1
                        }
                        
                        // Когда все операции завершены
                        if completedOperations == showtimes.count {
                            completion(successfulOperations > 0)
                        }
                    }
                }
                
                // Если нет сеансов для добавления
                if showtimes.isEmpty {
                    print("ℹ️ Нет сеансов для добавления")
                    completion(false)
                }
            }
        }
    }
    
    // Получение всех кинотеатров и фильмов
    private func getAllCinemasAndMovies(completion: @escaping ([[String: Any]], [[String: Any]], Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var cinemas: [[String: Any]] = []
        var movies: [[String: Any]] = []
        var success = true
        
        // Получаем кинотеатры
        dispatchGroup.enter()
        db.collection("cinemas").getDocuments { snapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("❌ Ошибка при получении кинотеатров: \(error.localizedDescription)")
                success = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ Документы кинотеатров не найдены")
                success = false
                return
            }
            
            for document in documents {
                var cinema = document.data()
                cinema["id"] = document.documentID
                cinemas.append(cinema)
            }
            
            print("✅ Успешно получено \(cinemas.count) кинотеатров")
        }
        
        // Получаем фильмы
        dispatchGroup.enter()
        db.collection("movies").getDocuments { snapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("❌ Ошибка при получении фильмов: \(error.localizedDescription)")
                success = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ Документы фильмов не найдены")
                success = false
                return
            }
            
            for document in documents {
                var movie = document.data()
                movie["id"] = document.documentID
                movies.append(movie)
            }
            
            print("✅ Успешно получено \(movies.count) фильмов")
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(cinemas, movies, success)
        }
    }
    
    // Проверка наличия данных в базе
    func checkDataExists() {
        print("🔍 Проверяем наличие данных в базе...")
        
        let dispatchGroup = DispatchGroup()
        
        // Проверка кинотеатров
        dispatchGroup.enter()
        db.collection("cinemas").getDocuments { snapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("❌ Ошибка при получении кинотеатров: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ Документы кинотеатров не найдены")
                return
            }
            
            print("✅ Найдено \(documents.count) кинотеатров")
            
            for (index, doc) in documents.enumerated() {
                if index < 3 { // Показываем только первые 3 для краткости
                    print("  📋 Кинотеатр #\(index + 1): ID = \(doc.documentID), name = \(doc.data()["name"] ?? "нет имени")")
                }
            }
        }
        
        // Проверка фильмов
        dispatchGroup.enter()
        db.collection("movies").getDocuments { snapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("❌ Ошибка при получении фильмов: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ Документы фильмов не найдены")
                return
            }
            
            print("✅ Найдено \(documents.count) фильмов")
            
            for (index, doc) in documents.enumerated() {
                if index < 3 { // Показываем только первые 3 для краткости
                    print("  📋 Фильм #\(index + 1): ID = \(doc.documentID), title = \(doc.data()["title"] ?? "нет названия")")
                }
            }
        }
        
        // Проверка сеансов
        dispatchGroup.enter()
        db.collection("showtimes").getDocuments { snapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("❌ Ошибка при получении сеансов: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ Документы сеансов не найдены")
                return
            }
            
            print("✅ Найдено \(documents.count) сеансов")
            
            for (index, doc) in documents.enumerated() {
                if index < 3 { // Показываем только первые 3 для краткости
                    print("  📋 Сеанс #\(index + 1): ID = \(doc.documentID), movieId = \(doc.data()["movieId"] ?? "нет ID фильма")")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("🏁 Проверка завершена")
        }
    }
}

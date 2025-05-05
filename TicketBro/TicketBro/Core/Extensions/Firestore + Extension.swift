//
//  Firestore + Extension.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Combine
import Foundation
import FirebaseFirestore

extension FirestoreService where T == Ticket {
    func addTicket(ticket: Ticket) -> AnyPublisher<Ticket, Error> {
        return add(item: ticket)
            .flatMap { [weak self] addedTicket -> AnyPublisher<Ticket, Error> in
                let sessionId = addedTicket.sessionId
                let userId = addedTicket.userId
                guard let self = self else {
                    return Just(addedTicket)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                // Обновление пользователя - добавление билета в список
                return self.updateUserTickets(userId: userId, ticketId: addedTicket.id ?? "")
                    .map { _ in addedTicket }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        
    }
    
    func addTickets(tickets: [Ticket]) -> AnyPublisher<Void, Error> {
        // Создаем массив издателей - по одному на каждый билет
        let publishers = tickets.map { ticket in
            add(item: ticket).map { _ in () }
        }
        
        // Объединяем все издатели в один
        return Publishers.MergeMany(publishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // Обновление пользователя - добавление билета в список
    private func updateUserTickets(userId: String, ticketId: String) -> AnyPublisher<Void, Error> {
        return Future<[String: Any], Error> { promise in
            Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists, var userData = snapshot.data() else {
                    promise(.failure(NSError(domain: "FirestoreService", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"])))
                    return
                }
                
                // Получаем текущий список билетов или создаем новый
                var ticketIds = userData["ticketIds"] as? [String] ?? []
                
                // Проверяем, что билет еще не добавлен
                if !ticketIds.contains(ticketId) {
                    ticketIds.append(ticketId)
                    userData["ticketIds"] = ticketIds
                }
                
                promise(.success(userData))
            }
        }
        .flatMap { userData -> AnyPublisher<Void, Error> in
            return Future<Void, Error> { promise in
                Firestore.firestore().collection("users").document(userId).setData(userData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }.eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

// Расширение для работы с сеансами
extension FirestoreService where T == Session {
    // Получение тестовых сеансов для разработки
    func getTestSessions(movieId: String, cinemaId: String, date: Date) -> [Session] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Генерируем несколько сеансов на разное время
        let sessionTimes = [10, 12, 14, 16, 18, 20, 22]
        var sessions: [Session] = []
        
        for (index, hour) in sessionTimes.enumerated() {
            guard let sessionDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay) else {
                continue
            }
            
            // Создаем уникальный ID для каждого сеанса
            let sessionId = "\(movieId)-\(cinemaId)-\(index)"
            
            // Выбираем случайный зал
            let hallId = index % 2 == 0 ? "1" : "2"
            
            // Определяем базовую цену и формат
            let basePrice = 300.0 + Double(index * 50)
            let format: Session.MovieFormat = index % 3 == 0 ? ._3D : ._2D
            
            // Создаем сеанс
            let session = Session(
                id: sessionId,
                movieId: movieId,
                cinemaId: cinemaId,
                hallId: hallId,
                date: sessionDate,
                price: basePrice,
                format: format,
                isActive: true,
                soldSeats: []
            )
            
            sessions.append(session)
        }
        
        return sessions
    }
}

// Расширение для работы с кинотеатрами
extension FirestoreService where T == Cinema {
    // Получение тестовых кинотеатров для разработки
    func getTestCinemas() -> [Cinema] {
        return [
            Cinema(
                id: "cinema1",
                name: "Октябрь",
                address: "ул. Новый Арбат, 24, Москва",
                description: "Один из старейших кинотеатров Москвы с богатой историей.",
                photoURLs: ["building"],
                location: Cinema.GeoPoint(latitude: 55.752259, longitude: 37.586407),
                rating: 4.7,
                halls: [
                    Hall(id: "1", name: "Зал 1", capacity: 100, hallType: .standard, features: [._3D]),
                    Hall(id: "2", name: "Зал 2", capacity: 150, hallType: .vip, features: [.comfortSeats])
                ],
                amenities: ["Паркинг", "Кафе"],
                contactPhone: "+7 (495) 123-45-67",
                contactEmail: "info@cinema.ru"
            ),
            Cinema(
                id: "cinema2",
                name: "Формула Кино",
                address: "ул. Ленина, 15, Москва",
                description: "Современный кинотеатр с комфортными залами.",
                photoURLs: ["film.circle"],
                location: Cinema.GeoPoint(latitude: 55.751244, longitude: 37.618423),
                rating: 4.5,
                halls: [
                    Hall(id: "1", name: "Зал 1", capacity: 120, hallType: .standard, features: [._3D]),
                    Hall(id: "2", name: "IMAX", capacity: 200, hallType: .imax, features: [._3D, .comfortSeats])
                ],
                amenities: ["Паркинг", "Кафе", "VIP-зал"],
                contactPhone: "+7 (495) 987-65-43",
                contactEmail: "info@formulakino.ru"
            )
        ]
    }
}

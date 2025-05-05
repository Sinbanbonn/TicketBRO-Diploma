//
//  AppEvent.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Core/Services/EventBus.swift
import Foundation
import Combine

// Тип события
enum AppEvent {
    case userUpdated(User)
    case ticketPurchased(Ticket)
    case favoriteMovieAdded(String)
    case favoriteMovieRemoved(String)
    case favoriteCinemaAdded(String)
    case favoriteCinemaRemoved(String)
    case switchToTicketsTab
    // Другие события
}

// Сервис для коммуникации между компонентами приложения
class EventBus {
    static let shared = EventBus()
    
    // Издатель событий
    private let eventSubject = PassthroughSubject<AppEvent, Never>()
    
    // Публикация события
    func publish(_ event: AppEvent) {
        eventSubject.send(event)
    }
    
    // Подписка на события
    func subscribe() -> AnyPublisher<AppEvent, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    // Подписка на конкретный тип события
    func subscribe<T>(for eventType: @escaping (AppEvent) -> T?) -> AnyPublisher<T, Never> {
        return eventSubject
            .compactMap(eventType)
            .eraseToAnyPublisher()
    }
}

// Расширения для упрощения подписки на конкретные события
extension EventBus {
    // Подписка на обновление пользователя
    func subscribeToUserUpdates() -> AnyPublisher<User, Never> {
        return subscribe { event -> User? in
            if case .userUpdated(let user) = event {
                return user
            }
            return nil
        }
    }
    
    // Подписка на покупку билета
    func subscribeToTicketPurchases() -> AnyPublisher<Ticket, Never> {
        return subscribe { event -> Ticket? in
            if case .ticketPurchased(let ticket) = event {
                return ticket
            }
            return nil
        }
    }
    
    // Подписка на добавление фильма в избранное
    func subscribeToFavoriteMovieAdditions() -> AnyPublisher<String, Never> {
        return subscribe { event -> String? in
            if case .favoriteMovieAdded(let movieId) = event {
                return movieId
            }
            return nil
        }
    }
    
    // Подписка на удаление фильма из избранного
    func subscribeToFavoriteMovieRemovals() -> AnyPublisher<String, Never> {
        return subscribe { event -> String? in
            if case .favoriteMovieRemoved(let movieId) = event {
                return movieId
            }
            return nil
        }
    }
}

//
//  UserService.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Core/Services/Firebase/UserService.swift
import Foundation
import Firebase
import Combine

class UserService {
    private let firestoreService: FirestoreService<User>
    private let storageService: StorageService
    
    init() {
        self.firestoreService = FirestoreService<User>(collectionPath: "users")
        self.storageService = StorageService()
    }
    
    // Получение пользователя по ID
    func getUser(userId: String) -> AnyPublisher<User?, Error> {
        return firestoreService.getById(id: userId)
    }
    
    // Обновление профиля пользователя
    func updateProfile(user: User) -> AnyPublisher<User, Error> {
        guard let userId = user.id else {
            return Fail(error: NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID пользователя отсутствует"])).eraseToAnyPublisher()
        }
        
        return firestoreService.update(id: userId, item: user)
    }
    
    // Загрузка аватара пользователя
    func uploadAvatar(userId: String, image: UIImage) -> AnyPublisher<User, Error> {
        return storageService.uploadImage(image: image, path: "avatars")
            .flatMap { [weak self] url -> AnyPublisher<User, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])).eraseToAnyPublisher()
                }
                
                return self.firestoreService.getById(id: userId)
                    .compactMap { $0 }
                    .flatMap { user -> AnyPublisher<User, Error> in
                        var updatedUser = user
                        updatedUser.avatar = url.absoluteString
                        
                        return self.firestoreService.update(id: userId, item: updatedUser)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // Добавление фильма в избранное
    func addToFavoriteMovies(userId: String, movieId: String) -> AnyPublisher<User, Error> {
        return firestoreService.getById(id: userId)
            .compactMap { $0 }
            .flatMap { [weak self] user -> AnyPublisher<User, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])).eraseToAnyPublisher()
                }
                
                var updatedUser = user
                
                // Проверяем, что фильм еще не в избранном
                if !updatedUser.favoriteMovies.contains(movieId) {
                    updatedUser.favoriteMovies.append(movieId)
                }
                
                return self.firestoreService.update(id: userId, item: updatedUser)
            }
            .eraseToAnyPublisher()
    }
    
    // Удаление фильма из избранного
    func removeFromFavoriteMovies(userId: String, movieId: String) -> AnyPublisher<User, Error> {
        return firestoreService.getById(id: userId)
            .compactMap { $0 }
            .flatMap { [weak self] user -> AnyPublisher<User, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])).eraseToAnyPublisher()
                }
                
                var updatedUser = user
                updatedUser.favoriteMovies.removeAll { $0 == movieId }
                
                return self.firestoreService.update(id: userId, item: updatedUser)
            }
            .eraseToAnyPublisher()
    }
    
    // Аналогично для кинотеатров
    func addToFavoriteCinemas(userId: String, cinemaId: String) -> AnyPublisher<User, Error> {
        // Аналогичная реализация
        return firestoreService.getById(id: userId)
            .compactMap { $0 }
            .flatMap { [weak self] user -> AnyPublisher<User, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])).eraseToAnyPublisher()
                }
                
                var updatedUser = user
                
                if !updatedUser.favoriteCinemas.contains(cinemaId) {
                    updatedUser.favoriteCinemas.append(cinemaId)
                }
                
                return self.firestoreService.update(id: userId, item: updatedUser)
            }
            .eraseToAnyPublisher()
    }
    
    func removeFromFavoriteCinemas(userId: String, cinemaId: String) -> AnyPublisher<User, Error> {
        // Аналогичная реализация
        return firestoreService.getById(id: userId)
            .compactMap { $0 }
            .flatMap { [weak self] user -> AnyPublisher<User, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])).eraseToAnyPublisher()
                }
                
                var updatedUser = user
                updatedUser.favoriteCinemas.removeAll { $0 == cinemaId }
                
                return self.firestoreService.update(id: userId, item: updatedUser)
            }
            .eraseToAnyPublisher()
    }
}
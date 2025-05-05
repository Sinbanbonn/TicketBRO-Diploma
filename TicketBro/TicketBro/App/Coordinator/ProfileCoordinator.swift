//
//  ProfileCoordinator.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import Foundation
import SwiftUI
import Combine
import UIKit

class ProfileCoordinator: ObservableObject {
    // Контейнер зависимостей
    let container: DIContainer
    
    // Текущий пользователь
    @Published var user: User?
    
    // Состояние редактирования профиля
    @Published var editedName: String = ""
    @Published var selectedImage: UIImage?
    
    // Состояние навигации
    @Published var showingEditProfile: Bool = false
    @Published var showingFavoriteMovies: Bool = false
    @Published var showingFavoriteCinemas: Bool = false
    @Published var showingSettings: Bool = false
    @Published var showingSupport: Bool = false
    
    // Загруженные данные
    @Published var favoriteMovies: [Movie] = []
    @Published var favoriteCinemas: [Cinema] = []
    @Published var isLoading: Bool = false
    
    // Замыкание для выхода из аккаунта
    private let logoutAction: () -> Void
    
    // Подписки на события
    var cancellables = Set<AnyCancellable>()
    
    // Инициализатор
    init(container: DIContainer, user: User?, logoutAction: @escaping () -> Void) {
        self.container = container
        self.user = user
        self.logoutAction = logoutAction
        
        // Устанавливаем начальное значение имени пользователя для редактирования
        if let userName = user?.name {
            self.editedName = userName
        }
        
        // Если пользователь авторизован, загружаем его данные
        if user != nil {
            loadFavoriteMovies()
            loadFavoriteCinemas()
        }
        
        // Подписываемся на обновления пользователя
        setupSubscriptions()
    }
    
    // Настройка подписок на события
    private func setupSubscriptions() {
        // Подписка на обновление пользователя через EventBus
        EventBus.shared.subscribeToUserUpdates()
            .sink { [weak self] updatedUser in
                guard let self = self else { return }
                self.user = updatedUser
                self.editedName = updatedUser.name
                
                // Обновляем избранное при обновлении пользователя
                self.loadFavoriteMovies()
                self.loadFavoriteCinemas()
            }
            .store(in: &cancellables)
    }
    
    // Выход из аккаунта
    func logout() {
        logoutAction()
    }
    
    // Обновление профиля пользователя
    func updateProfile() -> AnyPublisher<User, Error> {
        guard let user = user, let userId = user.id else {
            return Fail(error: NSError(domain: "ProfileCoordinator", code: -1, 
                            userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"]))
                .eraseToAnyPublisher()
        }
        
        var updatedUser = user
        updatedUser.name = editedName
        
        // Если выбрано новое изображение, загружаем его сначала
        if let image = selectedImage {
            return container.storageService.uploadImage(image: image, path: "avatars")
                .flatMap { [weak self] url -> AnyPublisher<User, Error> in
                    guard let self = self else {
                        return Fail(error: NSError(domain: "ProfileCoordinator", code: -1, 
                                        userInfo: [NSLocalizedDescriptionKey: "Координатор недоступен"]))
                            .eraseToAnyPublisher()
                    }
                    
                    updatedUser.avatar = url.absoluteString
                    
                    return self.container.userService.updateProfile(user: updatedUser)
                        .handleEvents(receiveOutput: { [weak self] updatedUser in
                            // Публикуем событие обновления пользователя
                            EventBus.shared.publish(.userUpdated(updatedUser))
                            // Сбрасываем выбранное изображение
                            self?.selectedImage = nil
                        })
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        } else {
            // Если новое изображение не выбрано, просто обновляем профиль
            return container.userService.updateProfile(user: updatedUser)
                .handleEvents(receiveOutput: { updatedUser in
                    // Публикуем событие обновления пользователя
                    EventBus.shared.publish(.userUpdated(updatedUser))
                })
                .eraseToAnyPublisher()
        }
    }
    
    // Загрузка избранных фильмов
    func loadFavoriteMovies() {
        guard let user = user, !user.favoriteMovies.isEmpty else {
            self.favoriteMovies = []
            return
        }
        
        isLoading = true
        
        // Для каждого ID фильма выполняем запрос
        let publishers = user.favoriteMovies.map { movieId in
            container.movieService.getById(id: movieId)
                .compactMap { $0 } // Убираем nil значения
        }
        
        // Объединяем результаты
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    print("Ошибка загрузки избранных фильмов: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.favoriteMovies = movies
            }
            .store(in: &cancellables)
    }
    
    // Загрузка избранных кинотеатров
    func loadFavoriteCinemas() {
        guard let user = user, !user.favoriteCinemas.isEmpty else {
            self.favoriteCinemas = []
            return
        }
        
        isLoading = true
        
        // Для каждого ID кинотеатра выполняем запрос
        let publishers = user.favoriteCinemas.map { cinemaId in
            container.cinemaService.getById(id: cinemaId)
                .compactMap { $0 } // Убираем nil значения
        }
        
        // Объединяем результаты
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    print("Ошибка загрузки избранных кинотеатров: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] cinemas in
                guard let self = self else { return }
                self.favoriteCinemas = cinemas
            }
            .store(in: &cancellables)
    }
    
    // Добавление фильма в избранное
    func addToFavoriteMovies(movieId: String) -> AnyPublisher<Void, Error> {
        guard let userId = user?.id else {
            return Fail(error: NSError(domain: "ProfileCoordinator", code: -1, 
                            userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]))
                .eraseToAnyPublisher()
        }
        
        return container.userService.addToFavoriteMovies(userId: userId, movieId: movieId)
            .map { _ in () }
            .handleEvents(receiveOutput: { [weak self] _ in
                // После успешного добавления обновляем список избранных фильмов
                self?.loadFavoriteMovies()
            })
            .eraseToAnyPublisher()
    }
    
    // Удаление фильма из избранного
    func removeFromFavoriteMovies(movieId: String) -> AnyPublisher<Void, Error> {
        guard let userId = user?.id else {
            return Fail(error: NSError(domain: "ProfileCoordinator", code: -1, 
                            userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]))
                .eraseToAnyPublisher()
        }
        
        return container.userService.removeFromFavoriteMovies(userId: userId, movieId: movieId)
            .map { _ in () }
            .handleEvents(receiveOutput: { [weak self] _ in
                // После успешного удаления обновляем список избранных фильмов
                self?.loadFavoriteMovies()
            })
            .eraseToAnyPublisher()
    }
    
    // Добавление кинотеатра в избранное
    func addToFavoriteCinemas(cinemaId: String) -> AnyPublisher<Void, Error> {
        guard let userId = user?.id else {
            return Fail(error: NSError(domain: "ProfileCoordinator", code: -1, 
                            userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]))
                .eraseToAnyPublisher()
        }
        
        return container.userService.addToFavoriteCinemas(userId: userId, cinemaId: cinemaId)
            .map { _ in () }
            .handleEvents(receiveOutput: { [weak self] _ in
                // После успешного добавления обновляем список избранных кинотеатров
                self?.loadFavoriteCinemas()
            })
            .eraseToAnyPublisher()
    }
    
    // Удаление кинотеатра из избранного
    func removeFromFavoriteCinemas(cinemaId: String) -> AnyPublisher<Void, Error> {
        guard let userId = user?.id else {
            return Fail(error: NSError(domain: "ProfileCoordinator", code: -1, 
                            userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]))
                .eraseToAnyPublisher()
        }
        
        return container.userService.removeFromFavoriteCinemas(userId: userId, cinemaId: cinemaId)
            .map { _ in () }
            .handleEvents(receiveOutput: { [weak self] _ in
                // После успешного удаления обновляем список избранных кинотеатров
                self?.loadFavoriteCinemas()
            })
            .eraseToAnyPublisher()
    }
}
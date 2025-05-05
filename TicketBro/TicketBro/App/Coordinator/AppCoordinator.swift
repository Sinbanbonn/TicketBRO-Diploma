//
//  AppCoordinator.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import SwiftUI
import Combine

// Перечисление для представления состояния авторизации
enum AuthState {
    case loading
    case authenticated
    case unauthenticated
}

// Класс координатора приложения
class AppCoordinator: ObservableObject {
    // Контейнер зависимостей
    let container = DIContainer()
    
    // Состояние авторизации
    @Published var authState: AuthState = .loading
    
    // Текущий аутентифицированный пользователь
    @Published var currentUser: User?
    
    // Подписки на события
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Проверяем текущее состояние аутентификации
        checkAuthState()
        
//         initializeAppData()
    }
    
    // Проверка состояния аутентификации
    private func checkAuthState() {
        if container.authService.isUserAuthenticated {
            if let userId = container.authService.currentUser?.id {
                container.userService.getUser(userId: userId)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure:
                            // Если не удалось получить данные пользователя, выходим из системы
                            self.logout()
                        }
                    } receiveValue: { [weak self] user in
                        if let user = user {
                            self?.currentUser = user
                            self?.authState = .authenticated
                        } else {
                            self?.logout()
                        }
                    }
                    .store(in: &cancellables)
                
            } else {
                self.authState = .unauthenticated
            }
        } else {
            self.authState = .unauthenticated
        }
    }
    
    // Вход пользователя в систему
    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        return container.authService.login(email: email, password: password)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.authState = .authenticated
            })
            .eraseToAnyPublisher()
    }
    
    // Регистрация нового пользователя
    func register(email: String, password: String, name: String) -> AnyPublisher<User, Error> {
        return container.authService.register(email: email, password: password, name: name)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.authState = .authenticated
            })
            .eraseToAnyPublisher()
    }
    
    // Выход пользователя из системы
    func logout() {
        container.authService.logout()
            .sink { _ in } receiveValue: { [weak self] _ in
                self?.currentUser = nil
                self?.authState = .unauthenticated
            }
            .store(in: &cancellables)
    }
    
    // Восстановление пароля
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        return container.authService.resetPassword(email: email)
    }

    func initializeAppData() {
        let initializer = FirebaseDataInitializer()
        
        // Заменяем сложную логику на упрощенную
        initializer.initializeAppDataSimplified()
        print("✅ Запущен процесс добавления тестовых данных в Firebase")

    }


}

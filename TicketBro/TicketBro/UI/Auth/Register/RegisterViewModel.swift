//
//  RegisterViewModel.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import Foundation
import Combine
import SwiftUI

class RegisterViewModel: ObservableObject {
    // Публикуемые свойства
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var isLoading = false
    
    // Вычисляемое свойство для валидации формы
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 6
    }
    
    // Зависимости
    private let register: (String, String, String) -> AnyPublisher<User, Error>
    
    // Подписки на события
    private var cancellables = Set<AnyCancellable>()
    
    init(register: @escaping (String, String, String) -> AnyPublisher<User, Error>) {
        self.register = register
    }
    
    func performRegistration() {
        isLoading = true
        
        register(email, password, name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                }
            } receiveValue: { _ in 
                // Успешная регистрация обрабатывается в координаторе
            }
            .store(in: &cancellables)
    }
}
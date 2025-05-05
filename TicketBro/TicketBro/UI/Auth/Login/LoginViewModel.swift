//
//  LoginViewModel.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    // Публикуемые свойства
    @Published var email = ""
    @Published var password = ""
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var isLoading = false
    @Published var showingResetPasswordAlert = false
    
    // Зависимости
    private let login: (String, String) -> AnyPublisher<User, Error>
    private let resetPassword: (String) -> AnyPublisher<Void, Error>
    
    // Подписки на события
    private var cancellables = Set<AnyCancellable>()
    
    init(login: @escaping (String, String) -> AnyPublisher<User, Error>, 
         resetPassword: @escaping (String) -> AnyPublisher<Void, Error>) {
        self.login = login
        self.resetPassword = resetPassword
    }
    
    func performLogin() {
        isLoading = true
        
        login(email, password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                }
            } receiveValue: { _ in 
                // Успешный вход обрабатывается в координаторе
            }
            .store(in: &cancellables)
    }
    
    func resetPasswordAction() {
        isLoading = true
        
        resetPassword(email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                } else {
                    self.alertMessage = "Инструкция по сбросу пароля отправлена на указанный email."
                    self.showingAlert = true
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

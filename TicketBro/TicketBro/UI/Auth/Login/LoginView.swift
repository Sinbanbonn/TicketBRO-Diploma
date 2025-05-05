//
//  LoginView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import Combine
import SwiftUI

// Обновленное представление LoginView
struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    // Замыкание для перехода к регистрации
    let navigateToRegister: () -> Void
    
    init(login: @escaping (String, String) -> AnyPublisher<User, Error>,
         navigateToRegister: @escaping () -> Void,
         resetPassword: @escaping (String) -> AnyPublisher<Void, Error>) {
        self.viewModel = LoginViewModel(login: login, resetPassword: resetPassword)
        self.navigateToRegister = navigateToRegister
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Логотип приложения
            Image(systemName: "film.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)
            
            Text("Вход в TicketBro")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            // Поле для ввода email
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.headline)
                TextField("Введите email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Поле для ввода пароля
            VStack(alignment: .leading) {
                Text("Пароль")
                    .font(.headline)
                SecureField("Введите пароль", text: $viewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Кнопка "Забыли пароль?"
            Button("Забыли пароль?") {
                viewModel.showingResetPasswordAlert = true
            }
            .foregroundColor(.purple)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Кнопка входа
            Button(action: viewModel.performLogin) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Войти")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            // Разделитель
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                Text("или")
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
            }
            .padding(.vertical)
            
            // Кнопка перехода к регистрации
            Button(action: navigateToRegister) {
                Text("Зарегистрироваться")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.purple)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.purple, lineWidth: 1)
            )
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Сброс пароля", isPresented: $viewModel.showingResetPasswordAlert) {
            TextField("Введите email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("Отмена", role: .cancel) {}
            Button("Сбросить") { viewModel.resetPasswordAction() }
        } message: {
            Text("Введите адрес электронной почты, на который будет отправлена инструкция по сбросу пароля.")
        }
    }
}

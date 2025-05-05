import SwiftUI
import Combine

struct RegisterView: View {
    // ViewModel для управления состоянием и бизнес-логикой
    @ObservedObject var viewModel: RegisterViewModel
    
    // Замыкание для перехода к логину
    let navigateToLogin: () -> Void
    
    init(register: @escaping (String, String, String) -> AnyPublisher<User, Error>,
         navigateToLogin: @escaping () -> Void) {
        self.viewModel = RegisterViewModel(register: register)
        self.navigateToLogin = navigateToLogin
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Логотип приложения
                Image(systemName: "film.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                Text("Регистрация в TicketBro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                // Поле для ввода имени
                VStack(alignment: .leading) {
                    Text("Имя")
                        .font(.headline)
                    TextField("Введите имя", text: $viewModel.name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
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
                
                // Поле для подтверждения пароля
                VStack(alignment: .leading) {
                    Text("Подтверждение пароля")
                        .font(.headline)
                    SecureField("Повторите пароль", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Индикатор валидности пароля
                if !viewModel.password.isEmpty {
                    HStack {
                        Text(viewModel.password.count >= 6 ? "Пароль подходит" : "Пароль должен содержать минимум 6 символов")
                            .font(.caption)
                            .foregroundColor(viewModel.password.count >= 6 ? .green : .red)
                        Spacer()
                    }
                }
                
                // Индикатор совпадения паролей
                if !viewModel.confirmPassword.isEmpty {
                    HStack {
                        Text(viewModel.password == viewModel.confirmPassword ? "Пароли совпадают" : "Пароли не совпадают")
                            .font(.caption)
                            .foregroundColor(viewModel.password == viewModel.confirmPassword ? .green : .red)
                        Spacer()
                    }
                }
                
                // Кнопка регистрации
                Button(action: { viewModel.performRegistration() }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Зарегистрироваться")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormValid ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isLoading || !viewModel.isFormValid)
                
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
                
                // Кнопка перехода к логину
                Button(action: navigateToLogin) {
                    Text("Уже есть аккаунт? Войдите")
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
            }
            .padding()
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

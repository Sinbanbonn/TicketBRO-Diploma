//
//  ProfileCoordinatorView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import SwiftUI

struct ProfileCoordinatorView: View {
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        NavigationView {
            Group {
                if coordinator.user == nil {
                    // Если пользователь не авторизован
                    NotAuthorizedProfileView(logout: coordinator.logout)
                } else {
                    // Показываем профиль пользователя
                    ProfileView(coordinator: coordinator)
                }
            }
            .navigationTitle("Профиль")
            .background(
                Group {
                    // Редактирование профиля
                    NavigationLink(
                        destination: EditProfileView(coordinator: coordinator),
                        isActive: $coordinator.showingEditProfile
                    ) {
                        EmptyView()
                    }
                    
                    // Избранные фильмы
                    NavigationLink(
                        destination: FavoriteMoviesView(coordinator: coordinator),
                        isActive: $coordinator.showingFavoriteMovies
                    ) {
                        EmptyView()
                    }
                    
                    // Избранные кинотеатры
                    NavigationLink(
                        destination: FavoriteCinemasView(coordinator: coordinator),
                        isActive: $coordinator.showingFavoriteCinemas
                    ) {
                        EmptyView()
                    }
                    
                    // Настройки
                    NavigationLink(
                        destination: SettingsView(coordinator: coordinator),
                        isActive: $coordinator.showingSettings
                    ) {
                        EmptyView()
                    }
                    
                    // Поддержка
                    NavigationLink(
                        destination: SupportView(),
                        isActive: $coordinator.showingSupport
                    ) {
                        EmptyView()
                    }
                }
            )
        }
    }
}

// Представление профиля при отсутствии авторизации
struct NotAuthorizedProfileView: View {
    let logout: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Вы не авторизованы")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Войдите в аккаунт, чтобы получить доступ к профилю")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Выйти") {
                logout()
            }
            .padding()
            .frame(minWidth: 200)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.top)
        }
        .padding()
    }
}

// Основное представление профиля
struct ProfileView: View {
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        List {
            // Секция профиля
            Section {
                HStack(spacing: 16) {
                    // Аватар пользователя
                    if let avatarUrl = coordinator.user?.avatar, !avatarUrl.isEmpty {
                        AsyncImage(url: URL(string: avatarUrl)) { phase in
                            switch phase {
                            case .empty:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.purple)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.purple)
                            @unknown default:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.purple)
                            }
                        }
                        .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.purple)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(coordinator.user?.name ?? "Пользователь")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(coordinator.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        coordinator.showingEditProfile = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.purple)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Секция избранного
            Section(header: Text("Избранное")) {
                Button(action: {
                    coordinator.showingFavoriteMovies = true
                }) {
                    HStack {
                        Image(systemName: "film")
                            .foregroundColor(.purple)
                        Text("Избранные фильмы")
                        Spacer()
                        Text("\(coordinator.user?.favoriteMovies.count ?? 0)")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    coordinator.showingFavoriteCinemas = true
                }) {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.purple)
                        Text("Избранные кинотеатры")
                        Spacer()
                        Text("\(coordinator.user?.favoriteCinemas.count ?? 0)")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
            
            // Секция настроек
            Section(header: Text("Настройки")) {
                Button(action: {
                    coordinator.showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.purple)
                        Text("Настройки приложения")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    coordinator.showingSupport = true
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.purple)
                        Text("Поддержка")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
            
            // Секция выхода
            Section {
                Button(action: {
                    coordinator.logout()
                }) {
                    HStack {
                        Spacer()
                        Text("Выйти")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// Представление редактирования профиля
struct EditProfileView: View {
    @ObservedObject var coordinator: ProfileCoordinator
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isShowingImagePicker = false
    @State private var isUpdating = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Фото профиля")) {
                HStack {
                    Spacer()
                    
                    // Отображение выбранного изображения или текущего аватара
                    if let selectedImage = coordinator.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else if let avatarUrl = coordinator.user?.avatar, !avatarUrl.isEmpty {
                        AsyncImage(url: URL(string: avatarUrl)) { phase in
                            switch phase {
                            case .empty:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.purple)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.purple)
                            @unknown default:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.purple)
                            }
                        }
                        .frame(width: 120, height: 120)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                
                Button("Сменить фото") {
                    isShowingImagePicker = true
                }
                .frame(maxWidth: .infinity)
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(selectedImage: Binding(
                        get: { coordinator.selectedImage },
                        set: { coordinator.selectedImage = $0 }
                    ))
                }
            }
            
            Section(header: Text("Личная информация")) {
                TextField("Имя", text: $coordinator.editedName)
                
                // Email нельзя изменить
                HStack {
                    Text("Email")
                    Spacer()
                    Text(coordinator.user?.email ?? "")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button(action: updateProfile) {
                    if isUpdating {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Сохранить")
                            Spacer()
                        }
                    }
                }
                .disabled(isUpdating)
            }
        }
        .navigationTitle("Редактирование профиля")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Обновление профиля
    private func updateProfile() {
        isUpdating = true
        
        coordinator.updateProfile()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isUpdating = false
                
                if case .failure(let error) = completion {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            } receiveValue: { _ in }
            .store(in: &coordinator.cancellables)
    }
}

// Представление избранных фильмов
struct FavoriteMoviesView: View {
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        Group {
            if coordinator.isLoading {
                ProgressView("Загрузка избранных фильмов...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if coordinator.favoriteMovies.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "film")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                    
                    Text("У вас нет избранных фильмов")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Добавляйте фильмы в избранное, чтобы они появились здесь")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                List {
                    ForEach(coordinator.favoriteMovies) { movie in
                        HStack(spacing: 16) {
                            // Постер фильма
                            AsyncImage(url: URL(string: movie.posterURL)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .foregroundColor(.gray)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Rectangle()
                                        .foregroundColor(.gray)
                                        .overlay(
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundColor(.white)
                                        )
                                @unknown default:
                                    Rectangle()
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 60, height: 90)
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Название фильма
                                Text(movie.title)
                                    .font(.headline)
                                
                                // Жанры
                                Text(movie.genres.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Рейтинг
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    
                                    Text(String(format: "%.1f", movie.rating))
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            // Кнопка удаления из избранного
                            Button(action: {
                                // Логика удаления из избранного
                            }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Избранные фильмы")
    }
}

// Представление избранных кинотеатров
struct FavoriteCinemasView: View {
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        Group {
            if coordinator.isLoading {
                ProgressView("Загрузка избранных кинотеатров...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if coordinator.favoriteCinemas.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "building.2")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                    
                    Text("У вас нет избранных кинотеатров")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Добавляйте кинотеатры в избранное, чтобы они появились здесь")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                List {
                    ForEach(coordinator.favoriteCinemas) { cinema in
                        HStack(spacing: 16) {
                            // Изображение кинотеатра
                            if let photoUrl = cinema.photoURLs.first {
                                AsyncImage(url: URL(string: photoUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle()
                                            .foregroundColor(.gray)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Rectangle()
                                            .foregroundColor(.gray)
                                            .overlay(
                                                Image(systemName: "exclamationmark.triangle")
                                                    .foregroundColor(.white)
                                            )
                                    @unknown default:
                                        Rectangle()
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Название кинотеатра
                                Text(cinema.name)
                                    .font(.headline)
                                
                                // Адрес
                                Text(cinema.address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Рейтинг
                                HStack {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(cinema.rating) ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                    Text(String(format: "%.1f", cinema.rating))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Кнопка удаления из избранного
                            Button(action: {
                                // Логика удаления из избранного
                            }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Избранные кинотеатры")
    }
}

// Представление выбора изображения
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Представление настроек
struct SettingsView: View {
    @ObservedObject var coordinator: ProfileCoordinator
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var language = "Русский"
    
    var body: some View {
        Form {
            Section(header: Text("Общие")) {
                Toggle("Уведомления", isOn: $notificationsEnabled)
                
                Toggle("Темная тема", isOn: $darkModeEnabled)
                
                Picker("Язык", selection: $language) {
                    Text("Русский").tag("Русский")
                    Text("English").tag("English")
                }
            }
            
            Section(header: Text("О приложении")) {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                Button("Условия использования") {
                    // Показать условия использования
                }
                
                Button("Политика конфиденциальности") {
                    // Показать политику конфиденциальности
                }
            }
        }
        .navigationTitle("Настройки")
    }
}

// Представление поддержки
struct SupportView: View {
    @State private var supportEmail = ""
    @State private var supportMessage = ""
    @State private var isSending = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Свяжитесь с нами")) {
                TextField("Ваш email", text: $supportEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                ZStack(alignment: .topLeading) {
                    if supportMessage.isEmpty {
                        Text("Опишите вашу проблему или вопрос...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    
                    TextEditor(text: $supportMessage)
                        .frame(minHeight: 150)
                        .opacity(supportMessage.isEmpty ? 0.25 : 1)
                }
            }
            
            Section {
                Button(action: sendSupportRequest) {
                    if isSending {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Отправить")
                            Spacer()
                        }
                    }
                }
                .disabled(isSending || supportEmail.isEmpty || supportMessage.isEmpty)
            }
            
            Section(header: Text("Часто задаваемые вопросы")) {
                DisclosureGroup("Как купить билет?") {
                    Text("Выберите фильм, затем кинотеатр, сеанс и места. После этого оплатите билет удобным способом.")
                        .padding(.vertical, 8)
                }
                
                DisclosureGroup("Как отменить билет?") {
                    Text("Вы можете отменить билет не позднее, чем за 3 часа до начала сеанса. Для этого перейдите в раздел 'Билеты', выберите нужный билет и нажмите кнопку 'Отменить билет'.")
                        .padding(.vertical, 8)
                }
                
                DisclosureGroup("Как добавить фильм в избранное?") {
                    Text("На странице фильма нажмите кнопку в виде сердечка.")
                        .padding(.vertical, 8)
                }
            }
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Сообщение отправлено"),
                message: Text("Мы ответим вам в течение 24 часов на указанный email."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("Поддержка")
    }
    
    // Отправка запроса в поддержку
    private func sendSupportRequest() {
        isSending = true
        
        // Имитация отправки запроса
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSending = false
            showingSuccessAlert = true
            supportMessage = ""
        }
    }
}

// Расширение для модели User для создания заглушки
extension User {
    static var placeholder: User {
        User(
            id: "placeholder",
            email: "user@example.com",
            name: "Пользователь",
            avatar: nil
        )
    }
}

//
//  CinemasCoordinatorView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Представление для вкладки кинотеатров (CinemasCoordinatorView.swift)
import SwiftUI
import MapKit

struct CinemasCoordinatorView: View {
    @ObservedObject var coordinator: CinemasCoordinator
    
    var body: some View {
        NavigationView {
            Group {
                if coordinator.isLoading {
                    // Показываем индикатор загрузки
                    ProgressView("Загрузка кинотеатров...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = coordinator.errorMessage {
                    // Показываем сообщение об ошибке, если есть
                    VStack {
                        Text("Произошла ошибка")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                        
                        Button("Повторить") {
                            coordinator.loadCinemas()
                        }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    // Показываем список кинотеатров
                    CinemasListView(coordinator: coordinator)
                }
            }
            .navigationTitle("Кинотеатры")
            .background(
                // Детали кинотеатра
                NavigationLink(
                    destination: CinemaDetailView(cinema: coordinator.selectedCinema ?? Cinema.placeholder),
                    isActive: $coordinator.showingCinemaDetails
                ) {
                    EmptyView()
                }
            )
        }
    }
}

// Представление списка кинотеатров
struct CinemasListView: View {
    @ObservedObject var coordinator: CinemasCoordinator
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Переключатель между списком и картой
            Picker("Вид", selection: $selectedTab) {
                Text("Список").tag(0)
                Text("Карта").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                // Вид списка
                List {
                    ForEach(coordinator.cinemas) { cinema in
                        CinemaListItem(cinema: cinema)
                            .onTapGesture {
                                coordinator.selectCinema(cinema)
                            }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                // Вид карты
                CinemasMapView(cinemas: coordinator.cinemas) { cinema in
                    coordinator.selectCinema(cinema)
                }
            }
        }
    }
}

// Элемент списка кинотеатров
struct CinemaListItem: View {
    let cinema: Cinema
    
    var body: some View {
        HStack(spacing: 16) {
            // Изображение кинотеатра с использованием компонента FirebaseImage
            FirebaseImage(
                urlString: cinema.photoURLs.first ?? "",
                placeholder: "building",
                width: 80,
                height: 80
            )
            .cornerRadius(8)
            
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
        }
        .padding(.vertical, 8)
    }
}

// Представление кинотеатров на карте
struct CinemasMapView: View {
    let cinemas: [Cinema]
    let onCinemaSelect: (Cinema) -> Void
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423), // Москва
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: cinemas) { cinema in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: cinema.location.latitude,
                longitude: cinema.location.longitude
            )) {
                VStack {
                    Image(systemName: "film")
                        .foregroundColor(.red)
                        .font(.title)
                    
                    Text(cinema.name)
                        .font(.caption)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(4)
                }
                .onTapGesture {
                    onCinemaSelect(cinema)
                }
            }
        }
    }
}

// Представление деталей кинотеатра
struct CinemaDetailView: View {
    let cinema: Cinema
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Фотографии кинотеатра
                if !cinema.photoURLs.isEmpty {
                    TabView {
                        ForEach(cinema.photoURLs, id: \.self) { photoUrl in
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
                            .aspectRatio(16/9, contentMode: .fill)
                            .clipped()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 200)
                }
                
                // Информация о кинотеатре
                VStack(alignment: .leading, spacing: 12) {
                    // Название и рейтинг
                    HStack {
                        Text(cinema.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(cinema.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", cinema.rating))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Адрес
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.purple)
                        Text(cinema.address)
                    }
                    
                    // Описание
                    Text(cinema.description)
                        .padding(.vertical)
                    
                    // Удобства
                    if !cinema.amenities.isEmpty {
                        Text("Удобства")
                            .font(.headline)
                        
                        HStack {
                            ForEach(cinema.amenities, id: \.self) { amenity in
                                HStack {
                                    Image(systemName: amenityIcon(for: amenity))
                                    Text(amenity)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Контактная информация
                    Text("Контакты")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.purple)
                        Text(cinema.contactPhone)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.purple)
                        Text(cinema.contactEmail)
                    }
                    
                    // Часы работы
                    Text("Часы работы")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading) {
                        workingHoursRow("Понедельник", hours: cinema.workingHours.monday)
                        workingHoursRow("Вторник", hours: cinema.workingHours.tuesday)
                        workingHoursRow("Среда", hours: cinema.workingHours.wednesday)
                        workingHoursRow("Четверг", hours: cinema.workingHours.thursday)
                        workingHoursRow("Пятница", hours: cinema.workingHours.friday)
                        workingHoursRow("Суббота", hours: cinema.workingHours.saturday)
                        workingHoursRow("Воскресенье", hours: cinema.workingHours.sunday)
                    }
                    
                    // Карта
                    Text("Расположение")
                        .font(.headline)
                        .padding(.top)
                    
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: cinema.location.latitude,
                            longitude: cinema.location.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )), annotationItems: [cinema]) { cinema in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(
                            latitude: cinema.location.latitude,
                            longitude: cinema.location.longitude
                        )) {
                            Image(systemName: "film.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(cinema.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Функция для получения иконки для удобства
    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case "паркинг": return "car.fill"
        case "кафе": return "cup.and.saucer.fill"
        case "wi-fi": return "wifi"
        case "vip-зал": return "star.fill"
        case "imax": return "rectangle.expand.vertical"
        default: return "checkmark.circle.fill"
        }
    }
    
    // Функция для отображения часов работы
    private func workingHoursRow(_ day: String, hours: Cinema.DailyHours) -> some View {
        HStack {
            Text(day)
                .frame(width: 120, alignment: .leading)
            Text("\(hours.open) - \(hours.close)")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// Расширение для модели Cinema для создания заглушки
extension Cinema {
    static var placeholder: Cinema {
        Cinema(
            id: "placeholder",
            name: "Название кинотеатра",
            address: "Адрес кинотеатра",
            description: "Описание кинотеатра",
            photoURLs: [],
            location: GeoPoint(latitude: 55.751244, longitude: 37.618423),
            rating: 4.5,
            halls: [],
            amenities: ["Паркинг", "Кафе"],
            contactPhone: "+7 (999) 123-45-67",
            contactEmail: "cinema@example.com",
            workingHours: WorkingHours(
                monday: DailyHours(open: "09:00", close: "23:00"),
                tuesday: DailyHours(open: "09:00", close: "23:00"),
                wednesday: DailyHours(open: "09:00", close: "23:00"),
                thursday: DailyHours(open: "09:00", close: "23:00"),
                friday: DailyHours(open: "09:00", close: "23:00"),
                saturday: DailyHours(open: "09:00", close: "23:00"),
                sunday: DailyHours(open: "09:00", close: "23:00")
            )
        )
    }
}

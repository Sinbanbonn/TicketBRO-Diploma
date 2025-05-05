//
//  TicketsCoordinatorView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Представление для вкладки билетов (TicketsCoordinatorView.swift)
import SwiftUI

struct TicketsCoordinatorView: View {
    @ObservedObject var coordinator: TicketsCoordinator
    
    var body: some View {
        NavigationView {
            Group {
                if coordinator.user == nil {
                    // Если пользователь не авторизован
                    NotAuthorizedView()
                } else if coordinator.isLoading {
                    // Показываем индикатор загрузки
                    ProgressView("Загрузка билетов...")
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
                            coordinator.loadTickets()
                        }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top)
                    }
                    .padding()
                } else if coordinator.tickets.isEmpty {
                    // Если у пользователя нет билетов
                    NoTicketsView()
                } else {
                    // Показываем список билетов
                    TicketsListView(coordinator: coordinator)
                }
            }
            .navigationTitle("Мои билеты")
            .background(
                // Детали билета
                NavigationLink(
                    destination: TicketDetailView(
                        ticket: coordinator.selectedTicket ?? Ticket.placeholder,
                        coordinator: coordinator
                    ),
                    isActive: $coordinator.showingTicketDetails
                ) {
                    EmptyView()
                }
            )
        }
    }
}

// Представление при отсутствии авторизации
struct NotAuthorizedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Необходима авторизация")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Для просмотра билетов необходимо войти в аккаунт")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Войти") {
                // Логика для перехода к экрану входа
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

// Представление при отсутствии билетов
struct NoTicketsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("У вас пока нет билетов")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Здесь будут отображаться ваши билеты после покупки")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Перейти к фильмам") {
                // Логика для перехода к экрану фильмов
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

// Представление списка билетов
struct TicketsListView: View {
    @ObservedObject var coordinator: TicketsCoordinator
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Переключатель между активными и прошедшими билетами
            Picker("Билеты", selection: $selectedTab) {
                Text("Активные").tag(0)
                Text("История").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                // Активные билеты
                List {
                    ForEach(coordinator.tickets.filter { $0.sessionDate > Date() }) { ticket in
                        TicketListItem(ticket: ticket)
                            .onTapGesture {
                                coordinator.selectTicket(ticket)
                            }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                // История билетов
                List {
                    ForEach(coordinator.tickets.filter { $0.sessionDate <= Date() }) { ticket in
                        TicketHistoryItem(ticket: ticket)
                            .onTapGesture {
                                coordinator.selectTicket(ticket)
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// Элемент списка активных билетов
struct TicketListItem: View {
    let ticket: Ticket
    
    var body: some View {
        HStack(spacing: 16) {
            // Постер фильма
            AsyncImage(url: URL(string: ticket.moviePosterURL)) { phase in
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
                Text(ticket.movieTitle)
                    .font(.headline)
                
                // Название кинотеатра и зала
                Text("\(ticket.cinemaName), Зал \(ticket.hallName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Дата и время сеанса
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.purple)
                    
                    Text(dateFormatter.string(from: ticket.sessionDate))
                        .font(.subheadline)
                    
                    Image(systemName: "clock")
                        .foregroundColor(.purple)
                    
                    Text(timeFormatter.string(from: ticket.sessionDate))
                        .font(.subheadline)
                }
                
                // Места
                HStack {
                    Image(systemName: "seat.fill")
                        .foregroundColor(.purple)
                    
                    Text("Ряд \(ticket.row), Место \(ticket.seat)")
                        .font(.subheadline)
                }
            }
            
            Spacer()
            
            // Статус билета
            VStack {
                Text(ticket.status.localizedTitle)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ticketStatusColor(for: ticket.status))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    // Цвет статуса билета
    private func ticketStatusColor(for status: Ticket.Status) -> Color {
        switch status {
        case .active:
            return .green
        case .used:
            return .gray
        case .expired:
            return .red
        case .cancelled:
            return .orange
        }
    }
    
    // Форматирование даты
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    // Форматирование времени
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

// Элемент списка прошедших билетов
struct TicketHistoryItem: View {
    let ticket: Ticket
    
    var body: some View {
        HStack(spacing: 16) {
            // Постер фильма
            AsyncImage(url: URL(string: ticket.moviePosterURL)) { phase in
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
            .opacity(0.7)
            
            VStack(alignment: .leading, spacing: 4) {
                // Название фильма
                Text(ticket.movieTitle)
                    .font(.headline)
                
                // Название кинотеатра и зала
                Text("\(ticket.cinemaName), Зал \(ticket.hallName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Дата и время сеанса
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    
                    Text(dateFormatter.string(from: ticket.sessionDate))
                        .font(.subheadline)
                    
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    
                    Text(timeFormatter.string(from: ticket.sessionDate))
                        .font(.subheadline)
                }
            }
            
            Spacer()
            
            // Статус билета
            VStack {
                Text(ticket.status.localizedTitle)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ticketStatusColor(for: ticket.status))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .opacity(0.7)
    }
    
    // Цвет статуса билета
    private func ticketStatusColor(for status: Ticket.Status) -> Color {
        switch status {
        case .active:
            return .green
        case .used:
            return .gray
        case .expired:
            return .red
        case .cancelled:
            return .orange
        }
    }
    
    // Форматирование даты
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    // Форматирование времени
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

// Расширение для скругления определенных углов
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Координатор для вкладки билетов (TicketsCoordinator.swift)
import Foundation
import SwiftUI
import Combine

// Обновленный TicketsCoordinator с загрузкой билетов
class TicketsCoordinator: ObservableObject {
    // Контейнер зависимостей
    let container: DIContainer
    
    // Текущий пользователь
    let user: User?
    
    // Опубликованные свойства для навигации
    @Published var selectedTicket: Ticket?
    @Published var showingTicketDetails = false
    
    // Опубликованные свойства для отображения данных
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Подписки на события
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer, user: User?) {
        self.container = container
        self.user = user
        
        // Загружаем данные при инициализации
        if user != nil {
            loadTickets()
        }
        
        // Подписываемся на событие покупки билета
        setupSubscriptions()
    }
    
    // Настройка подписок
    private func setupSubscriptions() {
        // Подписка на обновление пользователя
        EventBus.shared.subscribeToUserUpdates()
            .sink { [weak self] user in
                // Перезагружаем билеты при обновлении пользователя
                self?.loadTickets()
            }
            .store(in: &cancellables)
        
        // Подписка на покупку билета
        EventBus.shared.subscribeToTicketPurchases()
            .sink { [weak self] ticket in
                // Добавляем новый билет в список и обновляем интерфейс
                self?.tickets.append(ticket)
            }
            .store(in: &cancellables)
    }
    
    // Загрузка билетов
    func loadTickets() {
        guard let user = user, let userId = user.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Запрос билетов пользователя из Firestore
        container.ticketService.query(field: "userId", isEqualTo: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                    print("❌ Ошибка при загрузке билетов: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] tickets in
                guard let self = self else { return }
                self.tickets = tickets
                print("✅ Загружено \(tickets.count) билетов")
                
                // Если у нас есть билеты, загрузим дополнительную информацию о фильмах и кинотеатрах
                if !tickets.isEmpty {
                    self.loadTicketDetails()
                }
            }
            .store(in: &cancellables)
    }
    
    // Загрузка дополнительных данных о билетах
    private func loadTicketDetails() {
        for (index, ticket) in tickets.enumerated() {
            // Загрузка информации о фильме
            container.movieService.getById(id: ticket.movieId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("❌ Ошибка при загрузке информации о фильме: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] movie in
                    guard let self = self, let movie = movie else { return }
                    
                    // Обновляем данные о фильме в билете
                    var updatedTicket = ticket
                    updatedTicket.movieTitle = movie.title
                    updatedTicket.moviePosterURL = movie.posterURL
                    
                    // Обновляем билет в массиве
                    if index < self.tickets.count {
                        self.tickets[index] = updatedTicket
                    }
                }
                .store(in: &cancellables)
            
            // Загрузка информации о кинотеатре
            container.cinemaService.getById(id: ticket.cinemaId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("❌ Ошибка при загрузке информации о кинотеатре: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] cinema in
                    guard let self = self, let cinema = cinema else { return }
                    
                    // Обновляем данные о кинотеатре в билете
                    var updatedTicket = ticket
                    updatedTicket.cinemaName = cinema.name
                    
                    // Ищем зал
                    for hall in cinema.halls where hall.id == ticket.hallId {
                        updatedTicket.hallName = hall.name
                        break
                    }
                    
                    // Обновляем билет в массиве
                    if index < self.tickets.count {
                        self.tickets[index] = updatedTicket
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    // Выбор билета для просмотра деталей
    func selectTicket(_ ticket: Ticket) {
        self.selectedTicket = ticket
        self.showingTicketDetails = true
    }
    
    // Проверка QR-кода билета
    func showTicketQRCode(_ ticket: Ticket) {
        self.selectedTicket = ticket
        // Логика для отображения QR-кода
    }
    
    // Отмена билета
    func cancelTicket(_ ticket: Ticket) -> AnyPublisher<Void, Error> {
        guard let ticketId = ticket.id else {
            return Fail(error: NSError(domain: "TicketsCoordinator", code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "Билет не имеет ID"]))
                .eraseToAnyPublisher()
        }
        
        // Обновляем статус билета на "отмененный"
        var updatedTicket = ticket
        updatedTicket.status = .cancelled
        
        return container.ticketService.update(id: ticketId, item: updatedTicket)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

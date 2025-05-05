//
//  TicketDetailViewModel.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import Foundation
import Combine
import SwiftUI

class TicketDetailViewModel: ObservableObject {
    // Билет, который отображается
    private let ticket: Ticket
    
    // Функция для отмены билета из координатора
    private let cancelTicketAction: (Ticket) -> AnyPublisher<Void, Error>
    
    // Состояние представления
    @Published var isShowingQRCode = false
    @Published var isShowingCancelAlert = false
    @Published var isCancelling = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var alertTitle = ""
    
    // Подписки на события
    private var cancellables = Set<AnyCancellable>()
    
    // Инициализатор
    init(ticket: Ticket, cancelTicketAction: @escaping (Ticket) -> AnyPublisher<Void, Error>) {
        self.ticket = ticket
        self.cancelTicketAction = cancelTicketAction
    }
    
    // Форматирование даты
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: ticket.sessionDate)
    }
    
    // Форматирование времени
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: ticket.sessionDate)
    }
    
    // Форматирование даты и времени
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: ticket.purchaseDate)
    }
    
    // Цвет статуса билета
    func ticketStatusColor(for status: Ticket.Status) -> Color {
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
    
    // Отмена билета
    func cancelTicket() {
        isCancelling = true
        
        cancelTicketAction(ticket)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isCancelling = false
                
                if case .failure(let error) = completion {
                    self.alertTitle = "Ошибка"
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.alertTitle = "Успешно"
                self.alertMessage = "Билет успешно отменен. Средства будут возвращены на ваш счет в течение 3-5 рабочих дней."
                self.showingAlert = true
            }
            .store(in: &cancellables)
    }
}
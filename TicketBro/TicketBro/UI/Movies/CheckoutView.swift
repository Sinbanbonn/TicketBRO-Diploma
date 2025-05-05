//
//  CheckoutView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// CheckoutView.swift
import SwiftUI
import Combine

struct CheckoutView: View {
    let movie: Movie
    let cinema: Cinema
    let session: Session
    let selectedSeats: [(row: Int, seat: Int)]
    let totalPrice: Double
    @ObservedObject var coordinator: MoviesCoordinator
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedPaymentMethod: PaymentMethod = .creditCard
    @State private var isProcessingPayment = false
    @State private var showingConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Форматтеры для дат
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // Доступные методы оплаты
    enum PaymentMethod: String, CaseIterable, Identifiable {
        case creditCard = "Банковская карта"
        case applePay = "Apple Pay"
        case payPal = "PayPal"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .creditCard: return "creditcard"
            case .applePay: return "apple.logo"
            case .payPal: return "p.circle"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Информация о заказе
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ваш заказ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Фильм и кинотеатр
                        HStack(alignment: .top, spacing: 16) {
                            // Постер фильма
                            FirebaseImage(
                                urlString: movie.posterURL,
                                placeholder: "film",
                                width: 80,
                                height: 120
                            )
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Название фильма
                                Text(movie.title)
                                    .font(.headline)
                                
                                // Кинотеатр и зал
                                Text("\(cinema.name), зал \(session.hallId)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Дата и время
                                Text("\(dateFormatter.string(from: session.date)), \(timeFormatter.string(from: session.date))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Формат
                                Text(session.format.rawValue.uppercased())
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        
                        Divider()
                        
                        // Выбранные места
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Выбранные места")
                                .font(.headline)
                            
                            ForEach(selectedSeats.sorted { a, b in
                                if a.row == b.row {
                                    return a.seat < b.seat
                                }
                                return a.row < b.row
                            }, id: \.self.row) { seat in
                                HStack {
                                    Text("Ряд \(seat.row), Место \(seat.seat)")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    // Цена за место (в зависимости от типа)
                                    let isVIP = seat.row >= 8 // Упрощенно считаем, что ряды с 8 по 10 - VIP
                                    let price = isVIP ? session.price * 1.5 : session.price
                                    
                                    Text("\(Int(price)) ₽")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        
                        Divider()
                        
                        // Итоговая сумма
                        HStack {
                            Text("Итого:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(totalPrice)) ₽")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Выбор способа оплаты
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Способ оплаты")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(PaymentMethod.allCases) { method in
                            PaymentMethodRow(
                                method: method,
                                isSelected: selectedPaymentMethod == method,
                                onSelect: { selectedPaymentMethod = method }
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Оформление заказа")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    processPayment()
                }) {
                    if isProcessingPayment {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Оплатить \(Int(totalPrice)) ₽")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                .disabled(isProcessingPayment)
            }
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingConfirmation) {
                OrderConfirmationView(
                    movie: movie,
                    cinema: cinema,
                    session: session,
                    selectedSeats: selectedSeats,
                    totalPrice: totalPrice,
                    coordinator: coordinator,
                    onClose: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // Обработка оплаты
    // Обработка оплаты
    private func processPayment() {
        isProcessingPayment = true
        
        // Симуляция процесса оплаты
        let deadline = DispatchTime.now() + 2.0
        
        // Создаем DispatchWorkItem с нашим замыканием
        let workItem = DispatchWorkItem {
            
            // Создаем билеты
            var tickets: [Ticket] = []
            
            for seat in self.selectedSeats {
                // Определяем тип места
                let isVIP = seat.row >= 8
                let price = isVIP ? self.session.price * 1.5 : self.session.price
                
                // Создаем билет
                let seatInfo = "\(seat.row)-\(seat.seat)"
                let ticketId = "\(self.session.id ?? "session")-\(seatInfo)"
                
                // Создаем билет с использованием конструктора Ticket
                let ticket = Ticket(
                    id: ticketId,
                    userId: self.coordinator.container.authService.currentUser?.id ?? "",
                    sessionId: self.session.id ?? "",
                    movieId: self.movie.id ?? "",
                    cinemaId: self.cinema.id ?? "",
                    hallId: self.session.hallId,
                    row: seat.row,
                    seat: seat.seat,
                    price: price,
                    purchaseDate: Date(),
                    sessionDate: self.session.date,
                    status: .active,
                    paymentMethod: self.selectedPaymentMethod.rawValue
                )
                
                tickets.append(ticket)
            }
            
            // Добавляем в базу данных - используем общий метод для всех билетов
            for ticket in tickets {
                self.coordinator.container.ticketService.add(item: ticket)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            self.isProcessingPayment = false
                            self.errorMessage = error.localizedDescription
                            self.showingError = true
                        }
                    } receiveValue: { _ in
                        // Обработка для каждого билета
                    }
                    .store(in: &self.coordinator.cancellables)
            }
            
            // После добавления всех билетов
            DispatchQueue.main.async {
                self.isProcessingPayment = false
                self.showingConfirmation = true
            }
        }
        
        // Запускаем выполнение задачи
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: workItem)
    }
}

// Строка выбора способа оплаты
struct PaymentMethodRow: View {
    let method: CheckoutView.PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Иконка метода оплаты
                Image(systemName: method.icon)
                    .font(.headline)
                    .foregroundColor(.purple)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 8)
                
                // Название метода оплаты
                Text(method.rawValue)
                    .font(.headline)
                
                Spacer()
                
                // Индикатор выбора
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .gray)
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.purple.opacity(0.05) : Color.white)
                    )
            )
            .contentShape(Rectangle()) // Для лучшей области нажатия
        }
        .buttonStyle(PlainButtonStyle()) // Убираем стандартную анимацию кнопки
    }
}

//
//  SeatSelectionView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// SeatSelectionView.swift
import SwiftUI
import Combine

struct SeatSelectionView: View {
    let movie: Movie
    let cinema: Cinema
    let session: Session
    @ObservedObject var coordinator: MoviesCoordinator
    @State private var selectedSeats: [(row: Int, seat: Int)] = []
    @State private var isShowingCheckout = false
    
    // Заглушка для схемы зала
    private let seatRows: [SeatRow] = [
        SeatRow(rowNumber: 1, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 2, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 3, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 4, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 5, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 6, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 7, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .standard) }),
        SeatRow(rowNumber: 8, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .vip) }),
        SeatRow(rowNumber: 9, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .vip) }),
        SeatRow(rowNumber: 10, seats: Array(1...10).map { Seat(seatNumber: $0, seatType: .vip) })
    ]
    
    // Занятые места (заглушка)
    private let occupiedSeats: [(row: Int, seat: Int)] = [
        (1, 3), (1, 4), (2, 7), (2, 8), (3, 5), (4, 9), (5, 2), (5, 3),
        (6, 6), (7, 1), (8, 4), (9, 9), (10, 5), (10, 6)
    ]
    
    // Общая стоимость выбранных билетов
    private var totalPrice: Double {
        var price = 0.0
        for seat in selectedSeats {
            if let row = seatRows.first(where: { $0.rowNumber == seat.row }) {
                if let seatObj = row.seats.first(where: { $0.seatNumber == seat.seat }) {
                    price += seatObj.seatType == .vip ? session.price * 1.5 : session.price
                }
            }
        }
        return price
    }
    
    // Форматтер для времени
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // Форматтер для даты
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Информация о сеансе
            VStack(spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                
                HStack {
                    Text(cinema.name)
                    Text("•")
                    Text("Зал \(session.hallId)")
                    Text("•")
                    Text("\(dateFormatter.string(from: session.date)), \(timeFormatter.string(from: session.date))")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding()
            
            // Экран
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                    .cornerRadius(4)
                
                Text("ЭКРАН")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)
            .padding(.vertical)
            
            // Схема зала
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(seatRows) { row in
                        HStack(spacing: 8) {
                            // Номер ряда
                            Text("\(row.rowNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            
                            // Места
                            ForEach(row.seats) { seat in
                                SeatView(
                                    row: row.rowNumber,
                                    seat: seat,
                                    isSelected: selectedSeats.contains(where: { $0.row == row.rowNumber && $0.seat == seat.seatNumber }),
                                    isOccupied: occupiedSeats.contains(where: { $0.row == row.rowNumber && $0.seat == seat.seatNumber }),
                                    onTap: { row, seat in
                                        toggleSeat(row: row, seat: seat)
                                    }
                                )
                            }
                            
                            // Номер ряда (с правой стороны)
                            Text("\(row.rowNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                        }
                    }
                }
                .padding()
                
                // Легенда
                HStack(spacing: 16) {
                    // Свободное место
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                        
                        Text("Свободно")
                            .font(.caption)
                    }
                    
                    // Выбранное место
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                        
                        Text("Выбрано")
                            .font(.caption)
                    }
                    
                    // Занятое место
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                        
                        Text("Занято")
                            .font(.caption)
                    }
                }
                .padding()
                
                // VIP-места
                HStack(spacing: 8) {
                    Rectangle()
                        .stroke(Color.orange, lineWidth: 2)
                        .background(Color.orange.opacity(0.1))
                        .frame(width: 20, height: 20)
                        .cornerRadius(4)
                    
                    Text("VIP (+50%)")
                        .font(.caption)
                }
                .padding(.bottom)
            }
            
            // Нижняя панель с информацией и кнопкой
            VStack(spacing: 12) {
                HStack {
                    // Выбранные места
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Выбранные места:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if selectedSeats.isEmpty {
                            Text("Не выбрано")
                                .font(.subheadline)
                        } else {
                            Text(formattedSelectedSeats)
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                    
                    // Стоимость
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Стоимость:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(totalPrice)) ₽")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    isShowingCheckout = true
                }) {
                    Text("Оформить заказ")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedSeats.isEmpty ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedSeats.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 5, y: -5)
        }
        .navigationTitle("Выбор мест")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingCheckout) {
            CheckoutView(
                movie: movie,
                cinema: cinema,
                session: session,
                selectedSeats: selectedSeats,
                totalPrice: totalPrice,
                coordinator: coordinator
            )
        }
    }
    
    // Переключение выбора места
    private func toggleSeat(row: Int, seat: Int) {
        // Проверяем, занято ли место
        if occupiedSeats.contains(where: { $0.row == row && $0.seat == seat }) {
            return
        }
        
        // Если место уже выбрано, удаляем его
        if let index = selectedSeats.firstIndex(where: { $0.row == row && $0.seat == seat }) {
            selectedSeats.remove(at: index)
        } else {
            // Иначе добавляем его в выбранные
            selectedSeats.append((row: row, seat: seat))
        }
    }
    
    // Форматирование выбранных мест
    private var formattedSelectedSeats: String {
        let sortedSeats = selectedSeats.sorted { a, b in
            if a.row == b.row {
                return a.seat < b.seat
            }
            return a.row < b.row
        }
        
        return sortedSeats.map { "Ряд \($0.row) Место \($0.seat)" }.joined(separator: ", ")
    }
}

// Представление для отображения места
struct SeatView: View {
    let row: Int
    let seat: Seat
    let isSelected: Bool
    let isOccupied: Bool
    let onTap: (Int, Int) -> Void
    
    var body: some View {
        Button(action: {
            if !isOccupied {
                onTap(row, seat.seatNumber)
            }
        }) {
            Text("\(seat.seatNumber)")
                .font(.caption)
                .foregroundColor(textColor)
                .frame(width: 24, height: 24)
                .background(backgroundColor)
                .overlay(
                    seat.seatType == .vip ?
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.orange, lineWidth: 2)
                        .opacity(isOccupied ? 0.3 : 1) : nil
                )
                .cornerRadius(4)
        }
        .disabled(isOccupied)
    }
    
    // Цвет фона в зависимости от статуса места
    private var backgroundColor: Color {
        if isOccupied {
            return Color.gray
        } else if isSelected {
            return Color.purple
        } else {
            return seat.seatType == .vip ? Color.orange.opacity(0.1) : Color.gray.opacity(0.2)
        }
    }
    
    // Цвет текста в зависимости от статуса места
    private var textColor: Color {
        if isOccupied {
            return Color.white
        } else if isSelected {
            return Color.white
        } else {
            return Color.primary
        }
    }
}

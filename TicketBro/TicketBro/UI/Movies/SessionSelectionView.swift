//
//  SessionSelectionView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// SessionSelectionView.swift
import SwiftUI
import Combine

struct SessionSelectionView: View {
    let movie: Movie
    let cinema: Cinema
    @ObservedObject var coordinator: MoviesCoordinator
    @State private var selectedDate: Date = Date()
    @State private var selectedSession: Session? = nil
    
    // Форматтеры для дат
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // Получаем даты на ближайшие 7 дней
    private var availableDates: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    // Получаем сеансы для выбранной даты
    private var sessionsForSelectedDate: [Session] {
        // В реальном приложении здесь будет запрос к Firebase
        return coordinator.container.sessionService.getTestSessions(
            movieId: movie.id ?? "",
            cinemaId: cinema.id ?? "",
            date: selectedDate
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Информация о фильме и кинотеатре
            VStack(spacing: 8) {
                Text(movie.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(cinema.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Выбор даты
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableDates, id: \.self) { date in
                        DateSelectionItem(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            dateFormatter: dateFormatter,
                            dayFormatter: dayFormatter
                        )
                        .onTapGesture {
                            selectedDate = date
                            selectedSession = nil
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Список сеансов
            ScrollView {
                if sessionsForSelectedDate.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Нет доступных сеансов")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("На выбранную дату нет сеансов для этого фильма. Пожалуйста, выберите другую дату или кинотеатр.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                } else {
                    // Группировка сеансов по залам
                    ForEach(cinema.halls, id: \.id) { hall in
                        let hallSessions = sessionsForSelectedDate.filter { $0.hallId == hall.id }
                        
                        if !hallSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(hall.name)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                
                                // Сетка с доступными временами
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                                    ForEach(hallSessions) { session in
                                        SessionTimeItem(
                                            session: session,
                                            isSelected: selectedSession?.id == session.id,
                                            timeFormatter: timeFormatter
                                        )
                                        .onTapGesture {
                                            selectedSession = session
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Информация о форматах и обозначениях
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Информация")
                            .font(.headline)
                            .padding(.top, 16)
                        
                        HStack(spacing: 16) {
                            ForEach(Session.MovieFormat.allCases, id: \.self) { format in
                                HStack {
                                    Text(format.rawValue.uppercased())
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Кнопка выбора мест
            Button(action: {
                if let session = selectedSession {
                    coordinator.navigateToSeatSelection(movie: movie, cinema: cinema, session: session)
                }
            }) {
                Text("Выбрать места")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedSession != nil ? Color.purple : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(selectedSession == nil)
            .padding()
        }
        .navigationTitle("Выбор сеанса")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Элемент выбора даты
struct DateSelectionItem: View {
    let date: Date
    let isSelected: Bool
    let dateFormatter: DateFormatter
    let dayFormatter: DateFormatter
    
    var body: some View {
        VStack(spacing: 8) {
            // День недели
            Text(dayFormatter.string(from: date))
                .font(.caption)
                .foregroundColor(isToday(date) ? .purple : .secondary)
            
            // Число и месяц
            Text(dateFormatter.string(from: date))
                .fontWeight(isSelected ? .bold : .regular)
            
            // Индикатор выбора
            Circle()
                .fill(isSelected ? Color.purple : Color.clear)
                .frame(width: 6, height: 6)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.purple.opacity(0.1) : Color.clear)
        )
    }
    
    // Проверка, является ли дата сегодняшней
    private func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
}

// Элемент выбора времени сеанса
struct SessionTimeItem: View {
    let session: Session
    let isSelected: Bool
    let timeFormatter: DateFormatter
    
    var body: some View {
        VStack(spacing: 4) {
            // Время
            Text(timeFormatter.string(from: session.date))
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            
            // Формат
            Text(session.format.rawValue.uppercased())
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            
            // Цена
            Text("\(Int(session.price))₽")
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(minWidth: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.purple : Color.gray.opacity(0.1))
        )
    }
}
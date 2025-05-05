// OrderConfirmationView.swift
import SwiftUI
import Combine

struct OrderConfirmationView: View {
    let movie: Movie
    let cinema: Cinema
    let session: Session
    let selectedSeats: [(row: Int, seat: Int)]
    let totalPrice: Double
    @ObservedObject var coordinator: MoviesCoordinator
    let onClose: () -> Void
    
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок и анимация успеха
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Заказ оформлен!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Ваши билеты будут доступны в разделе «Билеты»")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Информация о заказе
                VStack(alignment: .leading, spacing: 16) {
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
                        Text("Ваши места")
                            .font(.headline)
                        
                        Text(selectedSeats.sorted { a, b in
                            if a.row == b.row {
                                return a.seat < b.seat
                            }
                            return a.row < b.row
                        }.map { "Ряд \($0.row), Место \($0.seat)" }.joined(separator: ", "))
                        .font(.subheadline)
                    }
                    
                    Divider()
                    
                    // Итоговая сумма
                    HStack {
                        Text("Оплачено:")
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
                
                // QR-код для электронного билета
                VStack(spacing: 16) {
                    Text("QR-код на входе")
                        .font(.headline)
                    
                    Image(systemName: "qrcode")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding()
                    
                    Text("Покажите этот QR-код при входе в зал")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Кнопки действий
                VStack(spacing: 12) {
                    Button(action: {
                        // Переход к билетам
                        onClose()
                        coordinator.navigateToTickets()
                    }) {
                        HStack {
                            Image(systemName: "ticket")
                            Text("Перейти к моим билетам")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onClose()
                    }) {
                        Text("Закрыть")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
    }
}

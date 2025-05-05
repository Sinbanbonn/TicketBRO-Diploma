//
//  TicketDetailView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import SwiftUI
import Combine

struct TicketDetailView: View {
    let ticket: Ticket
    @ObservedObject var coordinator: TicketsCoordinator
    @StateObject private var viewModel: TicketDetailViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    init(ticket: Ticket, coordinator: TicketsCoordinator) {
        self.ticket = ticket
        self.coordinator = coordinator
        // Инициализируем ViewModel, передавая метод cancelTicket из координатора
        _viewModel = StateObject(wrappedValue: TicketDetailViewModel(
            ticket: ticket,
            cancelTicketAction: { ticket in
                coordinator.cancelTicket(ticket)
            }
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Верхняя часть билета
                VStack(spacing: 0) {
                    // Фильм и кинотеатр
                    VStack(spacing: 8) {
                        // Постер фильма
                        // Постер фильма - улучшенная версия
                        AsyncImage(url: URL(string: ticket.moviePosterURL)) { phase in
                            switch phase {
                            case .empty:
                                // Состояние загрузки
                                VStack {
                                    Image(systemName: "film")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                    
                                    Text("Загрузка...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            case .success(let image):
                                // Успешная загрузка
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipped()
                            case .failure:
                                // Ошибка загрузки - показываем заглушку
                                VStack {
                                    Image(systemName: "film.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.purple)
                                    
                                    Text(ticket.movieTitle)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 8)
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            @unknown default:
                                // Неизвестное состояние
                                VStack {
                                    Image(systemName: "film.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.purple)
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(ticket.movieTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(ticket.cinemaName)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Статус билета
                        HStack {
                            Text(ticket.status.localizedTitle)
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.ticketStatusColor(for: ticket.status))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Разделитель в стиле билета
                    HStack(spacing: 0) {
                        ForEach(0..<20) { _ in
                            Circle()
                                .fill(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
                                .frame(width: 15, height: 15)
                                .offset(y: 7.5)
                        }
                    }
                    .frame(height: 15)
                    .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    
                    // Основная информация о билете
                    VStack(spacing: 20) {
                        // Дата и время
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Дата")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(viewModel.formattedDate)
                                    .font(.title3)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Время")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(viewModel.formattedTime)
                                    .font(.title3)
                            }
                        }
                        
                        Divider()
                        
                        // Зал и места
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Зал")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(ticket.hallName)
                                    .font(.title3)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Место")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Ряд \(ticket.row), Место \(ticket.seat)")
                                    .font(.title3)
                            }
                        }
                        
                        Divider()
                        
                        // Формат и цена
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Формат")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(ticket.format.rawValue.uppercased())
                                    .font(.title3)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Цена")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(ticket.price)) ₽")
                                    .font(.title3)
                            }
                        }
                        
                        // QR-код билета
                        if ticket.status == .active {
                            Button(action: {
                                viewModel.isShowingQRCode = true
                            }) {
                                HStack {
                                    Image(systemName: "qrcode")
                                    Text("Показать QR-код")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        
                        // Кнопка отмены билета
                        if ticket.status == .active && ticket.canCancel {
                            Button(action: {
                                viewModel.isShowingCancelAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Отменить билет")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isCancelling)
                            .alert(isPresented: $viewModel.isShowingCancelAlert) {
                                Alert(
                                    title: Text("Отмена билета"),
                                    message: Text("Вы уверены, что хотите отменить билет? Средства будут возвращены на ваш счет в течение 3-5 рабочих дней."),
                                    primaryButton: .destructive(Text("Отменить билет")) {
                                        viewModel.cancelTicket()
                                    },
                                    secondaryButton: .cancel(Text("Не отменять"))
                                )
                            }
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                
                // Дополнительная информация
                VStack(alignment: .leading, spacing: 16) {
                    Text("Информация о заказе")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Номер билета:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ticket.id?.prefix(10) ?? "Н/Д")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Дата покупки:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.formattedDateTime)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Метод оплаты:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ticket.paymentMethod)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.top, 16)
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.isShowingQRCode) {
            TicketQRCodeView(ticket: ticket)
        }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle("Билет", displayMode: .inline)
        .background(colorScheme == .dark ? Color.black : Color(.systemGray6))
        .edgesIgnoringSafeArea(.bottom)
    }
}

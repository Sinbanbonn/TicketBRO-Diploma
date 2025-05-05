//
//  CinemaSelectionView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// CinemaSelectionView.swift
import SwiftUI
import Combine

struct CinemaSelectionView: View {
    let movie: Movie
    @ObservedObject var coordinator: MoviesCoordinator
    @State private var selectedCinemaId: String? = nil
    
    var body: some View {
        VStack {
            // Заголовок
            VStack(alignment: .leading, spacing: 4) {
                Text("Выберите кинотеатр")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Для фильма \"\(movie.title)\"")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            // Список кинотеатров
            ScrollView {
                VStack(spacing: 12) {
                    // Заглушка - здесь будут реальные кинотеатры, где показывают фильм
                    // В реальном приложении нужно сделать запрос к Firebase
                    ForEach(coordinator.container.cinemaService.getTestCinemas()) { cinema in
                        CinemaSelectionItem(
                            cinema: cinema,
                            isSelected: selectedCinemaId == cinema.id
                        )
                        .onTapGesture {
                            selectedCinemaId = cinema.id
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Кнопка "Продолжить"
            Button(action: {
                if let cinemaId = selectedCinemaId,
                   let cinema = coordinator.container.cinemaService.getTestCinemas().first(where: { $0.id == cinemaId }) {
                    coordinator.navigateToSessionSelection(movie: movie, cinema: cinema)
                }
            }) {
                Text("Продолжить")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedCinemaId != nil ? Color.purple : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(selectedCinemaId == nil)
            .padding()
        }
        .navigationTitle("Выбор кинотеатра")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Элемент списка кинотеатров
struct CinemaSelectionItem: View {
    let cinema: Cinema
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Изображение кинотеатра
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
            
            // Индикатор выбора
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .purple : .gray)
                .font(.title2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.purple : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                .background(isSelected ? Color.purple.opacity(0.05) : Color.white)
        )
    }
}
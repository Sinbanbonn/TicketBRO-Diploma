//
//  MovieDetailView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import SwiftUI
import Combine

struct MovieDetailView: View {
    let movie: Movie
    @ObservedObject var coordinator: MoviesCoordinator
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Фоновое изображение и постер
                ZStack(alignment: .bottom) {
                    // Фоновое изображение
                    if let backdropURL = movie.backdropURL, !backdropURL.isEmpty {
                        AsyncImage(url: URL(string: backdropURL)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                                    .blur(radius: 3)
                                    .overlay(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            case .failure:
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            @unknown default:
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            }
                        }
                    } else {
                        Rectangle()
                            .foregroundColor(.gray)
                            .frame(height: 200)
                    }
                    
                    // Постер и основная информация
                    HStack(alignment: .bottom, spacing: 16) {
                        // Постер
                        FirebaseImage(
                            urlString: movie.posterURL,
                            placeholder: "film",
                            width: 120,
                            height: 180
                        )
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .offset(y: 20)
                        
                        // Основная информация
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let originalTitle = movie.originalTitle, originalTitle != movie.title {
                                Text(originalTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            HStack {
                                Text("\(movie.year)")
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(movie.duration) мин.")
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(movie.ageRestriction)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .font(.subheadline)
                            
                            // Жанры
                            if !movie.genres.isEmpty {
                                Text(movie.genres.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Рейтинг
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: Double(index) < movie.rating / 2.0 ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                                Text(String(format: "%.1f", movie.rating))
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(height: 220)
                
                // Кнопка покупки билетов
                Button(action: {
                    coordinator.selectCinemaForMovie(movie)
                }) {
                    Text("Купить билеты")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                
                // Описание фильма
                VStack(alignment: .leading, spacing: 8) {
                    Text("Описание")
                        .font(.headline)
                    
                    Text(movie.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Информация о съемочной группе
                VStack(alignment: .leading, spacing: 8) {
                    Text("Информация")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // Режиссер
                    HStack(alignment: .top) {
                        Text("Режиссер:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(movie.director)
                            .font(.subheadline)
                    }
                    
                    // В ролях
                    HStack(alignment: .top) {
                        Text("В ролях:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(movie.cast.joined(separator: ", "))
                            .font(.subheadline)
                    }
                    
                    // Язык
                    HStack(alignment: .top) {
                        Text("Язык:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(movie.language)
                            .font(.subheadline)
                    }
                    
                    // Субтитры
                    if let subtitles = movie.subtitles {
                        HStack(alignment: .top) {
                            Text("Субтитры:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            Text(subtitles)
                                .font(.subheadline)
                        }
                    }
                    
                    // Формат
                    HStack(alignment: .top) {
                        Text("Формат:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(movie.format.map { $0.rawValue.uppercased() }.joined(separator: ", "))
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                // Трейлер, если доступен
                if let trailerURL = movie.trailerURL, !trailerURL.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Трейлер")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        // Здесь будет видеоплеер, для прототипа используем заглушку
                        ZStack {
                            Rectangle()
                                .foregroundColor(.black)
                                .aspectRatio(16/9, contentMode: .fit)
                                .cornerRadius(8)
                            
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .onTapGesture {
                            // Открытие трейлера
                            if let url = URL(string: trailerURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//
//  MoviesCoordinatorView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Представление для вкладки фильмов (MoviesCoordinatorView.swift)
import SwiftUI

struct MoviesCoordinatorView: View {
    @ObservedObject var coordinator: MoviesCoordinator
    
    var body: some View {
        NavigationView {
            Group {
                if coordinator.isLoading {
                    // Показываем индикатор загрузки
                    ProgressView("Загрузка фильмов...")
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
                            coordinator.loadMovies()
                        }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    // Показываем список фильмов
                    MoviesListView(coordinator: coordinator)
                }
            }
            .navigationTitle("Фильмы")
            // Навигационные ссылки для перехода на детальные экраны
            .background(
                Group {
                    // Детали фильма
                    NavigationLink(
                        destination: MovieDetailView(movie: coordinator.selectedMovie ?? Movie.placeholder, coordinator: coordinator),
                        isActive: $coordinator.showingMovieDetails
                    ) {
                        EmptyView()
                    }
                    
                    // Выбор кинотеатра
                    NavigationLink(
                        destination: CinemaSelectionView(movie: coordinator.selectedMovie ?? Movie.placeholder, coordinator: coordinator),
                        isActive: $coordinator.showingCinemaSelection
                    ) {
                        EmptyView()
                    }
                    
                    // Выбор сеанса
                    NavigationLink(
                        destination: SessionSelectionView(
                            movie: coordinator.selectedMovie ?? Movie.placeholder,
                            cinema: coordinator.selectedCinema ?? Cinema.placeholder,
                            coordinator: coordinator
                        ),
                        isActive: $coordinator.showingSessionSelection
                    ) {
                        EmptyView()
                    }
                    
                    // Выбор мест
                    NavigationLink(
                        destination: SeatSelectionView(
                            movie: coordinator.selectedMovie ?? Movie.placeholder,
                            cinema: coordinator.selectedCinema ?? Cinema.placeholder,
                            session: coordinator.selectedSession ?? Session.placeholder,
                            coordinator: coordinator
                        ),
                        isActive: $coordinator.showingSeatSelection
                    ) {
                        EmptyView()
                    }
                }
            )
        }
    }
}

// Заглушка для списка фильмов
struct MoviesListView: View {
    @ObservedObject var coordinator: MoviesCoordinator
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Секция "Сейчас в кино"
                if !coordinator.featuredMovies.isEmpty {
                    MovieCarouselSection(
                        title: "Сейчас в кино",
                        movies: coordinator.featuredMovies,
                        onMovieSelect: { coordinator.selectMovie($0) }
                    )
                }
                
                // Секция "Скоро в прокате"
                if !coordinator.upcomingMovies.isEmpty {
                    MovieCarouselSection(
                        title: "Скоро в прокате",
                        movies: coordinator.upcomingMovies,
                        onMovieSelect: { coordinator.selectMovie($0) }
                    )
                }
                
                // Секция "Все фильмы"
                Text("Все фильмы")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    ForEach(coordinator.movies) { movie in
                        MovieGridItem(movie: movie)
                            .onTapGesture {
                                coordinator.selectMovie(movie)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// Компонент для карусели фильмов
struct MovieCarouselSection: View {
    let title: String
    let movies: [Movie]
    let onMovieSelect: (Movie) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(movies) { movie in
                        MovieCarouselItem(movie: movie)
                            .onTapGesture {
                                onMovieSelect(movie)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Элемент карусели фильмов
struct MovieCarouselItem: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Фиксированный spacing
            // Постер фильма - фиксированные размеры для всех
            if let image = movie.getPosterImage() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                    .clipped() // Обрезаем выходящее за пределы
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
            }
            
            // Название фильма с фиксированной высотой
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
                .frame(width: 120, height: 40, alignment: .topLeading) // Фиксированная высота
            
            // Рейтинг
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", movie.rating))
                    .font(.subheadline)
            }
        }
        .frame(width: 120)
    }
}

struct MovieGridItem: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Фиксированный spacing
            // Постер фильма
            FirebaseImage(
                urlString: movie.posterURL,
                placeholder: "film",
                width: 160,
                height: 240
            )
            .cornerRadius(8)
            
            // Название фильма с фиксированной высотой
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
                .frame(height: 40, alignment: .topLeading) // Фиксированная высота
            
            // Рейтинг
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", movie.rating))
                    .font(.subheadline)
            }
        }
    }
}

// Расширение для модели Movie для создания заглушки
extension Movie {
    static var placeholder: Movie {
        Movie(
            id: "placeholder",
            title: "Название фильма",
            originalTitle: "Original Title",
            year: 2025,
            duration: 120,
            genres: ["Жанр 1", "Жанр 2"],
            description: "Описание фильма",
            posterURL: "",
            backdropURL: nil,
            trailerURL: nil,
            director: "Режиссер",
            cast: ["Актер 1", "Актер 2"],
            rating: 8.0,
            ageRestriction: "16+",
            releaseDate: Date(),
            endScreeningDate: Date().addingTimeInterval(60*60*24*30), // +30 дней
            language: "Русский",
            subtitles: nil,
            format: [.imax, ._3D]
        )
    }
}

// MoviesCoordinator.swift (обновленный)
import Foundation
import SwiftUI
import Combine

class MoviesCoordinator: ObservableObject {
    // Контейнер зависимостей
    let container: DIContainer
    
    // Опубликованные свойства для навигации
    @Published var selectedMovie: Movie?
    @Published var showingMovieDetails = false
    @Published var showingCinemaSelection = false
    @Published var showingSessionSelection = false
    @Published var showingSeatSelection = false
    
    // Дополнительные свойства для процесса покупки билетов
    @Published var selectedCinema: Cinema?
    @Published var selectedSession: Session?
    
    // Опубликованные свойства для отображения данных
    @Published var movies: [Movie] = []
    @Published var featuredMovies: [Movie] = []
    @Published var upcomingMovies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Подписки на события
    var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        
        // Загружаем данные при инициализации
        loadMovies()
    }
    
    // Загрузка фильмов
    func loadMovies() {
        isLoading = true
        errorMessage = nil
        
        container.movieService.getAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                    print("❌ Ошибка при загрузке фильмов: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.movies = movies
                
                // Подготовка данных для разных секций
                self.prepareFeaturedAndUpcomingMovies()
                
                print("✅ Загружено \(movies.count) фильмов")
            }
            .store(in: &cancellables)
    }
    
    // Подготовка данных для разных секций
    private func prepareFeaturedAndUpcomingMovies() {
        // Фильмы, которые уже вышли в прокат
        self.featuredMovies = self.movies.filter { movie in
            guard let endDate = movie.endScreeningDate else { return false }
            return movie.releaseDate <= Date() && endDate >= Date()
        }
        
        // Предстоящие фильмы
        self.upcomingMovies = self.movies.filter { $0.releaseDate > Date() }
    }
    
    // Выбор фильма для просмотра деталей
    func selectMovie(_ movie: Movie) {
        self.selectedMovie = movie
        self.showingMovieDetails = true
    }
    
    // Выбор кинотеатра для просмотра сеансов
    func selectCinemaForMovie(_ movie: Movie) {
        self.selectedMovie = movie
        self.showingCinemaSelection = true
    }
    
    // Навигация к выбору сеанса
    func navigateToSessionSelection(movie: Movie, cinema: Cinema) {
        self.selectedMovie = movie
        self.selectedCinema = cinema
        self.showingSessionSelection = true
    }
    
    // Навигация к выбору мест
    func navigateToSeatSelection(movie: Movie, cinema: Cinema, session: Session) {
        self.selectedMovie = movie
        self.selectedCinema = cinema
        self.selectedSession = session
        self.showingSeatSelection = true
    }
    
    // Навигация к разделу Билеты
    func navigateToTickets() {
        // Переключаем на вкладку Билеты
        // Это можно реализовать через EventBus или через передачу замыкания от MainTabView
        EventBus.shared.publish(.switchToTicketsTab)
    }
}

//
//  CinemasCoordinator.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Координатор для вкладки кинотеатров (CinemasCoordinator.swift)
import Foundation
import SwiftUI
import Combine

class CinemasCoordinator: ObservableObject {
    // Контейнер зависимостей
    let container: DIContainer
    
    // Опубликованные свойства для навигации
    @Published var selectedCinema: Cinema?
    @Published var showingCinemaDetails = false
    
    // Опубликованные свойства для отображения данных
    @Published var cinemas: [Cinema] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Подписки на события
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        
        // Загружаем данные при инициализации
        loadCinemas()
    }
    
    // Загрузка кинотеатров из Firebase
    // Загрузка кинотеатров из Firebase
    func loadCinemas() {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Начинаем загрузку кинотеатров...")
        
        container.cinemaService.getAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                    print("❌ Ошибка при загрузке кинотеатров: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] cinemas in
                guard let self = self else { return }
                self.cinemas = cinemas
                print("✅ Загружено \(cinemas.count) кинотеатров")

            }
            .store(in: &cancellables)
    }
    
    // Выбор кинотеатра для просмотра деталей
    func selectCinema(_ cinema: Cinema) {
        self.selectedCinema = cinema
        self.showingCinemaDetails = true
    }
}

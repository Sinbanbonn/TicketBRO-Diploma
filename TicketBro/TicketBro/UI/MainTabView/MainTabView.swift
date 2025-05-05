//
//  MainTabView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

// MainTabView.swift (обновленный)
import SwiftUI
import Combine

struct MainTabView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var selectedTab = 0
    
    // Подписки на события
    @StateObject private var eventSubscriber = EventSubscriber()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка с фильмами
            MoviesCoordinatorView(coordinator: MoviesCoordinator(container: coordinator.container))
                .tabItem {
                    Label("Фильмы", systemImage: "film")
                }
                .tag(0)
            
            // Вкладка с кинотеатрами
            CinemasCoordinatorView(coordinator: CinemasCoordinator(container: coordinator.container))
                .tabItem {
                    Label("Кинотеатры", systemImage: "building.2")
                }
                .tag(1)
            
            // Вкладка с билетами
            TicketsCoordinatorView(coordinator: TicketsCoordinator(container: coordinator.container, user: coordinator.currentUser))
                .tabItem {
                    Label("Билеты", systemImage: "ticket")
                }
                .tag(2)
            
            // Вкладка с профилем
            ProfileCoordinatorView(
                coordinator: ProfileCoordinator(
                    container: coordinator.container,
                    user: coordinator.currentUser,
                    logoutAction: { coordinator.logout() }
                )
            )
            .tabItem {
                Label("Профиль", systemImage: "person")
            }
            .tag(3)
        }
        .accentColor(.purple) // Основной цвет приложения
        .onReceive(eventSubscriber.$shouldSwitchToTicketsTab) { shouldSwitch in
            if shouldSwitch {
                selectedTab = 2 // Переключаемся на вкладку "Билеты"
                eventSubscriber.shouldSwitchToTicketsTab = false
            }
        }
    }
}

// Подписчик на события для MainTabView
class EventSubscriber: ObservableObject {
    @Published var shouldSwitchToTicketsTab = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Подписываемся на событие переключения вкладки
        EventBus.shared.subscribeToTabSwitch()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.shouldSwitchToTicketsTab = true
            }
            .store(in: &cancellables)
    }
}

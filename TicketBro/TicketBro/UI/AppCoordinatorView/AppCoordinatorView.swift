//
//  AppCoordinatorView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import SwiftUI

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        Group {
            switch coordinator.authState {
            case .loading:
                // Экран загрузки при запуске приложения
                SplashScreenView()
            case .authenticated:
                // Основное содержимое приложения для авторизованных пользователей
                MainTabView(coordinator: coordinator)
            case .unauthenticated:
                // Экраны авторизации для неавторизованных пользователей
                AuthCoordinatorView(coordinator: coordinator)
            }
        }
    }
}

// Вспомогательный экран загрузки
struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(systemName: "film.fill") // Логотип приложения
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("TicketBro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 40)
            }
        }
    }
}

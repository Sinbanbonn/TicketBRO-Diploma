//
//  ViewModel.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import Foundation
import Combine

protocol ViewModel: ObservableObject {
    // Контейнер зависимостей
    var container: DIContainer { get }
    
    // Подписки на события
    var cancellables: Set<AnyCancellable> { get set }
}

//
//  Coordinator.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Core/Protocols/Coordinator.swift
import Foundation
import SwiftUI

protocol Coordinator: ObservableObject {
    associatedtype ContentView: View
    
    // Представление, управляемое координатором
    var contentView: ContentView { get }
    
    // Контейнер зависимостей
    var container: DIContainer { get }
}
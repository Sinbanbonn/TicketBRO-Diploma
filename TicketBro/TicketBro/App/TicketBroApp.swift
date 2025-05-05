//
//  TicketBroApp.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import SwiftUI
import Firebase

@main
struct TicketBroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
        }
    }
}

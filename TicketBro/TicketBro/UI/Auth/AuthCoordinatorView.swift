//
//  AuthCoordinatorView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import SwiftUI
import Combine

struct AuthCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var showLogin = true
    
    var body: some View {
        NavigationView {
            if showLogin {
                LoginView(
                    login: { email, password in
                        coordinator.login(email: email, password: password)
                    },
                    navigateToRegister: { showLogin = false },
                    resetPassword: { email in
                        coordinator.resetPassword(email: email)
                    }
                )
            } else {
                RegisterView(
                    register: { email, password, name in
                        coordinator.register(email: email, password: password, name: name)
                    },
                    navigateToLogin: { showLogin = true }
                )
            }
        }
    }
}

//
//  AppDelegate.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Инициализация Firebase
        FirebaseApp.configure()
        
        // Настройки Firestore
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true // Включаем офлайн кэширование
        Firestore.firestore().settings = settings
        
        return true
    }
}

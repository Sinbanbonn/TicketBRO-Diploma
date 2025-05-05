//
//  FirebaseAuthService.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine

class FirebaseAuthService {
    private let auth = Auth.auth()
    
    // Текущий пользователь (если вошел в систему)
    var currentUser: User? {
        if let firebaseUser = auth.currentUser {
            return User(id: firebaseUser.uid, email: firebaseUser.email ?? "", name: firebaseUser.displayName ?? "")
        }
        return nil
    }
    
    // Проверка аутентификации пользователя
    var isUserAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    // Регистрация нового пользователя
    func register(email: String, password: String, name: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            self?.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    promise(.failure(NSError(domain: "FirebaseAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать пользователя"])))
                    return
                }
                
                // Создаем профиль пользователя
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = name
                
                changeRequest.commitChanges { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    // Создаем нового пользователя в Firestore
                    let newUser = User(
                        id: firebaseUser.uid,
                        email: email,
                        name: name,
                        phoneNumber: nil,
                        avatar: nil
                    )
                    
                    let db = Firestore.firestore()
                    do {
                        // Используем ID пользователя из Firebase Auth как ID документа
                        try db.collection("users").document(firebaseUser.uid).setData(from: newUser)
                        promise(.success(newUser))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Вход пользователя в систему
    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            self?.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    promise(.failure(NSError(domain: "FirebaseAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось войти в систему"])))
                    return
                }
                
                // Получаем данные пользователя из Firestore
                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    do {
                        if let user = try snapshot?.data(as: User.self) {
                            promise(.success(user))
                        } else {
                            // Если данных о пользователе в Firestore нет, создаем базовый профиль
                            let newUser = User(email: firebaseUser.email ?? "", name: firebaseUser.displayName ?? "Пользователь")
                            try db.collection("users").document(firebaseUser.uid).setData(from: newUser)
                            promise(.success(newUser))
                        }
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Выход пользователя из системы
    func logout() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            do {
                try self?.auth.signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Сброс пароля пользователя
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.auth.sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

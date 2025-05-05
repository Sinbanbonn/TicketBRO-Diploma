//
//  FirestoreService.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Core/Services/Firebase/FirestoreService.swift
import Foundation
import Firebase
import FirebaseFirestore
import Combine

// Базовый сервис для работы с Firestore
class FirestoreService<T: Codable & Identifiable> {
    private let db = Firestore.firestore()
    private let collectionPath: String
    
    init(collectionPath: String) {
        self.collectionPath = collectionPath
    }
    
    // Получение всех документов коллекции
    func getAll() -> AnyPublisher<[T], Error> {
        print("📡 Запрос всех документов из коллекции \(collectionPath)")
        
        return Future<[T], Error> { [weak self] promise in
            guard let self = self else {
                print("❌ Сервис недоступен")
                promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            self.db.collection(self.collectionPath).getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Ошибка при получении документов из коллекции \(self.collectionPath): \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ Коллекция \(self.collectionPath) пуста или не существует")
                    promise(.success([]))
                    return
                }
                
                print("✅ Получено \(documents.count) документов из коллекции \(self.collectionPath)")
                
                do {
                    let items: [T] = try documents.compactMap { document in
                        return try document.data(as: T.self)
                    }
                    
                    print("✅ Декодировано \(items.count) объектов из \(documents.count) документов")
                    if items.count < documents.count {
                        print("⚠️ Некоторые документы не удалось декодировать")
                    }
                    
                    promise(.success(items))
                } catch {
                    print("❌ Ошибка при декодировании данных: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Получение документа по ID
    func getById(id: String) -> AnyPublisher<T?, Error> {
        return Future<T?, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            self.db.collection(self.collectionPath).document(id).getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    promise(.success(nil))
                    return
                }
                
                do {
                    let item = try snapshot.data(as: T.self)
                    promise(.success(item))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Добавление нового документа
    func add(item: T) -> AnyPublisher<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            do {
                let reference = try self.db.collection(self.collectionPath).addDocument(from: item)
                
                // Получаем созданный документ, чтобы вернуть актуальные данные
                reference.getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    do {
                        if let createdItem = try snapshot?.data(as: T.self) {
                            promise(.success(createdItem))
                        } else {
                            promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить созданный документ"])))
                        }
                    } catch {
                        promise(.failure(error))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Обновление существующего документа
    func update(id: String, item: T) -> AnyPublisher<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            do {
                try self.db.collection(self.collectionPath).document(id).setData(from: item)
                
                // Получаем обновленный документ, чтобы вернуть актуальные данные
                self.db.collection(self.collectionPath).document(id).getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    do {
                        if let updatedItem = try snapshot?.data(as: T.self) {
                            promise(.success(updatedItem))
                        } else {
                            promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить обновленный документ"])))
                        }
                    } catch {
                        promise(.failure(error))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Удаление документа по ID
    func delete(id: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            self.db.collection(self.collectionPath).document(id).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Получение документов с фильтрацией по полю
    func query(field: String, isEqualTo value: Any) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            self.db.collection(self.collectionPath)
                .whereField(field, isEqualTo: value)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    do {
                        let items: [T] = try documents.compactMap { document in
                            try document.data(as: T.self)
                        }
                        promise(.success(items))
                    } catch {
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    // Наблюдение за изменениями в коллекции
    func observeCollection() -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()
        
        let listener = db.collection(collectionPath).addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                subject.send([])
                return
            }
            
            do {
                let items: [T] = try documents.compactMap { document in
                    try document.data(as: T.self)
                }
                subject.send(items)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        
        // Сохраняем слушатель, чтобы предотвратить его уничтожение
        return subject
            .handleEvents(receiveCancel: {
                listener.remove() // Отписываемся при отмене подписки
            })
            .eraseToAnyPublisher()
    }
    
    // Наблюдение за изменениями в документе
    func observeDocument(id: String) -> AnyPublisher<T?, Error> {
        let subject = PassthroughSubject<T?, Error>()
        
        let listener = db.collection(collectionPath).document(id).addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                subject.send(nil)
                return
            }
            
            do {
                let item = try snapshot.data(as: T.self)
                subject.send(item)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        
        // Сохраняем слушатель, чтобы предотвратить его уничтожение
        return subject
            .handleEvents(receiveCancel: {
                listener.remove() // Отписываемся при отмене подписки
            })
            .eraseToAnyPublisher()
    }
}

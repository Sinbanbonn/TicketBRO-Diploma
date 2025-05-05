//
//  StorageService.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Core/Services/Firebase/StorageService.swift
import Foundation
import Firebase
import FirebaseStorage
import Combine
import UIKit

class StorageService {
    private let storage = Storage.storage()
    
    // Загрузка изображения в Firebase Storage
    func uploadImage(image: UIImage, path: String) -> AnyPublisher<URL, Error> {
        return Future<URL, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            // Создаем уникальное имя файла
            let filename = UUID().uuidString
            let storageRef = self.storage.reference().child("\(path)/\(filename).jpg")
            
            // Преобразуем изображение в данные
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось преобразовать изображение в данные"])))
                return
            }
            
            // Загружаем изображение
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                // Получаем URL загруженного изображения
                storageRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let downloadURL = url else {
                        promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить URL изображения"])))
                        return
                    }
                    
                    promise(.success(downloadURL))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Удаление изображения из Firebase Storage
    func deleteImage(url: URL) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервис недоступен"])))
                return
            }
            
            // Получаем ссылку на изображение в Storage
            let storageRef = self.storage.reference(forURL: url.absoluteString)
            
            // Удаляем изображение
            storageRef.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

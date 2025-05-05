//
//  Image + Extension.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//

import SwiftUI
import Combine

extension Image {
    static func fromFirebase(_ urlString: String, placeholder: Image = Image(systemName: "photo")) -> some View {
        Group {
            if urlString.contains("http") {
                // Это URL-ссылка
                AsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            } else {
                // Это имя системного изображения
                Image(systemName: urlString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

// Добавляем новую подписку в EventBus
extension EventBus {
    // Подписка на событие переключения на вкладку "Билеты"
    func subscribeToTabSwitch() -> AnyPublisher<Void, Never> {
        return subscribe { event -> Void? in
            if case .switchToTicketsTab = event {
                return ()
            }
            return nil
        }
    }
}

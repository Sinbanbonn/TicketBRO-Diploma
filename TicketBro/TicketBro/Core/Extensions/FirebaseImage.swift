// FirebaseImage.swift
import SwiftUI

// Вспомогательный компонент для отображения изображений
struct FirebaseImage: View {
    let urlString: String
    let placeholder: String
    let width: CGFloat
    let height: CGFloat
    
    init(urlString: String, placeholder: String = "photo", width: CGFloat = 100, height: CGFloat = 100) {
        self.urlString = urlString
        self.placeholder = placeholder
        self.width = width
        self.height = height
    }
    
    var body: some View {
        Group {
            if urlString.hasPrefix("http") {
                // Это URL-ссылка на изображение
                AsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: height)
                            .clipped()
                    case .failure:
                        Image(systemName: placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)
                    @unknown default:
                        Image(systemName: placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)
                    }
                }
            } else if let uiImage = UIImage(named: urlString) {
                // Это имя ассета в Assets.xcassets
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                // Предполагаем, что это имя системного изображения
                Image(systemName: urlString.isEmpty ? placeholder : urlString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            }
        }
    }
}

import Foundation
import FirebaseFirestore
import CoreLocation

struct Cinema: Identifiable, Codable {
    @DocumentID var id: String? // ID кинотеатра в Firebase
    var name: String
    var address: String
    var description: String
    var photoURLs: [String] // URL изображений кинотеатра
    var location: GeoPoint // Координаты для отображения на карте
    var rating: Double // Рейтинг кинотеатра (от 0 до 5)
    var halls: [Hall] // Залы кинотеатра
    var amenities: [String] // Удобства (паркинг, кафе, и т.д.)
    var contactPhone: String
    var contactEmail: String
    var workingHours: WorkingHours
    
    // Геоточка для Firebase
    struct GeoPoint: Codable {
        var latitude: Double
        var longitude: Double
    }
    
    // Рабочие часы кинотеатра
    struct WorkingHours: Codable {
        var monday: DailyHours
        var tuesday: DailyHours
        var wednesday: DailyHours
        var thursday: DailyHours
        var friday: DailyHours
        var saturday: DailyHours
        var sunday: DailyHours
        
        // Инициализатор для создания объекта программно
        init(monday: DailyHours, tuesday: DailyHours, wednesday: DailyHours,
             thursday: DailyHours, friday: DailyHours, saturday: DailyHours,
             sunday: DailyHours) {
            
            self.monday = monday
            self.tuesday = tuesday
            self.wednesday = wednesday
            self.thursday = thursday
            self.friday = friday
            self.saturday = saturday
            self.sunday = sunday
        }
    }
    
    struct DailyHours: Codable {
        var open: String // Время открытия в формате "HH:mm"
        var close: String // Время закрытия в формате "HH:mm"
        
        // Инициализатор для создания объекта программно
        init(open: String, close: String) {
            self.open = open
            self.close = close
        }
    }
    
    // Основной инициализатор
    init(id: String? = nil,
         name: String = "",
         address: String = "",
         description: String = "",
         photoURLs: [String] = [],
         location: GeoPoint = GeoPoint(latitude: 0, longitude: 0),
         rating: Double = 0,
         halls: [Hall] = [],
         amenities: [String] = [],
         contactPhone: String = "",
         contactEmail: String = "",
         workingHours: WorkingHours? = nil) {
        
        self.id = id
        self.name = name
        self.address = address
        self.description = description
        self.photoURLs = photoURLs
        self.location = location
        self.rating = rating
        self.halls = halls
        self.amenities = amenities
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        
        // Если workingHours не указано, создаем дефолтный объект
        if let workingHours = workingHours {
            self.workingHours = workingHours
        } else {
            self.workingHours = WorkingHours(
                monday: DailyHours(open: "09:00", close: "21:00"),
                tuesday: DailyHours(open: "09:00", close: "21:00"),
                wednesday: DailyHours(open: "09:00", close: "21:00"),
                thursday: DailyHours(open: "09:00", close: "21:00"),
                friday: DailyHours(open: "09:00", close: "21:00"),
                saturday: DailyHours(open: "09:00", close: "21:00"),
                sunday: DailyHours(open: "09:00", close: "21:00")
            )
        }
    }
}

// Расширение для получения UIImage из имени ассета или системного изображения
extension Cinema {
    // Получает UIImage из URL, имени ассета или системного изображения
    func getPhoto(index: Int) -> UIImage? {
        guard index < photoURLs.count else { return nil }
        
        let photoURL = photoURLs[index]
        
        // Проверяем, является ли это URL
        if photoURL.hasPrefix("http") {
            // Здесь нужен код для загрузки изображения по URL
            // В данном случае возвращаем nil, так как это асинхронная операция
            return nil
        } else if let image = UIImage(named: photoURL) {
            // Это имя ассета
            return image
        } else {
            // Предполагаем, что это имя системного изображения
            return UIImage(systemName: photoURL)
        }
    }
}

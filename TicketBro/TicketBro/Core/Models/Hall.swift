import Foundation
import FirebaseFirestore

struct Hall: Identifiable, Codable {
    var id: String? // ID зала в Firebase
    var name: String // Название зала
    var capacity: Int // Общее количество мест
    var hallType: HallType // Тип зала
    var features: [HallFeature] // Особенности зала
    
    // Тип зала
    enum HallType: String, Codable {
        case standard = "standard"
        case vip = "vip"
        case imax = "imax"
        case dolbyAtmos = "dolby_atmos"
        case screenX = "screen_x"
        
        // Добавим обработку неизвестных типов
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            switch rawValue {
            case "standard": self = .standard
            case "vip": self = .vip
            case "imax": self = .imax
            case "dolby_atmos": self = .dolbyAtmos
            case "screen_x": self = .screenX
            default: self = .standard // Используем стандартный зал как значение по умолчанию
            }
        }
    }
    
    // Особенности зала
    enum HallFeature: String, Codable {
        case _3D = "3d"
        case _4DX = "4dx"
        case comfortSeats = "comfort_seats"
        case loveSeats = "love_seats"
        case recliners = "recliners"
        
        // Добавим обработку неизвестных особенностей
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            switch rawValue {
            case "3d": self = ._3D
            case "4dx": self = ._4DX
            case "comfort_seats": self = .comfortSeats
            case "love_seats": self = .loveSeats
            case "recliners": self = .recliners
            default: self = .comfortSeats // Используем удобные кресла как значение по умолчанию
            }
        }
    }
    
    // Инициализатор для декодирования из Firestore
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.capacity = try container.decode(Int.self, forKey: .capacity)
        
        // Декодирование типа зала
        if let hallTypeString = try container.decodeIfPresent(String.self, forKey: .hallType) {
            self.hallType = HallType(rawValue: hallTypeString) ?? .standard
        } else {
            self.hallType = .standard
        }
        
        // Декодирование особенностей зала
        if let featuresStrings = try container.decodeIfPresent([String].self, forKey: .features) {
            self.features = featuresStrings.compactMap { HallFeature(rawValue: $0) }
        } else {
            self.features = []
        }
    }
    
    // CodingKeys для соответствия данным в Firestore
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case capacity
        case hallType
        case features
    }
    
    // Инициализатор для создания объекта программно
    init(id: String? = nil, name: String, capacity: Int, hallType: HallType, features: [HallFeature]) {
        self.id = id
        self.name = name
        self.capacity = capacity
        self.hallType = hallType
        self.features = features
    }
}

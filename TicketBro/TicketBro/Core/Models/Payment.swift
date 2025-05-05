//
//  Payment.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// Models/Payment.swift
import Foundation
import FirebaseFirestore

struct Payment: Identifiable, Codable {
    @DocumentID var id: String? // ID платежа в Firebase
    var ticketId: String // ID билета
    var userId: String // ID пользователя
    var amount: Double // Сумма платежа
    var currency: String = "RUB" // Валюта платежа
    var paymentMethod: PaymentMethod // Метод оплаты
    var paymentDate: Date // Дата и время оплаты
    var transactionId: String // ID транзакции от платежной системы
    var status: PaymentStatus // Статус платежа
    
    enum PaymentMethod: String, Codable {
        case creditCard = "credit_card"
        case applePay = "apple_pay"
        case payPal = "pay_pal"
        case googlePay = "google_pay"
        case bankTransfer = "bank_transfer"
    }
    
    enum PaymentStatus: String, Codable {
        case pending = "pending"
        case completed = "completed"
        case failed = "failed"
        case refunded = "refunded"
    }
}

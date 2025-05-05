//
//  FormField.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// UI/Components/FormField.swift
import SwiftUI

// Компонент для полей формы с валидацией
struct FormField<Input: View, Validation: View>: View {
    let label: String
    let input: Input
    let validation: Validation
    
    init(label: String, @ViewBuilder input: () -> Input, @ViewBuilder validation: () -> Validation) {
        self.label = label
        self.input = input()
        self.validation = validation()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
            
            input
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            validation
        }
    }
}

// Предварительно заданные валидаторы
struct Validators {
    // Проверка на пустую строку
    static func notEmpty(_ text: String) -> Bool {
        !text.isEmpty
    }
    
    // Проверка на валидный email
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Проверка на минимальную длину
    static func minLength(_ text: String, _ length: Int) -> Bool {
        text.count >= length
    }
    
    // Проверка на равенство строк
    static func isEqual(_ text1: String, _ text2: String) -> Bool {
        text1 == text2
    }
}
//
//  TicketQRCodeView.swift
//  TicketBro
//
//  Created by Admin Bookie on 5.05.25.
//


// TicketQRCodeView.swift
import SwiftUI
import CoreImage.CIFilterBuiltins

struct TicketQRCodeView: View {
    let ticket: Ticket
    @Environment(\.presentationMode) private var presentationMode
    
    // Генерация QR-кода
    private var qrCode: UIImage {
        let data = "\(ticket.id ?? "")|\(ticket.movieId)|\(ticket.cinemaId)|\(ticket.hallId)|\(ticket.row)|\(ticket.seat)"
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(data.utf8)
        filter.correctionLevel = "H" // Высокий уровень коррекции ошибок
        
        if let outputImage = filter.outputImage {
            let scale = UIScreen.main.scale
            let transform = CGAffineTransform(scaleX: 10 * scale, y: 10 * scale)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
    
    // Форматтеры для дат
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("QR-код билета")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Покажите этот код при входе в кинозал")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // QR-код
            Image(uiImage: qrCode)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
            
            VStack(spacing: 4) {
                Text(ticket.movieTitle)
                    .font(.headline)
                
                Text("\(ticket.cinemaName), Зал \(ticket.hallName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(dateFormatter.string(from: ticket.sessionDate)), \(timeFormatter.string(from: ticket.sessionDate))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Ряд \(ticket.row), Место \(ticket.seat)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
            
            Button("Закрыть") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
        }
        .padding()
    }
}
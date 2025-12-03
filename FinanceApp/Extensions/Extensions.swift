// Extensions.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Extensões úteis para o projeto

import SwiftUI

// MARK: - Double Extensions
extension Double {
    /// Formata o valor como moeda brasileira (R$)
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }
    
    /// Formata com duas casas decimais
    var twoDecimalPlaces: String {
        String(format: "%.2f", self)
    }
}

// MARK: - String Extensions
extension String {
    /// Converte string para Double, tratando vírgula como separador decimal
    var toDouble: Double? {
        Double(self.replacingOccurrences(of: ",", with: "."))
    }
    
    /// Remove espaços em branco do início e fim
    var trimmed: String {
        trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Color Extensions
extension Color {
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
}

// MARK: - View Extensions
extension View {
    /// Aplica estilo de card
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    /// Esconde o teclado
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Date Extensions
extension Date {
    var currentMonth: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var currentYear: Int {
        Calendar.current.component(.year, from: self)
    }
}

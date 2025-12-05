//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// Extensions.swift
// Extensões úteis para o projeto

import SwiftUI

// MARK: - Double Extensions
extension Double {
    /// Formata o valor como moeda brasileira (R$)
    var currencyFormatted: String {
        Self.currencyFormatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }
    
    /// Formata com duas casas decimais
    var twoDecimalPlaces: String {
        String(format: "%.2f", self)
    }
    
    /// Formata para edição (sem R$, com separadores)
    var formattedForEditing: String {
        Self.editingFormatter.string(from: NSNumber(value: self)) ?? "0,00"
    }
    
    /// Formato curto para valores grandes
    var currencyFormattedShort: String {
        if self >= 1000 {
            Self.shortCurrencyFormatter.string(from: NSNumber(value: self)) ?? "R$ 0"
        } else {
            currencyFormatted
        }
    }
    
    // MARK: - Static Formatters (reutilizáveis para performance)
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
    
    private static let editingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }()
    
    private static let shortCurrencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

// MARK: - String Extensions
extension String {
    /// Converte string para Double, tratando vírgula como separador decimal
    var toDouble: Double? {
        let cleaned = self
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        
        return Double(cleaned)
    }
    
    /// Remove espaços em branco do início e fim
    var trimmed: String {
        trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - View Extensions
extension View {
    /// Esconde o teclado
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
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

// MARK: - Currency Input Helper
struct CurrencyInputHelper {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }()
    
    /// Formata input de moeda enquanto digita
    static func format(_ input: String) -> String {
        let numbers = input.filter { $0.isNumber }
        
        guard !numbers.isEmpty,
              let cents = Int(numbers),
              cents > 0 else {
            return ""
        }
        
        let value = Double(cents) / 100.0
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    /// Parse de string formatada para Double
    static func parse(_ text: String) -> Double? {
        text.toDouble
    }
}

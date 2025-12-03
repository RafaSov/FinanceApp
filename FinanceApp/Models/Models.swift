// Models.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Modelos de dados da aplicação

import SwiftUI

// MARK: - Categoria de Despesa
enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case lazer = "Lazer"
    case transporte = "Transporte"
    case educacao = "Educação"
    case investimento = "Investimento"
    case alimentacao = "Alimentação"
    case saude = "Saúde"
    case moradia = "Moradia"
    case governo = "Governo"
    case empresa = "Empresa"
    case outros = "Outros"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .lazer: return .purple
        case .transporte: return .blue
        case .educacao: return .orange
        case .investimento: return .green
        case .alimentacao: return .red
        case .saude: return .pink
        case .moradia: return .brown
        case .governo: return .yellow
        case .empresa: return .indigo
        case .outros: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .lazer: return "gamecontroller"
        case .transporte: return "car"
        case .educacao: return "book"
        case .investimento: return "chart.line.uptrend.xyaxis"
        case .alimentacao: return "fork.knife"
        case .saude: return "heart"
        case .moradia: return "house"
        case .governo: return "flag"
        case .empresa: return "briefcase"
        case .outros: return "ellipsis.circle"
        }
    }
}

// MARK: - Status de Pagamento
enum PaymentStatus: String, CaseIterable, Codable {
    case pago = "Pago"
    case atrasado = "Atrasado"
    case pendente = "Pendente"
    
    var color: Color {
        switch self {
        case .pago: return .green
        case .atrasado: return .red
        case .pendente: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .pago: return "checkmark.circle.fill"
        case .atrasado: return "exclamationmark.circle.fill"
        case .pendente: return "clock.fill"
        }
    }
}

// MARK: - Despesa/Conta
struct Expense: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var value: Double
    var category: ExpenseCategory
    var status: PaymentStatus
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Dados do Mês
struct MonthData: Identifiable, Codable {
    var id = UUID()
    var month: Int // 1-12
    var year: Int
    var income: Double
    var expenses: [Expense]
    
    // Propriedades calculadas
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.value }
    }
    
    var balance: Double {
        income - totalExpenses
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.monthSymbols[month - 1].capitalized
    }
    
    // Ano formatado como texto (sem separador de milhar)
    var yearFormatted: String {
        String(year)
    }
    
    // Título completo do mês
    var fullTitle: String {
        "\(monthName) \(String(year))"
    }
    
    // Agrupamento por categoria
    var expensesByCategory: [(category: ExpenseCategory, total: Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        for expense in expenses {
            totals[expense.category, default: 0] += expense.value
        }
        return totals.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }
}

// MARK: - Dados do Ano
struct YearData: Identifiable, Codable {
    var id = UUID()
    var year: Int
    var months: [MonthData]
    
    // Ano formatado como texto
    var yearFormatted: String {
        String(year)
    }
    
    var totalIncome: Double {
        months.reduce(0) { $0 + $1.income }
    }
    
    var totalExpenses: Double {
        months.reduce(0) { $0 + $1.totalExpenses }
    }
}

// MARK: - Configurações de Notificação
struct NotificationSettings: Codable {
    var isEnabled: Bool = false
    var dueDay: Int = 5
}

//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// Models.swift
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
    case empresas = "Empresas"
    case governo = "Governo"
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
        case .empresas: return .indigo
        case .governo: return .yellow
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
        case .empresas: return "briefcase"
        case .governo: return "flag"
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
struct Expense: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var value: Double
    var category: ExpenseCategory
    var status: PaymentStatus
    var dueDay: Int?
    
    init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        category: ExpenseCategory,
        status: PaymentStatus,
        dueDay: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.category = category
        self.status = status
        self.dueDay = dueDay
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Dados do Mês
struct MonthData: Identifiable, Codable {
    var id: UUID
    var month: Int
    var year: Int
    var income: Double
    var expenses: [Expense]
    
    init(
        id: UUID = UUID(),
        month: Int,
        year: Int,
        income: Double = 0,
        expenses: [Expense] = []
    ) {
        self.id = id
        self.month = month
        self.year = year
        self.income = income
        self.expenses = expenses
    }
    
    // MARK: - Computed Properties
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.value }
    }
    
    var balance: Double {
        income - totalExpenses
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        guard month >= 1, month <= 12 else { return "" }
        return formatter.monthSymbols[month - 1].capitalized
    }
    
    var yearFormatted: String {
        String(year)
    }
    
    var fullTitle: String {
        "\(monthName) \(yearFormatted)"
    }
    
    var expensesByCategory: [CategoryTotal] {
        Dictionary(grouping: expenses, by: \.category)
            .mapValues { $0.reduce(0) { $0 + $1.value } }
            .map { CategoryTotal(category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }
}

// MARK: - Dados do Ano
struct YearData: Identifiable, Codable {
    var id: UUID
    var year: Int
    var months: [MonthData]
    
    init(id: UUID = UUID(), year: Int, months: [MonthData] = []) {
        self.id = id
        self.year = year
        self.months = months
    }
    
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
    var isEnabled: Bool
    
    init(isEnabled: Bool = false) {
        self.isEnabled = isEnabled
    }
}

// MARK: - Category Total (para gráficos)
struct CategoryTotal: Identifiable {
    let category: ExpenseCategory
    let total: Double
    
    var id: String { category.id }
}

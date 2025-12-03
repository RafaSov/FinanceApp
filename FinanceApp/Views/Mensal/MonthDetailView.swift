// MonthDetailView.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Tela de detalhes do mês

import SwiftUI

struct MonthDetailView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    
    let year: Int
    let month: Int
    
    @State private var showingAddExpense = false
    @State private var showingEditIncome = false
    @State private var showingCopyAlert = false
    @State private var editingExpense: Expense?
    @State private var refreshID = UUID() // Força atualização da view
    
    // Verifica se o mês anterior tem contas
    private var hasPreviousMonthExpenses: Bool {
        previousMonthData?.expenses.isEmpty == false
    }
    
    // Dados do mês anterior
    private var previousMonthData: MonthData? {
        var prevMonth = month - 1
        var prevYear = year
        
        if prevMonth < 1 {
            prevMonth = 12
            prevYear -= 1
        }
        
        return viewModel.getMonthData(year: prevYear, month: prevMonth)
    }
    
    // Nome do mês anterior
    private var previousMonthName: String {
        previousMonthData?.monthName ?? "anterior"
    }
    
    // Dados do mês atual - sempre busca do viewModel
    private var monthData: MonthData? {
        viewModel.getMonthData(year: year, month: month)
    }
    
    var body: some View {
        Group {
            if let data = monthData {
                List {
                    // Seção de Resumo
                    Section("Resumo do Mês") {
                        // Entrada
                        HStack {
                            Label("Entrada", systemImage: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Button {
                                showingEditIncome = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text(data.income.currencyFormatted)
                                        .foregroundColor(.green)
                                        .fontWeight(.medium)
                                    
                                    Image(systemName: "pencil.circle")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Gastos
                        HStack {
                            Label("Gastos", systemImage: "arrow.up.circle.fill")
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Text(data.totalExpenses.currencyFormatted)
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                        }
                        
                        // Saldo
                        HStack {
                            Label("Saldo", systemImage: data.balance >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(data.balance >= 0 ? .blue : .orange)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(data.balance.currencyFormatted)
                                .foregroundColor(data.balance >= 0 ? .blue : .orange)
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Seção de Contas
                    Section {
                        if data.expenses.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Nenhuma conta cadastrada")
                                        .foregroundColor(.secondary)
                                    
                                    // Botão de copiar quando vazio
                                    if hasPreviousMonthExpenses {
                                        Button {
                                            showingCopyAlert = true
                                        } label: {
                                            Label("Copiar do mês anterior", systemImage: "doc.on.doc")
                                                .font(.subheadline)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.blue)
                                        .padding(.top, 4)
                                    } else {
                                        Text("Toque em + para adicionar")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 20)
                                Spacer()
                            }
                        } else {
                            ForEach(data.expenses) { expense in
                                ExpenseRowView(expense: expense)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingExpense = expense
                                    }
                            }
                            .onDelete { offsets in
                                viewModel.deleteExpense(year: year, month: month, at: offsets)
                            }
                        }
                    } header: {
                        HStack(spacing: 16) {
                            Text("Contas (\(data.expenses.count))")
                            
                            Spacer()
                            
                            // Botão copiar do mês anterior
                            if hasPreviousMonthExpenses {
                                Button {
                                    showingCopyAlert = true
                                } label: {
                                    Image(systemName: "doc.on.doc.fill")
                                        .font(.body)
                                        .foregroundColor(.orange)
                                }
                                .help("Copiar contas do mês anterior")
                            }
                            
                            // Botão adicionar
                            Button {
                                showingAddExpense = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }
                    } footer: {
                        if hasPreviousMonthExpenses && !data.expenses.isEmpty {
                            Text("Toque em 📋 para copiar contas do mês anterior")
                                .font(.caption2)
                        }
                    }
                }
                .id(refreshID) // Força refresh quando ID muda
                .navigationTitle(data.fullTitle)
                .navigationBarTitleDisplayMode(.large)
            } else {
                Text("Erro ao carregar dados")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            ExpenseFormView(expense: nil) { newExpense in
                viewModel.addExpense(year: year, month: month, expense: newExpense)
                refreshID = UUID() // Força atualização
            }
        }
        .sheet(item: $editingExpense) { expense in
            ExpenseFormView(expense: expense) { updatedExpense in
                viewModel.updateExpense(year: year, month: month, expense: updatedExpense)
                refreshID = UUID() // Força atualização
                editingExpense = nil
            }
        }
        .sheet(isPresented: $showingEditIncome) {
            IncomeFormView(
                currentIncome: monthData?.income ?? 0,
                monthName: monthData?.monthName ?? "",
                year: year
            ) { newIncome in
                viewModel.updateIncome(year: year, month: month, newIncome: newIncome)
                refreshID = UUID() // Força atualização
            }
        }
        .alert("Copiar Contas", isPresented: $showingCopyAlert) {
            Button("Cancelar", role: .cancel) { }
            
            Button("Apenas Contas") {
                copyExpensesFromPreviousMonth(includeIncome: false)
            }
            
            Button("Contas + Entrada") {
                copyExpensesFromPreviousMonth(includeIncome: true)
            }
        } message: {
            if let prevData = previousMonthData {
                Text("Copiar \(prevData.expenses.count) conta(s) de \(previousMonthName)?\n\nAs contas serão copiadas com status 'Pendente'.")
            }
        }
    }
    
    // MARK: - Função para copiar contas
    private func copyExpensesFromPreviousMonth(includeIncome: Bool) {
        guard let prevData = previousMonthData else { return }
        
        // Copia cada despesa com novo ID e status Pendente
        for expense in prevData.expenses {
            let newExpense = Expense(
                id: UUID(), // Novo ID
                name: expense.name,
                value: expense.value,
                category: expense.category,
                status: .pendente // Reseta para pendente
            )
            viewModel.addExpense(year: year, month: month, expense: newExpense)
        }
        
        // Copia entrada se solicitado
        if includeIncome && prevData.income > 0 {
            viewModel.updateIncome(year: year, month: month, newIncome: prevData.income)
        }
        
        // Força atualização da view
        refreshID = UUID()
    }
}

// MARK: - Inicializador Conveniente
extension MonthDetailView {
    init(monthData: MonthData) {
        self.year = monthData.year
        self.month = monthData.month
    }
}

// MARK: - Income Form View (Novo formulário de entrada)
struct IncomeFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var valueText: String = ""
    
    let currentIncome: Double
    let monthName: String
    let year: Int
    let onSave: (Double) -> Void
    
    var parsedValue: Double? {
        parseValue(valueText)
    }
    
    var isValid: Bool {
        if let value = parsedValue {
            return value >= 0
        }
        return false
    }
    
    init(currentIncome: Double, monthName: String, year: Int, onSave: @escaping (Double) -> Void) {
        self.currentIncome = currentIncome
        self.monthName = monthName
        self.year = year
        self.onSave = onSave
        
        // Inicializa com valor atual formatado
        if currentIncome > 0 {
            _valueText = State(initialValue: Self.formatForEditing(currentIncome))
        } else {
            _valueText = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Informação do mês
                Section {
                    HStack {
                        Label("Mês", systemImage: "calendar")
                        Spacer()
                        Text("\(monthName) \(String(year))")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Campo de valor
                Section {
                    HStack(spacing: 8) {
                        Text("R$")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        TextField("0,00", text: $valueText)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .keyboardType(.decimalPad)
                            .onChange(of: valueText) { newValue in
                                valueText = formatCurrencyInput(newValue)
                            }
                    }
                    .padding(.vertical, 8)
                }
                header: {
                    Text("Valor da Entrada")
                }
                footer: {
                    Text("Digite o valor do seu salário ou renda mensal.")
                }
                
                // Preview
                if let value = parsedValue, value > 0 {
                    Section("Prévia") {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Entrada de \(monthName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(value.currencyFormatted)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.green.opacity(0.3))
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Atalhos de valores comuns
                Section("Valores Rápidos") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickValueButton(value: 1500, currentValue: parsedValue) {
                            valueText = Self.formatForEditing(1500)
                        }
                        QuickValueButton(value: 2500, currentValue: parsedValue) {
                            valueText = Self.formatForEditing(2500)
                        }
                        QuickValueButton(value: 3500, currentValue: parsedValue) {
                            valueText = Self.formatForEditing(3500)
                        }
                        QuickValueButton(value: 5000, currentValue: parsedValue) {
                            valueText = Self.formatForEditing(5000)
                        }
                        QuickValueButton(value: 7500, currentValue: parsedValue) {
                            valueText = Self.formatForEditing(7500)
                        }
                        QuickValueButton(value: 10000, currentValue: parsedValue) {
                            valueText = Self.formatForEditing(10000)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Editar Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if let value = parsedValue {
                            onSave(value)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("OK") {
                            hideKeyboard()
                        }
                    }
                }
            }
        }
    }
    
    // Formata entrada de moeda enquanto digita
    private func formatCurrencyInput(_ input: String) -> String {
        let numbers = input.filter { $0.isNumber }
        guard let cents = Int(numbers), cents > 0 else { return "" }
        let value = Double(cents) / 100.0
        return String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }
    
    // Parse do valor
    private func parseValue(_ text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        
        if cleaned.isEmpty { return 0 }
        return Double(cleaned)
    }
    
    // Formata valor para edição
    static func formatForEditing(_ value: Double) -> String {
        return String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Quick Value Button
struct QuickValueButton: View {
    let value: Double
    let currentValue: Double?
    let action: () -> Void
    
    var isSelected: Bool {
        guard let current = currentValue else { return false }
        return abs(current - value) < 0.01
    }
    
    var body: some View {
        Button(action: action) {
            Text(value.currencyFormattedShort)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.green : Color.green.opacity(0.1))
                .foregroundColor(isSelected ? .white : .green)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Extension para formato curto
extension Double {
    var currencyFormattedShort: String {
        if self >= 1000 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_BR")
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: self)) ?? "R$ 0"
        } else {
            return currencyFormatted
        }
    }
}

#Preview {
    NavigationStack {
        MonthDetailView(year: 2025, month: 1)
            .environmentObject(FinanceViewModel())
    }
}

#Preview("Income Form") {
    IncomeFormView(currentIncome: 5000, monthName: "Janeiro", year: 2025) { _ in }
}


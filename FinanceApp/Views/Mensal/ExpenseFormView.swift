// ExpenseFormView.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Formulário para adicionar/editar despesas

import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Campos do formulário
    @State private var name: String
    @State private var valueText: String
    @State private var category: ExpenseCategory
    @State private var status: PaymentStatus
    
    let existingExpense: Expense?
    let onSave: (Expense) -> Void
    
    var isEditing: Bool { existingExpense != nil }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && parseValue(valueText) != nil
    }
    
    init(expense: Expense?, onSave: @escaping (Expense) -> Void) {
        self.existingExpense = expense
        self.onSave = onSave
        
        // Inicializa os estados diretamente no init
        if let expense = expense {
            _name = State(initialValue: expense.name)
            _valueText = State(initialValue: Self.formatForEditing(expense.value))
            _category = State(initialValue: expense.category)
            _status = State(initialValue: expense.status)
        } else {
            _name = State(initialValue: "")
            _valueText = State(initialValue: "")
            _category = State(initialValue: .outros)
            _status = State(initialValue: .pendente)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Informações básicas
                Section("Informações da Conta") {
                    TextField("Nome da conta", text: $name)
                        .textInputAutocapitalization(.sentences)
                    
                    HStack {
                        Text("R$")
                            .foregroundColor(.secondary)
                        
                        TextField("0,00", text: $valueText)
                            .keyboardType(.decimalPad)
                            .onChange(of: valueText) { newValue in
                                valueText = formatCurrencyInput(newValue)
                            }
                    }
                }
                
                // Categoria
                Section("Categoria") {
                    Picker("Categoria", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Status
                Section("Status de Pagamento") {
                    Picker("Status", selection: $status) {
                        ForEach(PaymentStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Preview
                if isValid, let value = parseValue(valueText) {
                    Section("Prévia") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(name)
                                    .font(.headline)
                                Spacer()
                                Text(value.currencyFormatted)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Label(category.rawValue, systemImage: category.icon)
                                    .font(.caption)
                                    .foregroundColor(category.color)
                                
                                Spacer()
                                
                                Text(status.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(status.color.opacity(0.15))
                                    .foregroundColor(status.color)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Editar Conta" : "Nova Conta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let value = parseValue(valueText) else { return }
        
        let expense = Expense(
            id: existingExpense?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            value: value,
            category: category,
            status: status
        )
        
        onSave(expense)
        dismiss()
    }
    
    // Formata entrada de moeda enquanto digita
    private func formatCurrencyInput(_ input: String) -> String {
        // Remove tudo exceto números
        let numbers = input.filter { $0.isNumber }
        
        // Converte para centavos
        guard let cents = Int(numbers) else { return "" }
        
        // Formata como moeda (divide por 100)
        let value = Double(cents) / 100.0
        
        // Formata com vírgula
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
        
        guard let value = Double(cleaned), value > 0 else { return nil }
        return value
    }
    
    // Formata valor para edição
    static func formatForEditing(_ value: Double) -> String {
        return String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }
}

#Preview {
    ExpenseFormView(expense: nil) { _ in }
}

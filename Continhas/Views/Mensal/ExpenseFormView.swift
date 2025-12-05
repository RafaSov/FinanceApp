//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// ExpenseFormView.swift
// Formulário para adicionar/editar despesas

import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Campos do formulário
    @State private var name: String
    @State private var valueText: String
    @State private var category: ExpenseCategory
    @State private var status: PaymentStatus
    @State private var hasDueDate: Bool
    @State private var dueDay: Int
    
    private let existingExpense: Expense?
    private let onSave: (Expense) -> Void
    
    var isEditing: Bool { existingExpense != nil }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && parseValue(valueText) != nil
    }
    
    init(expense: Expense?, onSave: @escaping (Expense) -> Void) {
        self.existingExpense = expense
        self.onSave = onSave
        
        // Inicializa os estados
        _name = State(initialValue: expense?.name ?? "")
        _valueText = State(initialValue: expense != nil ? expense!.value.formattedForEditing : "")
        _category = State(initialValue: expense?.category ?? .outros)
        _status = State(initialValue: expense?.status ?? .pendente)
        _hasDueDate = State(initialValue: expense?.dueDay != nil)
        _dueDay = State(initialValue: expense?.dueDay ?? 1)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Informações básicas
                Section("Informações da Conta") {
                    TextField("Nome da conta", text: $name)
                        .textInputAutocapitalization(.sentences)
                    
                    HStack(spacing: 8) {
                        Text("R$")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        TextField("0,00", text: $valueText)
                            .keyboardType(.numberPad)
                            .onChange(of: valueText) { oldValue, newValue in
                                let formatted = CurrencyInputHelper.format(newValue)
                                if formatted != valueText {
                                    valueText = formatted
                                }
                            }
                    }
                }
                
                // Vencimento
                Section("Vencimento") {
                    Toggle(isOn: $hasDueDate) {
                        Label("Definir dia de vencimento", systemImage: "calendar.badge.clock")
                    }
                    
                    if hasDueDate {
                        Picker("Dia do vencimento", selection: $dueDay) {
                            ForEach(1...31, id: \.self) { day in
                                Text("Dia \(day)").tag(day)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.orange)
                            Text("Você receberá uma notificação no dia do vencimento")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                                
                                if hasDueDate {
                                    Label("Dia \(dueDay)", systemImage: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                
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
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("OK") {
                            hideKeyboard()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func saveExpense() {
        guard let value = parseValue(valueText) else { return }
        
        let expense = Expense(
            id: existingExpense?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            value: value,
            category: category,
            status: status,
            dueDay: hasDueDate ? dueDay : nil
        )
        
        onSave(expense)
        dismiss()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func parseValue(_ text: String) -> Double? {
        guard let value = CurrencyInputHelper.parse(text), value > 0 else {
            return nil
        }
        return value
    }
}

#Preview {
    ExpenseFormView(expense: nil) { _ in }
}

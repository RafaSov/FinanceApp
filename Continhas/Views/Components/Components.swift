//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// Components.swift
// Componentes reutilizáveis da UI

import SwiftUI

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String?
    
    init(title: String, value: Double, color: Color, icon: String? = nil) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value.currencyFormatted)
                .font(.system(.callout, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value.currencyFormatted)")
    }
}

// MARK: - Expense Row
struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(expense.name)
                    .font(.headline)
                
                Spacer()
                
                Text(expense.value.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            HStack {
                // Categoria
                Label(expense.category.rawValue, systemImage: expense.category.icon)
                    .font(.caption)
                    .foregroundColor(expense.category.color)
                
                Spacer()
                
                // Vencimento
                if let dueDay = expense.dueDay {
                    Label("Dia \(dueDay)", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.trailing, 8)
                }
                
                // Status
                StatusBadge(status: expense.status)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var accessibilityDescription: String {
        var description = "\(expense.name), \(expense.value.currencyFormatted), \(expense.category.rawValue), \(expense.status.rawValue)"
        if let dueDay = expense.dueDay {
            description += ", vence dia \(dueDay)"
        }
        return description
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: PaymentStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.15))
        .foregroundColor(status.color)
        .cornerRadius(6)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        icon: String,
        title: String,
        message: String,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Category Legend
struct CategoryLegendView: View {
    let categories: [CategoryTotal]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(categories) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.category.color)
                        .frame(width: 12, height: 12)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(item.total.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
    }
}

// MARK: - Share Sheet (UIKit Bridge)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Configurações para iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.permittedArrowDirections = []
            popover.sourceRect = CGRect(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY,
                width: 0,
                height: 0
            )
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    
    init(message: String = "Carregando...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

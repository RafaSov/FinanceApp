// Components.swift
// Created by Rafael Souza Dutra on 02/12/25.
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
                
                // Status
                HStack(spacing: 4) {
                    Image(systemName: expense.status.icon)
                        .font(.caption2)
                    Text(expense.status.rawValue)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(expense.status.color.opacity(0.15))
                .foregroundColor(expense.status.color)
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
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
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Category Legend
struct CategoryLegendView: View {
    let categories: [(category: ExpenseCategory, total: Double)]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(categories, id: \.category) { item in
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
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Carregando...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


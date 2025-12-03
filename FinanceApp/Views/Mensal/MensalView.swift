// MensalView.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Tela com lista de anos e meses

import SwiftUI

struct MensalView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.sortedYears) { yearData in
                    Section {
                        DisclosureGroup {
                            ForEach(yearData.months) { month in
                                NavigationLink {
                                    MonthDetailView(monthData: month)
                                } label: {
                                    MonthRowView(month: month)
                                }
                            }
                        } label: {
                            YearHeaderView(year: yearData)
                        }
                    }
                }
            }
            .navigationTitle("Mensal")
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Year Header
struct YearHeaderView: View {
    let year: YearData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(String(year.year))
                .font(.headline)
            
            Spacer()
            
            if year.totalExpenses > 0 {
                Text(year.totalExpenses.currencyFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Month Row
struct MonthRowView: View {
    let month: MonthData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(month.monthName)
                    .font(.body)
                
                if month.expenses.count > 0 {
                    Text("\(month.expenses.count) conta(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if month.totalExpenses > 0 {
                    Text(month.totalExpenses.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                
                if month.balance != 0 && month.income > 0 {
                    Text(month.balance.currencyFormatted)
                        .font(.caption)
                        .foregroundColor(month.balance >= 0 ? .green : .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MensalView()
        .environmentObject(FinanceViewModel())
}

//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// ResumoView.swift

import SwiftUI

struct ResumoView: View {
    @EnvironmentObject var viewModel: ContinhasViewModel
    
    private var currentMonth: MonthData? {
        viewModel.currentMonthData
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let month = currentMonth {
                        // Header do mês
                        MonthHeaderView(month: month)
                        
                        // Cards de resumo
                        SummaryCardsView(month: month)
                        
                        // Gráfico e legenda
                        if !month.expenses.isEmpty {
                            ChartSectionView(month: month)
                        } else {
                            EmptyStateView(
                                icon: "chart.pie",
                                title: "Nenhum gasto registrado",
                                message: "Adicione suas contas na aba Mensal para visualizar o gráfico de gastos por categoria"
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                    } else {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Carregando dados...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                viewModel.loadData()
            }
        }
    }
}

// MARK: - Month Header
struct MonthHeaderView: View {
    let month: MonthData
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(month.monthName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(String(month.year))
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            NavigationLink(destination: MonthDetailView(year: month.year, month: month.month)) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(isPressed ? 0.2 : 0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "calendar.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                .scaleEffect(isPressed ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            }
            .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        }
        .padding(.horizontal)
    }
}

// MARK: - Pressable Button Style
struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Summary Cards
struct SummaryCardsView: View {
    let month: MonthData
    
    var body: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Entrada",
                value: month.income,
                color: .green,
                icon: "arrow.down.circle"
            )
            
            SummaryCard(
                title: "Gastos",
                value: month.totalExpenses,
                color: .red,
                icon: "arrow.up.circle"
            )
            
            SummaryCard(
                title: "Saldo",
                value: month.balance,
                color: month.balance >= 0 ? .blue : .orange,
                icon: month.balance >= 0 ? "checkmark.circle" : "exclamationmark.circle"
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Chart Section
struct ChartSectionView: View {
    let month: MonthData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gastos por Categoria")
                .font(.headline)
                .padding(.horizontal)
            
            PieChartView(data: month.expensesByCategory.map { (category: $0.category, total: $0.total) })
                .frame(height: 250)
                .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            CategoryLegendView(categories: month.expensesByCategory)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
}

#Preview {
    ResumoView()
        .environmentObject(ContinhasViewModel())
}

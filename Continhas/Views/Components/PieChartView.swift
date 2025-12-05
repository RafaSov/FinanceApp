//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// PieChartView.swift
// Gráfico de pizza para visualização de gastos

import SwiftUI
import Charts

// MARK: - Pie Chart View
struct PieChartView: View {
    let data: [(category: ExpenseCategory, total: Double)]
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ModernPieChart(data: data)
        } else {
            LegacyPieChart(data: data)
        }
    }
}

// MARK: - iOS 17+ Chart
@available(iOS 17.0, *)
struct ModernPieChart: View {
    let data: [(category: ExpenseCategory, total: Double)]
    
    var body: some View {
        Chart(data, id: \.category) { item in
            SectorMark(
                angle: .value("Valor", item.total),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(item.category.color)
            .cornerRadius(4)
        }
    }
}

// MARK: - Legacy Pie Chart (iOS 16)
struct LegacyPieChart: View {
    let data: [(category: ExpenseCategory, total: Double)]
    
    private var total: Double {
        data.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Fatias do gráfico
                ForEach(Array(data.enumerated()), id: \.element.category) { index, item in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index)
                    )
                    .fill(item.category.color)
                }
                
                // Círculo central (donut)
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: size * 0.5, height: size * 0.5)
                
                // Valor total no centro
                VStack(spacing: 2) {
                    Text("Total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(total.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.7)
                }
                .frame(width: size * 0.4)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let precedingTotal = data.prefix(index).reduce(0) { $0 + $1.total }
        return .degrees(precedingTotal / total * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let includingTotal = data.prefix(index + 1).reduce(0) { $0 + $1.total }
        return .degrees(includingTotal / total * 360 - 90)
    }
}

// MARK: - Pie Slice Shape
struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    PieChartView(data: [
        (.lazer, 500),
        (.transporte, 300),
        (.alimentacao, 800),
        (.moradia, 1200)
    ])
    .frame(height: 250)
    .padding()
}

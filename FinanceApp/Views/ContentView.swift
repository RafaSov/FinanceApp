//
//  ContentView.swift
//  FinanceApp
//
//  Created by Rafael Souza Dutra on 02/12/25.
//

// ContentView.swift
// View principal com TabView

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var financeViewModel: FinanceViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ResumoView()
                .tabItem {
                    Label("Resumo", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            MensalView()
                .tabItem {
                    Label("Mensal", systemImage: "calendar")
                }
                .tag(1)
            
            ConfigView()
                .tabItem {
                    Label("Config", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(FinanceViewModel())
}

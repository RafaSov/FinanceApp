// ConfigView.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Tela de configurações

import SwiftUI

struct ConfigView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false
    @State private var showingExportError = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationStack {
            List {
                // Seção de Dados
                Section {
                    // Exportar
                    Button {
                        exportData()
                    } label: {
                        Label("Exportar Dados", systemImage: "square.and.arrow.up")
                            .foregroundColor(.primary)
                    }
                    
                    // Notificações
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        HStack {
                            Label("Notificações", systemImage: "bell.badge")
                            
                            Spacer()
                            
                            if viewModel.notificationSettings.isEnabled {
                                Text("Dia \(viewModel.notificationSettings.dueDay)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Deletar
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Deletar Todos os Dados", systemImage: "trash")
                    }
                } header: {
                    Text("Dados")
                } footer: {
                    Text("Exporte seus dados em formato CSV compatível com Excel, Numbers e Google Sheets.")
                }
                
                // Estatísticas
                Section("Estatísticas") {
                    HStack {
                        Label("Anos registrados", systemImage: "calendar")
                        Spacer()
                        Text("\(viewModel.years.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Total de contas", systemImage: "doc.text")
                        Spacer()
                        Text("\(totalExpenses)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Seção Sobre
                Section("Sobre") {
                    HStack {
                        Label("Versão", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Desenvolvido com", systemImage: "heart.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("SwiftUI")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Configurações")
            .alert("Deletar Todos os Dados?", isPresented: $showingDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Deletar", role: .destructive) {
                    viewModel.deleteAllData()
                }
            } message: {
                Text("Esta ação não pode ser desfeita. Todos os dados de todos os meses serão permanentemente deletados.")
            }
            .alert("Erro ao Exportar", isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Não foi possível gerar o arquivo de exportação. Tente novamente.")
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    private var totalExpenses: Int {
        viewModel.years.reduce(0) { total, year in
            total + year.months.reduce(0) { $0 + $1.expenses.count }
        }
    }
    
    private func exportData() {
        if let url = viewModel.exportToCSV() {
            exportURL = url
            showingExportSheet = true
        } else {
            showingExportError = true
        }
    }
}

#Preview {
    ConfigView()
        .environmentObject(FinanceViewModel())
}

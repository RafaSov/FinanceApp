//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// ConfigView.swift
// Tela de configurações - CORRIGIDO com exportação robusta

import SwiftUI

struct ConfigView: View {
    @EnvironmentObject var viewModel: ContinhasViewModel
    
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false
    @State private var showingExportError = false
    @State private var isExporting = false
    @State private var exportItems: [Any] = []
    
    var body: some View {
        NavigationStack {
            List {
                // Seção de Dados
                Section {
                    // Exportar
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Label("Exportar Dados", systemImage: "square.and.arrow.up")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isExporting)
                    
                    // Notificações
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        HStack {
                            Label("Notificações", systemImage: "bell.badge")
                            
                            Spacer()
                            
                            if viewModel.notificationSettings.isEnabled {
                                Text("Ativadas")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("Desativadas")
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
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Desenvolvido por", systemImage: "heart.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("Rafael Dutra")
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
                Text("Não foi possível gerar o arquivo de exportação. Verifique se há dados para exportar.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ActivityViewController(activityItems: exportItems)
            }
        }
    }
    
    private var totalExpenses: Int {
        viewModel.years.reduce(0) { total, year in
            total + year.months.reduce(0) { $0 + $1.expenses.count }
        }
    }
    
    // Versão do app (pega do Info.plist)
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    // Build number do app
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    private func exportData() {
        isExporting = true

        Task(priority: .userInitiated) {
            // Call the main actor-isolated method safely on the main actor
            let fileURL = await MainActor.run { viewModel.exportToCSV() }

            // Update UI state on the main actor
            await MainActor.run {
                if let fileURL {
                    exportItems = [fileURL]
                    isExporting = false
                    showingExportSheet = true
                } else {
                    isExporting = false
                    showingExportError = true
                }
            }
        }
    }
}

// MARK: - Activity View Controller (mais confiável que ShareSheet)
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // Configurações para iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.permittedArrowDirections = []
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ConfigView()
        .environmentObject(ContinhasViewModel())
}

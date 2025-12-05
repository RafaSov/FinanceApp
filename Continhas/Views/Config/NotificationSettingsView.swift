//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// NotificationSettingsView.swift
// Configurações de notificações - Simplificado

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var viewModel: ContinhasViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEnabled: Bool = false
    @State private var showingPermissionAlert = false
    @State private var showingSavedAlert = false
    @State private var hasAppeared = false
    
    var body: some View {
        Form {
            // Toggle de ativação
            Section {
                Toggle(isOn: $isEnabled) {
                    Label("Ativar notificações", systemImage: "bell.badge")
                }
                .onChange(of: isEnabled) { _, newValue in
                    if newValue {
                        requestPermission()
                    }
                }
            } footer: {
                Text("Receba lembretes no dia do vencimento de cada conta.")
            }
            
            // Explicação
            Section("Como funciona") {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(
                        icon: "1.circle.fill",
                        color: .blue,
                        text: "Ao criar uma conta, defina o dia de vencimento"
                    )
                    
                    InfoRow(
                        icon: "2.circle.fill",
                        color: .blue,
                        text: "No dia do vencimento, você receberá uma notificação"
                    )
                    
                    InfoRow(
                        icon: "3.circle.fill",
                        color: .blue,
                        text: "Contas marcadas como 'Pago' não enviam notificação"
                    )
                }
                .padding(.vertical, 8)
            }
            
            // Preview da notificação
            if isEnabled {
                Section("Exemplo de notificação") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Continhas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("💰 Conta vence hoje!")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Text("9:00")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Internet - R$ 150,00")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 52)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Botão Salvar
            Section {
                Button {
                    saveSettings()
                } label: {
                    HStack {
                        Spacer()
                        Label("Salvar Configurações", systemImage: "checkmark.circle.fill")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasAppeared {
                loadCurrentSettings()
                hasAppeared = true
            }
        }
        .alert("Permissão Necessária", isPresented: $showingPermissionAlert) {
            Button("Abrir Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {
                isEnabled = false
            }
        } message: {
            Text("Para receber notificações, você precisa permitir nas configurações do seu iPhone.")
        }
        .alert("Configurações Salvas!", isPresented: $showingSavedAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            if isEnabled {
                Text("Você receberá notificações no dia de vencimento de cada conta.")
            } else {
                Text("As notificações foram desativadas.")
            }
        }
    }
    
    private func loadCurrentSettings() {
        isEnabled = viewModel.notificationSettings.isEnabled
    }
    
    private func requestPermission() {
        viewModel.requestNotificationPermission { granted in
            if !granted {
                isEnabled = false
                showingPermissionAlert = true
            }
        }
    }
    
    private func saveSettings() {
        viewModel.updateNotificationSettings(isEnabled: isEnabled)
        showingSavedAlert = true
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environmentObject(ContinhasViewModel())
    }
}

// NotificationSettingsView.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Configurações de notificações

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEnabled: Bool = false
    @State private var selectedDay: Int = 5
    @State private var showingPermissionAlert = false
    @State private var showingSavedAlert = false
    @State private var hasAppeared = false
    
    let availableDays = Array(1...28)
    
    var body: some View {
        Form {
            // Toggle de ativação
            Section {
                Toggle(isOn: $isEnabled) {
                    Label("Ativar notificação de vencimento", systemImage: "bell.badge")
                }
                .onChange(of: isEnabled) { newValue in
                    if newValue {
                        requestPermission()
                    }
                }
            } footer: {
                Text("Você receberá um lembrete mensal no dia selecionado às 9h.")
            }
            
            // Seletor de dia
            Section("Data de Vencimento") {
                if isEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Selecione o dia do mês:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Grid de dias
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(availableDays, id: \.self) { day in
                                Button {
                                    selectedDay = day
                                } label: {
                                    Text("\(day)")
                                        .font(.callout)
                                        .fontWeight(selectedDay == day ? .bold : .regular)
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Circle()
                                                .fill(selectedDay == day ? Color.blue : Color.clear)
                                        )
                                        .foregroundColor(selectedDay == day ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.secondary)
                        Text("Ative as notificações para selecionar o dia")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Preview da notificação
            if isEnabled {
                Section("Prévia da Notificação") {
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
                                Text("FinanceApp")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("💰 Lembrete de Contas")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Text("9:00")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Suas contas estão vencendo! Verifique seus pagamentos no app.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 52)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    HStack {
                        Image(systemName: "repeat.circle")
                            .foregroundColor(.blue)
                        Text("Repetição")
                        Spacer()
                        Text("Todo dia \(selectedDay) de cada mês")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
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
                Text("Você será notificado todo dia \(selectedDay) de cada mês às 9h.")
            } else {
                Text("As notificações foram desativadas.")
            }
        }
    }
    
    private func loadCurrentSettings() {
        isEnabled = viewModel.notificationSettings.isEnabled
        selectedDay = viewModel.notificationSettings.dueDay
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
        viewModel.updateNotificationSettings(isEnabled: isEnabled, dueDay: selectedDay)
        showingSavedAlert = true
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environmentObject(FinanceViewModel())
    }
}

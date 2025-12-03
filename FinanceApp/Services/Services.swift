// Services.swift
// Created by Rafael Souza Dutra on 02/12/25.
// Serviços de persistência e notificações

import Foundation
import UserNotifications

// MARK: - Serviço de Persistência de Dados
class StorageService {
    static let shared = StorageService()
    
    private let yearsKey = "FinanceYearsData"
    private let notificationKey = "NotificationSettings"
    
    private init() {}
    
    // MARK: - Anos/Meses
    func saveYears(_ years: [YearData]) {
        if let encoded = try? JSONEncoder().encode(years) {
            UserDefaults.standard.set(encoded, forKey: yearsKey)
        }
    }
    
    func loadYears() -> [YearData] {
        guard let data = UserDefaults.standard.data(forKey: yearsKey),
              let decoded = try? JSONDecoder().decode([YearData].self, from: data) else {
            return []
        }
        return decoded
    }
    
    // MARK: - Configurações de Notificação
    func saveNotificationSettings(_ settings: NotificationSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: notificationKey)
        }
    }
    
    func loadNotificationSettings() -> NotificationSettings {
        guard let data = UserDefaults.standard.data(forKey: notificationKey),
              let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return NotificationSettings()
        }
        return decoded
    }
    
    // MARK: - Deletar Tudo
    func deleteAllData() {
        UserDefaults.standard.removeObject(forKey: yearsKey)
    }
}

// MARK: - Serviço de Notificações
class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func scheduleMonthlyNotification(day: Int) {
        // Remove notificações anteriores
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "💰 Lembrete de Contas"
        content.body = "Suas contas estão vencendo! Verifique seus pagamentos no app."
        content.sound = .default
        content.badge = 1
        
        // Configura para disparar todo mês no dia especificado às 9h
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "monthlyDueReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - Serviço de Exportação
class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    func generateCSV(from years: [YearData]) -> String {
        var csv = "Ano;Mês;Entrada;Total Gastos;Saldo;Conta;Valor;Categoria;Status\n"
        
        for year in years.sorted(by: { $0.year < $1.year }) {
            for month in year.months.sorted(by: { $0.month < $1.month }) {
                if month.expenses.isEmpty && month.income > 0 {
                    // Mês sem despesas mas com entrada
                    csv += "\(year.year);\(month.monthName);\(formatValue(month.income));\(formatValue(0));\(formatValue(month.income));;;;\n"
                } else if month.expenses.isEmpty {
                    // Mês vazio - pula
                    continue
                } else {
                    // Mês com despesas
                    for (index, expense) in month.expenses.enumerated() {
                        if index == 0 {
                            csv += "\(year.year);\(month.monthName);\(formatValue(month.income));\(formatValue(month.totalExpenses));\(formatValue(month.balance));\(expense.name);\(formatValue(expense.value));\(expense.category.rawValue);\(expense.status.rawValue)\n"
                        } else {
                            csv += ";;;;\(expense.name);\(formatValue(expense.value));\(expense.category.rawValue);\(expense.status.rawValue)\n"
                        }
                    }
                }
            }
        }
        
        return csv
    }
    
    func saveCSVToFile(_ csv: String) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "financas_\(dateString).csv"
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            // Adiciona BOM para UTF-8 (ajuda Excel a reconhecer acentos)
            let bom = "\u{FEFF}"
            try (bom + csv).write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Erro ao salvar CSV: \(error)")
            return nil
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }
}

//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// Services.swift
// Serviços de persistência e notificações

import Foundation
import UserNotifications

// MARK: - Storage Service
final class StorageService {
    static let shared = StorageService()
    
    private enum Keys {
        static let years = "finance_years_data"
        static let notifications = "finance_notification_settings"
    }
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Years Data
    
    func saveYears(_ years: [YearData]) {
        do {
            let data = try encoder.encode(years)
            defaults.set(data, forKey: Keys.years)
        } catch {
            print("❌ Erro ao salvar anos: \(error.localizedDescription)")
        }
    }
    
    func loadYears() -> [YearData] {
        guard let data = defaults.data(forKey: Keys.years) else {
            return []
        }
        
        do {
            return try decoder.decode([YearData].self, from: data)
        } catch {
            print("❌ Erro ao carregar anos: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Notification Settings
    
    func saveNotificationSettings(_ settings: NotificationSettings) {
        do {
            let data = try encoder.encode(settings)
            defaults.set(data, forKey: Keys.notifications)
        } catch {
            print("❌ Erro ao salvar configurações: \(error.localizedDescription)")
        }
    }
    
    func loadNotificationSettings() -> NotificationSettings {
        guard let data = defaults.data(forKey: Keys.notifications) else {
            return NotificationSettings()
        }
        
        do {
            return try decoder.decode(NotificationSettings.self, from: data)
        } catch {
            print("❌ Erro ao carregar configurações: \(error.localizedDescription)")
            return NotificationSettings()
        }
    }
    
    // MARK: - Delete All
    
    func deleteAllData() {
        defaults.removeObject(forKey: Keys.years)
    }
}

// MARK: - Notification Service
final class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    init() {}
    
    // MARK: - Permission
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erro ao solicitar permissão: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Schedule Notification
    
    func scheduleExpenseNotification(expense: Expense, month: Int, year: Int) {
        guard let dueDay = expense.dueDay else { return }
        
        // Remove notificação anterior
        cancelNotification(for: expense.id)
        
        // Cria conteúdo
        let content = UNMutableNotificationContent()
        content.title = "💰 Conta vence hoje!"
        content.body = "\(expense.name) - \(expense.value.currencyFormatted)"
        content.sound = .default
        content.badge = 1
        
        // Configura data
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = dueDay
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        // Valida se a data é futura
        guard let triggerDate = Calendar.current.date(from: dateComponents),
              triggerDate > Date() else {
            return
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "expense_\(expense.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotification(for expenseId: UUID) {
        let identifier = "expense_\(expenseId.uuidString)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.setBadgeCount(0) { _ in }
    }
    
    func rescheduleAllNotifications(for monthData: MonthData, isEnabled: Bool) {
        // Remove todas as notificações desse mês
        let identifiers = monthData.expenses.map { "expense_\($0.id.uuidString)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        
        guard isEnabled else { return }
        
        // Reagenda
        for expense in monthData.expenses where expense.dueDay != nil && expense.status != .pago {
            scheduleExpenseNotification(expense: expense, month: monthData.month, year: monthData.year)
        }
    }
}

// MARK: - Export Service
final class ExportService {
    static let shared = ExportService()
    
    private let fileManager = FileManager.default
    
    init() {}
    
    func generateCSV(from years: [YearData]) -> String {
        var lines: [String] = []
        
        // Header
        lines.append("Ano;Mes;Entrada;Total Gastos;Saldo;Conta;Valor;Categoria;Status;Vencimento")
        
        // Data
        for year in years.sorted(by: { $0.year < $1.year }) {
            for month in year.months.sorted(by: { $0.month < $1.month }) {
                appendMonthData(month: month, year: year.year, to: &lines)
            }
        }
        
        return lines.joined(separator: "\n")
    }
    
    func createCSVFile(from years: [YearData]) -> URL? {
        let csv = generateCSV(from: years)
        let tempDir = fileManager.temporaryDirectory
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        let fileName = "financas_\(formatter.string(from: Date())).csv"
        
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            // Remove arquivo antigo se existir
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
            
            // BOM + conteúdo
            let content = "\u{FEFF}" + csv
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            return fileURL
        } catch {
            print("❌ Erro ao criar arquivo CSV: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func appendMonthData(month: MonthData, year: Int, to lines: inout [String]) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "pt_BR")
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        func formatValue(_ value: Double) -> String {
            numberFormatter.string(from: NSNumber(value: value)) ?? "0,00"
        }
        
        if month.expenses.isEmpty {
            guard month.income > 0 else { return }
            lines.append("\(year);\(month.monthName);\(formatValue(month.income));\(formatValue(0));\(formatValue(month.income));;;;;")
            return
        }
        
        for (index, expense) in month.expenses.enumerated() {
            let dueDayStr = expense.dueDay.map { "Dia \($0)" } ?? ""
            
            if index == 0 {
                lines.append("\(year);\(month.monthName);\(formatValue(month.income));\(formatValue(month.totalExpenses));\(formatValue(month.balance));\(expense.name);\(formatValue(expense.value));\(expense.category.rawValue);\(expense.status.rawValue);\(dueDayStr)")
            } else {
                lines.append(";;;;;\(expense.name);\(formatValue(expense.value));\(expense.category.rawValue);\(expense.status.rawValue);\(dueDayStr)")
            }
        }
    }
}

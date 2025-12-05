//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// ContinhasViewModel.swift
// ViewModel principal

import Foundation
import SwiftUI
import Combine

// MARK: - Continhas ViewModel
final class ContinhasViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var years: [YearData] = []
    @Published var notificationSettings: NotificationSettings = NotificationSettings()
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    private let storageService: StorageService
    private let notificationService: NotificationService
    private let exportService: ExportService
    
    // MARK: - Computed Properties
    
    var currentMonthData: MonthData? {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        return getMonthData(year: currentYear, month: currentMonth)
    }
    
    var sortedYears: [YearData] {
        years.sorted { $0.year > $1.year }
    }
    
    // MARK: - Initialization
    
    init(
        storageService: StorageService = .shared,
        notificationService: NotificationService = .shared,
        exportService: ExportService = .shared
    ) {
        self.storageService = storageService
        self.notificationService = notificationService
        self.exportService = exportService
        
        loadData()
        ensureCurrentYearExists()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        years = storageService.loadYears()
        notificationSettings = storageService.loadNotificationSettings()
        isLoading = false
    }
    
    // MARK: - Year Management
    
    func ensureCurrentYearExists() {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        guard !years.contains(where: { $0.year == currentYear }) else { return }
        
        let newYear = createNewYear(year: currentYear)
        years.append(newYear)
        saveData()
    }
    
    private func createNewYear(year: Int) -> YearData {
        let months = (1...12).map { month in
            MonthData(month: month, year: year)
        }
        return YearData(year: year, months: months)
    }
    
    // MARK: - Month Data Management
    
    func getMonthData(year: Int, month: Int) -> MonthData? {
        years
            .first { $0.year == year }?
            .months.first { $0.month == month }
    }
    
    // MARK: - Income Management
    
    func updateIncome(year: Int, month: Int, newIncome: Double) {
        guard let indices = findMonthIndices(year: year, month: month) else { return }
        
        years[indices.year].months[indices.month].income = max(newIncome, 0)
        saveData()
    }
    
    // MARK: - Expense Management
    
    func addExpense(year: Int, month: Int, expense: Expense) {
        guard let indices = findMonthIndices(year: year, month: month) else { return }
        
        years[indices.year].months[indices.month].expenses.append(expense)
        saveData()
        
        scheduleNotificationIfNeeded(expense: expense, month: month, year: year)
    }
    
    func updateExpense(year: Int, month: Int, expense: Expense) {
        guard let indices = findMonthIndices(year: year, month: month),
              let expenseIndex = years[indices.year].months[indices.month].expenses.firstIndex(where: { $0.id == expense.id }) else {
            return
        }
        
        years[indices.year].months[indices.month].expenses[expenseIndex] = expense
        saveData()
        
        // Atualiza notificação
        notificationService.cancelNotification(for: expense.id)
        if expense.status != .pago {
            scheduleNotificationIfNeeded(expense: expense, month: month, year: year)
        }
    }
    
    func deleteExpense(year: Int, month: Int, at offsets: IndexSet) {
        guard let indices = findMonthIndices(year: year, month: month) else { return }
        
        // Cancela notificações
        for index in offsets {
            let expense = years[indices.year].months[indices.month].expenses[index]
            notificationService.cancelNotification(for: expense.id)
        }
        
        years[indices.year].months[indices.month].expenses.remove(atOffsets: offsets)
        saveData()
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        storageService.saveYears(years)
    }
    
    // MARK: - Delete All Data
    
    func deleteAllData() {
        storageService.deleteAllData()
        notificationService.cancelAllNotifications()
        years = []
        ensureCurrentYearExists()
    }
    
    // MARK: - Notification Settings
    
    func updateNotificationSettings(isEnabled: Bool) {
        notificationSettings.isEnabled = isEnabled
        storageService.saveNotificationSettings(notificationSettings)
        
        if isEnabled {
            rescheduleAllExpenseNotifications()
        } else {
            notificationService.cancelAllNotifications()
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationService.requestPermission(completion: completion)
    }
    
    // MARK: - Export
    
    func exportToCSV() -> URL? {
        exportService.createCSVFile(from: years)
    }
    
    // MARK: - Private Helpers
    
    private func findMonthIndices(year: Int, month: Int) -> (year: Int, month: Int)? {
        guard let yearIndex = years.firstIndex(where: { $0.year == year }),
              let monthIndex = years[yearIndex].months.firstIndex(where: { $0.month == month }) else {
            return nil
        }
        return (yearIndex, monthIndex)
    }
    
    private func scheduleNotificationIfNeeded(expense: Expense, month: Int, year: Int) {
        guard notificationSettings.isEnabled,
              expense.dueDay != nil,
              expense.status != .pago else { return }
        
        notificationService.scheduleExpenseNotification(expense: expense, month: month, year: year)
    }
    
    private func rescheduleAllExpenseNotifications() {
        for year in years {
            for month in year.months {
                notificationService.rescheduleAllNotifications(for: month, isEnabled: notificationSettings.isEnabled)
            }
        }
    }
}

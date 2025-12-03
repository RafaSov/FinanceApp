// FinanceViewModel.swift
// Created by Rafael Souza Dutra on 02/12/25.
// ViewModel principal

import Foundation
import SwiftUI
import Combine

// MARK: - Finance ViewModel Principal
class FinanceViewModel: ObservableObject {
    @Published var years: [YearData] = []
    @Published var notificationSettings: NotificationSettings = NotificationSettings()
    @Published var isLoading: Bool = false
    
    private let storageService = StorageService.shared
    private let notificationService = NotificationService.shared
    private let exportService = ExportService.shared
    
    // MARK: - Computed Properties
    var currentMonthData: MonthData? {
        let now = Date()
        let currentMonth = Calendar.current.component(.month, from: now)
        let currentYear = Calendar.current.component(.year, from: now)
        
        return years
            .first { $0.year == currentYear }?
            .months.first { $0.month == currentMonth }
    }
    
    var sortedYears: [YearData] {
        years.sorted { $0.year > $1.year }
    }
    
    // MARK: - Initialization
    init() {
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
        
        if !years.contains(where: { $0.year == currentYear }) {
            let newYear = createNewYear(year: currentYear)
            years.append(newYear)
            saveData()
        }
    }
    
    private func createNewYear(year: Int) -> YearData {
        var months: [MonthData] = []
        for month in 1...12 {
            months.append(MonthData(month: month, year: year, income: 0, expenses: []))
        }
        return YearData(year: year, months: months)
    }
    
    // MARK: - Month Data Management
    func getMonthData(year: Int, month: Int) -> MonthData? {
        years
            .first { $0.year == year }?
            .months.first { $0.month == month }
    }
    
    func updateMonthData(_ monthData: MonthData) {
        guard let yearIndex = years.firstIndex(where: { $0.year == monthData.year }),
              let monthIndex = years[yearIndex].months.firstIndex(where: { $0.month == monthData.month }) else {
            return
        }
        
        years[yearIndex].months[monthIndex] = monthData
        saveData()
        objectWillChange.send()
    }
    
    // MARK: - Income Management
    func updateIncome(year: Int, month: Int, newIncome: Double) {
        guard let yearIndex = years.firstIndex(where: { $0.year == year }),
              let monthIndex = years[yearIndex].months.firstIndex(where: { $0.month == month }) else {
            return
        }
        
        years[yearIndex].months[monthIndex].income = newIncome
        saveData()
        objectWillChange.send()
    }
    
    // MARK: - Expense Management
    func addExpense(year: Int, month: Int, expense: Expense) {
        guard let yearIndex = years.firstIndex(where: { $0.year == year }),
              let monthIndex = years[yearIndex].months.firstIndex(where: { $0.month == month }) else {
            return
        }
        
        years[yearIndex].months[monthIndex].expenses.append(expense)
        saveData()
        objectWillChange.send()
    }
    
    func updateExpense(year: Int, month: Int, expense: Expense) {
        guard let yearIndex = years.firstIndex(where: { $0.year == year }),
              let monthIndex = years[yearIndex].months.firstIndex(where: { $0.month == month }),
              let expenseIndex = years[yearIndex].months[monthIndex].expenses.firstIndex(where: { $0.id == expense.id }) else {
            return
        }
        
        years[yearIndex].months[monthIndex].expenses[expenseIndex] = expense
        saveData()
        objectWillChange.send()
    }
    
    func deleteExpense(year: Int, month: Int, at offsets: IndexSet) {
        guard let yearIndex = years.firstIndex(where: { $0.year == year }),
              let monthIndex = years[yearIndex].months.firstIndex(where: { $0.month == month }) else {
            return
        }
        
        years[yearIndex].months[monthIndex].expenses.remove(atOffsets: offsets)
        saveData()
        objectWillChange.send()
    }
    
    // MARK: - Persistence
    private func saveData() {
        storageService.saveYears(years)
    }
    
    // MARK: - Delete All Data
    func deleteAllData() {
        storageService.deleteAllData()
        years = []
        ensureCurrentYearExists()
    }
    
    // MARK: - Notification Settings
    func updateNotificationSettings(isEnabled: Bool, dueDay: Int) {
        notificationSettings.isEnabled = isEnabled
        notificationSettings.dueDay = dueDay
        storageService.saveNotificationSettings(notificationSettings)
        
        if isEnabled {
            notificationService.scheduleMonthlyNotification(day: dueDay)
        } else {
            notificationService.cancelAllNotifications()
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationService.requestPermission(completion: completion)
    }
    
    // MARK: - Export
    func exportToCSV() -> URL? {
        let csv = exportService.generateCSV(from: years)
        return exportService.saveCSVToFile(csv)
    }
}

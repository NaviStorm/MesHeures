// Fichier: ViewModels/WorkViewModel.swift
import Foundation
import Combine

class WorkViewModel: ObservableObject {
    @Published var periods: [WorkPeriod] = []
    @Published var currentPeriod: WorkPeriod?
    @Published var selectedDay: WorkDay?
    
    private let dataService = DataPersistenceService()
    
    init() {
        loadData()
    }
    
    func loadData() {
        // Chargement des périodes depuis le stockage local
        if let savedPeriods = dataService.loadPeriods() {
            periods = savedPeriods
        } else {
            // Initialisation avec les périodes de l'année en cours si aucune donnée n'existe
            let currentYear = Calendar.current.component(.year, from: Date())
            periods = TimeCalculator.generateWorkPeriods(for: currentYear)
        }
        
        // Déterminer la période actuelle
        updateCurrentPeriod()
    }
    
    func updateCurrentPeriod() {
        currentPeriod = periods.first(where: { $0.containsCurrentDate() })
    }
    
    func saveData() {
        dataService.savePeriods(periods)
    }
    
    // Fonctions CRUD pour les jours de travail
    func updateWorkDay(_ day: WorkDay) {
        guard let periodIndex = periods.firstIndex(where: { period in
            period.weeks.contains { week in
                week.days.contains { $0.id == day.id }
            }
        }) else { return }
        
        guard let weekIndex = periods[periodIndex].weeks.firstIndex(where: { week in
            week.days.contains { $0.id == day.id }
        }) else { return }
        
        guard let dayIndex = periods[periodIndex].weeks[weekIndex].days.firstIndex(where: { $0.id == day.id }) else { return }
        
        periods[periodIndex].weeks[weekIndex].days[dayIndex] = day
        saveData()
    }
    
    // Fonctions pour obtenir les statistiques
    func getWeeklyStatistics(for week: WorkWeek) -> (worked: TimeInterval, standard: TimeInterval, overtime: TimeInterval) {
        let settings = WorkSettings.shared
        let worked = week.totalWorkedTime
        let standard = settings.weeklyWorkDuration
        let overtime = week.overtimeHours(standardWeekHours: standard)
        
        return (worked, standard, overtime)
    }
    
    func getPeriodStatistics(for period: WorkPeriod) -> (worked: TimeInterval, expected: TimeInterval, overtime: TimeInterval) {
        let settings = WorkSettings.shared
        let worked = period.totalWorkedTime
        
        // Calcul du temps attendu pour la période (nombre de semaines * durée standard par semaine)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: period.startDate, to: period.endDate)
        let weeks = components.weekOfYear ?? 0
        let expected = Double(weeks) * settings.weeklyWorkDuration
        
        let overtime = period.totalOvertimeHours
        
        return (worked, expected, overtime)
    }
}



import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: WorkSettings = WorkSettings.shared
    
    private let dataService = DataPersistenceService()
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let loadedSettings = dataService.loadSettings() {
            // Copier les valeurs au lieu de remplacer l'instance
            WorkSettings.shared.workDaysPerWeek = loadedSettings.workDaysPerWeek
            WorkSettings.shared.weeklyWorkDuration = loadedSettings.weeklyWorkDuration
            WorkSettings.shared.workDays = loadedSettings.workDays
            WorkSettings.shared.dayStartTime = loadedSettings.dayStartTime
            WorkSettings.shared.dayEndTime = loadedSettings.dayEndTime
            WorkSettings.shared.minLunchDuration = loadedSettings.minLunchDuration
            WorkSettings.shared.maxDayDuration = loadedSettings.maxDayDuration
            WorkSettings.shared.maxWeeklyOvertime = loadedSettings.maxWeeklyOvertime
            WorkSettings.shared.maxPeriodOvertime = loadedSettings.maxPeriodOvertime
            WorkSettings.shared.currentPeriodColor = loadedSettings.currentPeriodColor
            WorkSettings.shared.currentWeekColor = loadedSettings.currentWeekColor
            
            // Mettre à jour la référence locale
            settings = WorkSettings.shared
        }
    }
    
    func saveSettings() {
        dataService.saveSettings(settings)
    }
    
    func resetToDefaults() {
        // Créer une nouvelle instance avec les valeurs par défaut
        let defaultSettings = WorkSettings()
        
        // Copier les valeurs vers l'instance partagée
        WorkSettings.shared.workDaysPerWeek = defaultSettings.workDaysPerWeek
        WorkSettings.shared.weeklyWorkDuration = defaultSettings.weeklyWorkDuration
        WorkSettings.shared.workDays = defaultSettings.workDays
        WorkSettings.shared.dayStartTime = defaultSettings.dayStartTime
        WorkSettings.shared.dayEndTime = defaultSettings.dayEndTime
        WorkSettings.shared.minLunchDuration = defaultSettings.minLunchDuration
        WorkSettings.shared.maxDayDuration = defaultSettings.maxDayDuration
        WorkSettings.shared.maxWeeklyOvertime = defaultSettings.maxWeeklyOvertime
        WorkSettings.shared.maxPeriodOvertime = defaultSettings.maxPeriodOvertime
        WorkSettings.shared.currentPeriodColor = defaultSettings.currentPeriodColor
        WorkSettings.shared.currentWeekColor = defaultSettings.currentWeekColor
        
        // Mettre à jour la référence locale
        settings = WorkSettings.shared
        saveSettings()
    }
}

// Fichier: Services/DataPersistenceService.swift
import Foundation

class DataPersistenceService {
    private let periodsKey = "workPeriods"
    private let settingsKey = "workSettings"
    
    func savePeriods(_ periods: [WorkPeriod]) {
        if let encoded = try? JSONEncoder().encode(periods) {
            UserDefaults.standard.set(encoded, forKey: periodsKey)
        }
    }
    
    func loadPeriods() -> [WorkPeriod]? {
        if let data = UserDefaults.standard.data(forKey: periodsKey),
           let periods = try? JSONDecoder().decode([WorkPeriod].self, from: data) {
            return periods
        }
        return nil
    }
    
    func saveSettings(_ settings: WorkSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadSettings() -> WorkSettings? {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(WorkSettings.self, from: data) {
            return settings
        }
        return nil
    }
}



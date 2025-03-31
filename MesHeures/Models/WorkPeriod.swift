// Fichier: Models/WorkPeriod.swift
import Foundation

struct WorkPeriod: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var weeks: [WorkWeek] = []
    
    var totalWorkedTime: TimeInterval {
        return weeks.reduce(0) { $0 + $1.totalWorkedTime }
    }
    
    var formattedTotalWorkedTime: String {
        return TimeCalculator.formatTimeInterval(totalWorkedTime)
    }
    
    var totalOvertimeHours: TimeInterval {
        let settings = WorkSettings.shared
        return weeks.reduce(0) { $0 + $1.overtimeHours(standardWeekHours: settings.weeklyWorkDuration) }
    }
    
    var formattedTotalOvertimeHours: String {
        return TimeCalculator.formatTimeInterval(totalOvertimeHours)
    }
    
    // Fonction pour vérifier si la période contient la date actuelle
    func containsCurrentDate() -> Bool {
        let currentDate = Date()
        return currentDate >= startDate && currentDate <= endDate
    }
}



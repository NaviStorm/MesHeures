// Fichier: Models/WorkWeek.swift
import Foundation

struct WorkWeek: Identifiable, Codable {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var days: [WorkDay] = []
    
    var totalWorkedTime: TimeInterval {
        return days.reduce(0) { $0 + $1.workedTime }
    }
    
    var formattedTotalWorkedTime: String {
        return TimeCalculator.formatTimeInterval(totalWorkedTime)
    }
    
    var weekNumber: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: startDate)
        return components.weekOfYear ?? 0
    }
    
    // Fonction pour calculer les heures supplémentaires de la semaine
    func overtimeHours(standardWeekHours: TimeInterval) -> TimeInterval {
        let overtime = totalWorkedTime - standardWeekHours
        return overtime > 0 ? min(overtime, TimeCalculator.hoursToSeconds(5)) : 0
    }
    
    var formattedOvertimeHours: String {
        let settings = WorkSettings.shared
        return TimeCalculator.formatTimeInterval(overtimeHours(standardWeekHours: settings.weeklyWorkDuration))
    }
}



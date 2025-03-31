// Fichier: Models/WorkDay.swift
import Foundation

struct WorkDay: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var startTime: Date?
    var lunchStartTime: Date?
    var lunchEndTime: Date?
    var endTime: Date?
    var absenceType: AbsenceType?
    var notes: String = ""
    
    var isWorkday: Bool {
        return absenceType == nil || absenceType == .REC || absenceType == .REC_HALF
    }
    
    var workedTime: TimeInterval {
        guard isWorkday, let startTime = startTime, let lunchStartTime = lunchStartTime,
              let lunchEndTime = lunchEndTime, let endTime = endTime else {
            return 0
        }
        
        // Utilisation du calculateur pour obtenir le temps travaillé
        return TimeCalculator.calculateWorkedTime(
            startTime: startTime,
            lunchStartTime: lunchStartTime,
            lunchEndTime: lunchEndTime,
            endTime: endTime
        )
    }
    
    var formattedWorkedTime: String {
        return TimeCalculator.formatTimeInterval(workedTime)
    }
}



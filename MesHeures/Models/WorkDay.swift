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
        // Si pas de temps enregistré, renvoyer 00:00
        guard startTime != nil, lunchStartTime != nil, lunchEndTime != nil, endTime != nil else {
            return "00:00"
        }
        
        return TimeCalculator.formatTimeInterval(workedTime)
    }
    
    // Méthode pratique pour réinitialiser/effacer tous les horaires
    mutating func clearTimes() {
        startTime = nil
        lunchStartTime = nil
        lunchEndTime = nil
        endTime = nil
    }
    
    // Méthode pour définir des horaires standard basés sur les paramètres
    mutating func setDefaultTimes() {
        let settings = WorkSettings.shared
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        
        // Extraire les composants de temps des paramètres
        let startComponents = calendar.dateComponents([.hour, .minute], from: settings.dayStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: settings.dayEndTime)
        
        // Calculer un temps de pause par défaut
        let lunchStartHour = 12
        let lunchEndHour = 13
        
        // Définir les temps
        startTime = calendar.date(bySettingHour: startComponents.hour ?? 9, minute: startComponents.minute ?? 0, second: 0, of: dayStart)
        lunchStartTime = calendar.date(bySettingHour: lunchStartHour, minute: 0, second: 0, of: dayStart)
        lunchEndTime = calendar.date(bySettingHour: lunchEndHour, minute: 0, second: 0, of: dayStart)
        endTime = calendar.date(bySettingHour: endComponents.hour ?? 18, minute: endComponents.minute ?? 0, second: 0, of: dayStart)
    }
}

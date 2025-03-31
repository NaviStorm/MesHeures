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
    
    // Un jour est considéré comme travaillé s'il n'a pas d'absence ou s'il a un type d'absence qui compte comme du travail
    var isWorkday: Bool {
        return absenceType == nil || isConsideredAsWorked
    }
    
    // Vérifie si le type d'absence est considéré comme du travail (CA, MAL, RTT, etc.)
    var isConsideredAsWorked: Bool {
        guard let type = absenceType else { return false }
        
        let consideredTypes = ["CA", "MAL", "RTT", "FER", "REC", "ANC", "FRA"]
        return consideredTypes.contains(type.baseType)
    }
    
    var canEditMorningHours: Bool {
        guard let type = absenceType else { return true }
        return type.isAfternoon
    }
    
    var canEditAfternoonHours: Bool {
        guard let type = absenceType else { return true }
        return type.isMorning
    }
    
    var workedTime: TimeInterval {
        let settings = WorkSettings.shared
        
        // Si c'est un jour sans absence, calculer le temps normalement
        if absenceType == nil {
            guard let startTime = startTime, let lunchStartTime = lunchStartTime,
                  let lunchEndTime = lunchEndTime, let endTime = endTime else {
                return 0
            }
            
            return TimeCalculator.calculateWorkedTime(
                startTime: startTime,
                lunchStartTime: lunchStartTime,
                lunchEndTime: lunchEndTime,
                endTime: endTime
            )
        }
        // Si c'est un jour d'absence considéré comme travaillé
        else if isConsideredAsWorked {
            // Calcul du temps standard pour une journée
            let dayDuration = settings.weeklyWorkDuration / Double(settings.workDaysPerWeek)
            
            // Pour une demi-journée, le temps est divisé par 2
            if let type = absenceType, type.isHalfDay {
                // Si c'est une demi-journée, ajouter le temps travaillé pour l'autre demi-journée
                let halfDayAbsence = dayDuration / 2.0
                
                if type.isMorning {
                    // Absence le matin, calculer le temps travaillé l'après-midi
                    if let lunchEndTime = lunchEndTime, let endTime = endTime {
                        let afternoonWorked = endTime.timeIntervalSince(lunchEndTime)
                        return halfDayAbsence + min(afternoonWorked, dayDuration / 2.0)
                    }
                    return halfDayAbsence
                } else if type.isAfternoon {
                    // Absence l'après-midi, calculer le temps travaillé le matin
                    if let startTime = startTime, let lunchStartTime = lunchStartTime {
                        let morningWorked = lunchStartTime.timeIntervalSince(startTime)
                        return halfDayAbsence + min(morningWorked, dayDuration / 2.0)
                    }
                    return halfDayAbsence
                } else {
                    // RTT_HALF ou REC_HALF (ancienne notation)
                    return dayDuration / 2.0
                }
            }
            
            // Pour une journée complète d'absence considérée comme travaillée
            return dayDuration
        }
        
        // Tout autre type d'absence est considéré comme non travaillé
        return 0
    }
    
    var formattedWorkedTime: String {
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
        
        // Définir selon les horaires spécifiés
        startTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: dayStart)
        lunchStartTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: dayStart)
        lunchEndTime = calendar.date(bySettingHour: 13, minute: 20, second: 0, of: dayStart)
        endTime = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: dayStart)
    }
}

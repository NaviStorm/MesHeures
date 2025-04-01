import Foundation

struct WorkPeriod: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var weeks: [WorkWeek] = []
    
    // Propriété calculée pour obtenir l'année de la période
    var year: Int {
        let calendar = Calendar.current
        // Nous utilisons la date des dimanches pour déterminer l'année de la période
        // En règle générale, on peut utiliser n'importe quel dimanche de la période,
        // mais par précaution, utilisons le premier dimanche de la période
        let firstSunday = getFirstSunday()
        return calendar.component(.year, from: firstSunday ?? startDate)
    }
    
    // Obtenir le premier dimanche de la période
    private func getFirstSunday() -> Date? {
        let calendar = Calendar.current
        var currentDate = startDate
        
        // Chercher le premier dimanche
        while currentDate <= endDate {
            if calendar.component(.weekday, from: currentDate) == 1 { // 1 = dimanche
                return currentDate
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return nil
    }
    
    // Propriété calculée pour obtenir le nom complet incluant l'année
    var fullName: String {
        return "\(name) \(year)"
    }
    
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

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
            
            // Trier les périodes par date (chronologiquement)
            ensureChronologicalOrder()
        } else {
            // Initialisation avec les périodes des années autour de l'année courante
            let currentYear = Calendar.current.component(.year, from: Date())
            initializePeriods(forYears: [currentYear-1, currentYear, currentYear+1])
        }
        
        // Déterminer la période actuelle
        updateCurrentPeriod()
    }
    
    private func initializePeriods(forYears years: [Int]) {
        var allPeriods: [WorkPeriod] = []
        
        // Générer les périodes pour chaque année spécifiée
        for year in years {
            let yearPeriods = TimeCalculator.generateWorkPeriods(for: year)
            allPeriods.append(contentsOf: yearPeriods)
        }
        
        periods = allPeriods
        ensureChronologicalOrder()
    }
    
    // Assure que les périodes sont triées chronologiquement
    private func ensureChronologicalOrder() {
        periods.sort { (period1, period2) -> Bool in
            return period1.startDate < period2.startDate
        }
    }
    
    func updateCurrentPeriod() {
        currentPeriod = periods.first(where: { $0.containsCurrentDate() })
    }
    
    func saveData() {
        dataService.savePeriods(periods)
    }
    
    // Obtenir la période suivante en respectant l'ordre chronologique
    func getNextPeriod(after period: WorkPeriod) -> WorkPeriod? {
        // S'assurer que les périodes sont triées
        ensureChronologicalOrder()
        
        guard let currentIndex = periods.firstIndex(where: { $0.id == period.id }) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        
        // Si nous avons déjà une période suivante, l'utiliser
        if nextIndex < periods.count {
            return periods[nextIndex]
        }
        
        // Sinon, nous devons générer la période suivante
        // Obtenir la date de fin de la dernière période
        let lastPeriodEndDate = period.endDate
        
        // Créer une date pour le premier jour du mois suivant
        let calendar = Calendar.current
        var nextMonthComponents = calendar.dateComponents([.year, .month], from: lastPeriodEndDate)
        
        // Avancer d'un mois
        if nextMonthComponents.month == 12 {
            nextMonthComponents.month = 1
            nextMonthComponents.year! += 1
        } else {
            nextMonthComponents.month! += 1
        }
        
        // Ajouter le premier jour du mois
        nextMonthComponents.day = 1
        
        guard let nextMonthStart = calendar.date(from: nextMonthComponents) else {
            return periods.first // Revenir au début si la date est invalide
        }
        
        // Obtenir l'année et le mois de la prochaine période
        let nextYear = calendar.component(.year, from: nextMonthStart)
        
        // Générer les périodes pour l'année suivante si nécessaire
        let nextYearPeriods = TimeCalculator.generateWorkPeriods(for: nextYear)
        
        // Trouver la période appropriée en fonction de la date
        var nextPeriod: WorkPeriod? = nil
        
        for p in nextYearPeriods {
            if calendar.date(nextMonthStart, matchesComponents: calendar.dateComponents([.month], from: p.startDate)) {
                nextPeriod = p
                break
            }
        }
        
        // Si nous avons trouvé une période suivante, l'ajouter à notre liste
        if let foundNextPeriod = nextPeriod {
            periods.append(foundNextPeriod)
            ensureChronologicalOrder()
            saveData()
            return foundNextPeriod
        }
        
        // Si tout échoue, boucler au début
        return periods.first
    }
    
    // Obtenir la période précédente en respectant l'ordre chronologique
    func getPreviousPeriod(before period: WorkPeriod) -> WorkPeriod? {
        // S'assurer que les périodes sont triées
        ensureChronologicalOrder()
        
        guard let currentIndex = periods.firstIndex(where: { $0.id == period.id }) else {
            return nil
        }
        
        let previousIndex = currentIndex - 1
        
        // Si nous avons déjà une période précédente, l'utiliser
        if previousIndex >= 0 {
            return periods[previousIndex]
        }
        
        // Sinon, nous devons générer la période précédente
        // Obtenir la date de début de la première période
        let firstPeriodStartDate = period.startDate
        
        // Créer une date pour le dernier jour du mois précédent
        let calendar = Calendar.current
        var prevMonthComponents = calendar.dateComponents([.year, .month], from: firstPeriodStartDate)
        
        // Reculer d'un mois
        if prevMonthComponents.month == 1 {
            prevMonthComponents.month = 12
            prevMonthComponents.year! -= 1
        } else {
            prevMonthComponents.month! -= 1
        }
        
        // Obtenir le dernier jour du mois précédent
        prevMonthComponents.day = calendar.range(of: .day, in: .month, for: calendar.date(from: prevMonthComponents)!)?.count
        
        guard let prevMonthEnd = calendar.date(from: prevMonthComponents) else {
            return periods.last // Revenir à la fin si la date est invalide
        }
        
        // Obtenir l'année du mois précédent
        let prevYear = calendar.component(.year, from: prevMonthEnd)
        
        // Générer les périodes pour l'année précédente si nécessaire
        let prevYearPeriods = TimeCalculator.generateWorkPeriods(for: prevYear)
        
        // Trouver la période appropriée en fonction de la date
        var prevPeriod: WorkPeriod? = nil
        
        for p in prevYearPeriods {
            if calendar.date(prevMonthEnd, matchesComponents: calendar.dateComponents([.month], from: p.endDate)) {
                prevPeriod = p
                break
            }
        }
        
        // Si nous avons trouvé une période précédente, l'ajouter à notre liste
        if let foundPrevPeriod = prevPeriod {
            periods.insert(foundPrevPeriod, at: 0)
            ensureChronologicalOrder()
            saveData()
            return foundPrevPeriod
        }
        
        // Si tout échoue, boucler à la fin
        return periods.last
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
    
    func addPeriods(_ newPeriods: [WorkPeriod]) {
        // Filtrer pour ne garder que les périodes qui n'existent pas déjà
        let existingPeriodYearMonths = periods.map { period -> (Int, Int) in
            let calendar = Calendar.current
            let year = calendar.component(.year, from: period.startDate)
            let month = calendar.component(.month, from: period.startDate)
            return (year, month)
        }
        
        let periodsToAdd = newPeriods.filter { newPeriod in
            let calendar = Calendar.current
            let year = calendar.component(.year, from: newPeriod.startDate)
            let month = calendar.component(.month, from: newPeriod.startDate)
            
            return !existingPeriodYearMonths.contains { $0.0 == year && $0.1 == month }
        }
        
        // Ajouter les nouvelles périodes
        if !periodsToAdd.isEmpty {
            periods.append(contentsOf: periodsToAdd)
            ensureChronologicalOrder()
            saveData()
        }
    }
}

extension Calendar {
    // Extension pratique pour vérifier si une date correspond à certains composants d'une autre date
    func date(_ date: Date, matchesComponents components: DateComponents) -> Bool {
        let dateComponents = self.dateComponents(components.dateComponentKeys, from: date)
        
        for key in components.dateComponentKeys {
            switch key {
            case .era:
                if let v1 = components.era, let v2 = dateComponents.era, v1 != v2 { return false }
            case .year:
                if let v1 = components.year, let v2 = dateComponents.year, v1 != v2 { return false }
            case .month:
                if let v1 = components.month, let v2 = dateComponents.month, v1 != v2 { return false }
            case .day:
                if let v1 = components.day, let v2 = dateComponents.day, v1 != v2 { return false }
            case .hour:
                if let v1 = components.hour, let v2 = dateComponents.hour, v1 != v2 { return false }
            case .minute:
                if let v1 = components.minute, let v2 = dateComponents.minute, v1 != v2 { return false }
            case .second:
                if let v1 = components.second, let v2 = dateComponents.second, v1 != v2 { return false }
            case .weekday:
                if let v1 = components.weekday, let v2 = dateComponents.weekday, v1 != v2 { return false }
            case .weekdayOrdinal:
                if let v1 = components.weekdayOrdinal, let v2 = dateComponents.weekdayOrdinal, v1 != v2 { return false }
            case .quarter:
                if let v1 = components.quarter, let v2 = dateComponents.quarter, v1 != v2 { return false }
            case .weekOfMonth:
                if let v1 = components.weekOfMonth, let v2 = dateComponents.weekOfMonth, v1 != v2 { return false }
            case .weekOfYear:
                if let v1 = components.weekOfYear, let v2 = dateComponents.weekOfYear, v1 != v2 { return false }
            case .yearForWeekOfYear:
                if let v1 = components.yearForWeekOfYear, let v2 = dateComponents.yearForWeekOfYear, v1 != v2 { return false }
            case .nanosecond:
                if let v1 = components.nanosecond, let v2 = dateComponents.nanosecond, v1 != v2 { return false }
            case .calendar, .timeZone:
                continue // Ignorer ces composants
            @unknown default:
                continue
            }
        }
        return true
    }
}

extension DateComponents {
    // Extension pour obtenir les clés des composants définis
    var dateComponentKeys: Set<Calendar.Component> {
        var keys = Set<Calendar.Component>()
        if era != nil { keys.insert(.era) }
        if year != nil { keys.insert(.year) }
        if month != nil { keys.insert(.month) }
        if day != nil { keys.insert(.day) }
        if hour != nil { keys.insert(.hour) }
        if minute != nil { keys.insert(.minute) }
        if second != nil { keys.insert(.second) }
        if weekday != nil { keys.insert(.weekday) }
        if weekdayOrdinal != nil { keys.insert(.weekdayOrdinal) }
        if quarter != nil { keys.insert(.quarter) }
        if weekOfMonth != nil { keys.insert(.weekOfMonth) }
        if weekOfYear != nil { keys.insert(.weekOfYear) }
        if yearForWeekOfYear != nil { keys.insert(.yearForWeekOfYear) }
        if nanosecond != nil { keys.insert(.nanosecond) }
        return keys
    }
}

import Foundation

struct TimeCalculator {
    static func calculateWorkedTime(
        startTime: Date,
        lunchStartTime: Date,
        lunchEndTime: Date,
        endTime: Date
    ) -> TimeInterval {
        let settings = WorkSettings.shared
        
        // Extraction des composants date et heure pour les calculs
        let calendar = Calendar.current
        
        // Créer des dates combinant la date de base avec les heures appropriées
        let baseDate = calendar.startOfDay(for: startTime)
        
        // S'assurer que toutes les heures sont sur la même date de base
        let normalizedStartTime = combineDateTime(baseDate: baseDate, timeFromDate: startTime)
        let normalizedLunchStartTime = combineDateTime(baseDate: baseDate, timeFromDate: lunchStartTime)
        let normalizedLunchEndTime = combineDateTime(baseDate: baseDate, timeFromDate: lunchEndTime)
        let normalizedEndTime = combineDateTime(baseDate: baseDate, timeFromDate: endTime)
        
        // Extraction des limites de la journée de travail
        let workdayStartComponents = calendar.dateComponents([.hour, .minute, .second], from: settings.dayStartTime)
        let workdayStart = calendar.date(bySettingHour: workdayStartComponents.hour ?? 7,
                                         minute: workdayStartComponents.minute ?? 0,
                                         second: 0,
                                         of: baseDate) ?? baseDate
        
        let workdayEndComponents = calendar.dateComponents([.hour, .minute, .second], from: settings.dayEndTime)
        let workdayEnd = calendar.date(bySettingHour: workdayEndComponents.hour ?? 19,
                                      minute: workdayEndComponents.minute ?? 0,
                                      second: 0,
                                      of: baseDate) ?? baseDate
        
        // Application des règles
        // 1. Si début avant l'heure minimum, ajuster au minimum
        let effectiveStartTime = normalizedStartTime < workdayStart ? workdayStart : normalizedStartTime
        
        // 2. Si fin après l'heure maximum, ajuster au maximum
        let effectiveEndTime = normalizedEndTime > workdayEnd ? workdayEnd : normalizedEndTime
        
        // 3. Calcul de la durée de la pause repas
        let lunchDuration = normalizedLunchEndTime.timeIntervalSince(normalizedLunchStartTime)
        
        // 4. Si la pause est inférieure au minimum, ajuster
        let effectiveLunchEndTime: Date
        if lunchDuration < settings.minLunchDuration {
            effectiveLunchEndTime = normalizedLunchStartTime.addingTimeInterval(settings.minLunchDuration)
        } else {
            effectiveLunchEndTime = normalizedLunchEndTime
        }
        
        // 5. Calcul du temps travaillé
        let morningWork = normalizedLunchStartTime.timeIntervalSince(effectiveStartTime)
        let afternoonWork = effectiveEndTime.timeIntervalSince(effectiveLunchEndTime)
        let totalWork = morningWork + afternoonWork
        
        // 6. Limitation à la durée maximale journalière
        return min(totalWork, settings.maxDayDuration)
    }
    
    // Fonction pour combiner une date de base avec l'heure d'une autre date
    static func combineDateTime(baseDate: Date, timeFromDate: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeFromDate)
        
        return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                             minute: timeComponents.minute ?? 0,
                             second: timeComponents.second ?? 0,
                             of: baseDate) ?? baseDate
    }
    
    // Méthodes utilitaires pour les conversions de temps
    static func hoursToSeconds(_ hours: Double) -> TimeInterval {
        return hours * 3600
    }
    
    static func minutesToSeconds(_ minutes: Double) -> TimeInterval {
        return minutes * 60
    }
    
    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    // Fonction mise à jour pour calculer les périodes de travail selon la nouvelle définition
    static func generateWorkPeriods(for year: Int) -> [WorkPeriod] {
        var periods: [WorkPeriod] = []
        let calendar = Calendar.current
        
        // Pour chaque mois de l'année
        for month in 1...12 {
            // Créer une date pour le premier jour du mois
            var firstDayComponents = DateComponents()
            firstDayComponents.year = year
            firstDayComponents.month = month
            firstDayComponents.day = 1
            
            guard let firstDayOfMonth = calendar.date(from: firstDayComponents) else {
                continue
            }
            
            // Trouver tous les dimanches du mois
            var allSundaysInMonth: [Date] = []
            
            // Trouver le premier dimanche
            var currentDate = firstDayOfMonth
            while calendar.component(.weekday, from: currentDate) != 1 { // 1 = dimanche
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
            // Maintenant, collecter tous les dimanches du mois
            let endOfMonthComponents = calendar.dateComponents([.year, .month], from: firstDayOfMonth)
            let nextMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: calendar.date(from: endOfMonthComponents)!) ?? firstDayOfMonth
            
            while currentDate <= nextMonth {
                allSundaysInMonth.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 7, to: currentDate) ?? currentDate
            }
            
            // Si le mois n'a pas de dimanches (cas très rare), passer au mois suivant
            if allSundaysInMonth.isEmpty {
                continue
            }
            
            // Pour chaque dimanche, calculer la semaine qui le contient (lundi au dimanche)
            var weekStartDates: [Date] = []
            var weekEndDates: [Date] = []
            
            for sunday in allSundaysInMonth {
                // Lundi de la semaine (6 jours avant le dimanche)
                if let monday = calendar.date(byAdding: .day, value: -6, to: sunday) {
                    weekStartDates.append(monday)
                    weekEndDates.append(sunday)
                }
            }
            
            // Créer une période pour le mois avec toutes ces semaines
            if !weekStartDates.isEmpty {
                let periodName = monthName(for: month) // Nom du mois sans l'année
                let periodStartDate = weekStartDates.first!
                let periodEndDate = weekEndDates.last!
                
                // Créer la période avec le nom sans l'année (l'année sera ajoutée dans la propriété fullName)
                var period = WorkPeriod(name: periodName, startDate: periodStartDate, endDate: periodEndDate)
                
                // Générer toutes les semaines pour cette période
                var weeks: [WorkWeek] = []
                
                for i in 0..<weekStartDates.count {
                    let weekStart = weekStartDates[i]
                    let weekEnd = weekEndDates[i]
                    
                    var week = WorkWeek(startDate: weekStart, endDate: weekEnd)
                    
                    // Générer les jours pour cette semaine
                    var days: [WorkDay] = []
                    var dayDate = weekStart
                    
                    while dayDate <= weekEnd {
                        days.append(WorkDay(date: dayDate))
                        dayDate = calendar.date(byAdding: .day, value: 1, to: dayDate) ?? dayDate
                    }
                    
                    week.days = days
                    weeks.append(week)
                }
                
                period.weeks = weeks
                periods.append(period)
            }
        }
        
        return periods
    }
    
    // Fonction auxiliaire pour obtenir le nom du mois
    private static func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.monthSymbols[month - 1].capitalized
    }
    
    // Fonction pour générer les semaines de travail - obsolète mais gardée pour compatibilité
    static func generateWorkWeeks(from startDate: Date, to endDate: Date) -> [WorkWeek] {
        var weeks: [WorkWeek] = []
        let calendar = Calendar.current
        
        // Trouver le premier lundi après ou égal à la date de début
        var currentDate = startDate
        while calendar.component(.weekday, from: currentDate) != 2 {  // 2 = lundi
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Générer les semaines jusqu'à la date de fin
        while currentDate <= endDate {
            let weekEndDate = calendar.date(byAdding: .day, value: 6, to: currentDate) ?? currentDate  // +6 jours = dimanche
            
            var week = WorkWeek(startDate: currentDate, endDate: min(weekEndDate, endDate))
            
            // Générer les jours pour cette semaine
            var days: [WorkDay] = []
            var dayDate = currentDate
            
            while dayDate <= min(weekEndDate, endDate) {
                days.append(WorkDay(date: dayDate))
                dayDate = calendar.date(byAdding: .day, value: 1, to: dayDate) ?? dayDate
            }
            
            week.days = days
            weeks.append(week)
            
            // Passer à la semaine suivante
            currentDate = calendar.date(byAdding: .day, value: 7, to: currentDate) ?? currentDate
        }
        
        return weeks
    }
}

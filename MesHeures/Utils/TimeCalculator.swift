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
        
        // Debug information
        print("Base date: \(baseDate)")
        print("Effective start: \(effectiveStartTime)")
        print("Lunch start: \(normalizedLunchStartTime)")
        print("Lunch end: \(effectiveLunchEndTime)")
        print("Effective end: \(effectiveEndTime)")
        print("Morning work: \(formatTimeInterval(morningWork))")
        print("Afternoon work: \(formatTimeInterval(afternoonWork))")
        print("Total work: \(formatTimeInterval(totalWork))")
        
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
    
    // Fonction pour calculer les périodes de travail selon les spécifications
    static func generateWorkPeriods(for year: Int) -> [WorkPeriod] {
        var periods: [WorkPeriod] = []
        
        // Définition des périodes selon les spécifications
        let periodDefinitions: [(name: String, startOffset: (month: Int, day: Int), endOffset: (month: Int, day: Int))] = [
            ("Janvier", (month: 12, day: 30), (month: 1, day: 26)),
            ("Février", (month: 1, day: 27), (month: 2, day: 23)),
            ("Mars", (month: 2, day: 24), (month: 3, day: 30)),
            ("Avril", (month: 3, day: 31), (month: 4, day: 27)),
            ("Mai", (month: 4, day: 28), (month: 5, day: 25)),
            ("Juin", (month: 5, day: 26), (month: 6, day: 29)),
            ("Juillet", (month: 6, day: 30), (month: 7, day: 27)),
            ("Août", (month: 7, day: 28), (month: 8, day: 31)),
            ("Septembre", (month: 9, day: 1), (month: 9, day: 28)),
            ("Octobre", (month: 9, day: 29), (month: 10, day: 26)),
            ("Novembre", (month: 10, day: 27), (month: 11, day: 30)),
            ("Décembre", (month: 12, day: 1), (month: 12, day: 28))
        ]
        
        let calendar = Calendar.current
        
        for definition in periodDefinitions {
            // Pour janvier, la date de début est en décembre de l'année précédente
            let startYear = definition.name == "Janvier" ? year - 1 : year
            let endYear = definition.name == "Décembre" && definition.endOffset.month < definition.startOffset.month ? year + 1 : year
            
            var startComponents = DateComponents()
            startComponents.year = startYear
            startComponents.month = definition.startOffset.month
            startComponents.day = definition.startOffset.day
            
            var endComponents = DateComponents()
            endComponents.year = endYear
            endComponents.month = definition.endOffset.month
            endComponents.day = definition.endOffset.day
            
            guard let startDate = calendar.date(from: startComponents),
                  let endDate = calendar.date(from: endComponents) else {
                continue
            }
            
            // Création de la période
            var period = WorkPeriod(name: definition.name, startDate: startDate, endDate: endDate)
            
            // Génération des semaines pour cette période
            period.weeks = generateWorkWeeks(from: startDate, to: endDate)
            
            periods.append(period)
        }
        
        return periods
    }
    
    // Fonction pour générer les semaines de travail d'une période
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

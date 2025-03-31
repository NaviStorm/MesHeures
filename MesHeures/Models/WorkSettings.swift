import Foundation
import SwiftUI

class WorkSettings: ObservableObject, Codable {
    static let shared = WorkSettings()
    
    @Published var workDaysPerWeek: Int = 5
    @Published var weeklyWorkDuration: TimeInterval = TimeCalculator.hoursToSeconds(39)
    @Published var workDays: [Int] = [1, 2, 3, 4, 5] // 1 = lundi, 7 = dimanche
    @Published var dayStartTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var dayEndTime: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var minLunchDuration: TimeInterval = TimeCalculator.minutesToSeconds(20)
    @Published var maxDayDuration: TimeInterval = TimeCalculator.hoursToSeconds(10)
    @Published var maxWeeklyOvertime: TimeInterval = TimeCalculator.hoursToSeconds(5)
    @Published var maxPeriodOvertime: TimeInterval = TimeCalculator.hoursToSeconds(10)
    @Published var currentPeriodColor: Color = .blue
    @Published var currentWeekColor: Color = .green
    
    // Fonction pour vérifier si un jour est un jour travaillé
    func isWorkDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // Conversion de l'index de 1=dimanche à 1=lundi pour correspondre à notre logique
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        return workDays.contains(adjustedWeekday)
    }
    
    // Pour la conformité Codable (avec CodingKeys pour gérer les @Published)
    enum CodingKeys: String, CodingKey {
        case workDaysPerWeek, weeklyWorkDuration, workDays, dayStartTime, dayEndTime
        case minLunchDuration, maxDayDuration, maxWeeklyOvertime, maxPeriodOvertime
        case currentPeriodColor, currentWeekColor
    }
    
    // Initialisation par défaut - explicitement définie
    init() {
        // Les valeurs par défaut sont déjà définies lors de la déclaration des propriétés
    }
    
    // Décodage
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workDaysPerWeek = try container.decode(Int.self, forKey: .workDaysPerWeek)
        weeklyWorkDuration = try container.decode(TimeInterval.self, forKey: .weeklyWorkDuration)
        workDays = try container.decode([Int].self, forKey: .workDays)
        dayStartTime = try container.decode(Date.self, forKey: .dayStartTime)
        dayEndTime = try container.decode(Date.self, forKey: .dayEndTime)
        minLunchDuration = try container.decode(TimeInterval.self, forKey: .minLunchDuration)
        maxDayDuration = try container.decode(TimeInterval.self, forKey: .maxDayDuration)
        maxWeeklyOvertime = try container.decode(TimeInterval.self, forKey: .maxWeeklyOvertime)
        maxPeriodOvertime = try container.decode(TimeInterval.self, forKey: .maxPeriodOvertime)
        // Pour les couleurs, nous devons stocker une valeur codable puis la convertir
        // Ce code est simplifié et devrait être adapté selon la méthode de codage des couleurs
    }
    
    // Encodage
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workDaysPerWeek, forKey: .workDaysPerWeek)
        try container.encode(weeklyWorkDuration, forKey: .weeklyWorkDuration)
        try container.encode(workDays, forKey: .workDays)
        try container.encode(dayStartTime, forKey: .dayStartTime)
        try container.encode(dayEndTime, forKey: .dayEndTime)
        try container.encode(minLunchDuration, forKey: .minLunchDuration)
        try container.encode(maxDayDuration, forKey: .maxDayDuration)
        try container.encode(maxWeeklyOvertime, forKey: .maxWeeklyOvertime)
        try container.encode(maxPeriodOvertime, forKey: .maxPeriodOvertime)
        // Même chose pour les couleurs
    }
}

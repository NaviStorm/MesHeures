import Foundation
import SwiftUI

class WorkSettings: ObservableObject, Codable, Equatable {
    // Utiliser une variable partagée mais avec @Published pour les mises à jour
    static var shared = WorkSettings()
    
    @Published var workDaysPerWeek: Int = 5 {
        didSet { objectWillChange.send() }
    }
    @Published var weeklyWorkDuration: TimeInterval = TimeCalculator.hoursToSeconds(39) {
        didSet { objectWillChange.send() }
    }
    @Published var workDays: [Int] = [1, 2, 3, 4, 5] {
        didSet { objectWillChange.send() }
    }
    @Published var dayStartTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date() {
        didSet { objectWillChange.send() }
    }
    @Published var dayEndTime: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date() {
        didSet { objectWillChange.send() }
    }
    @Published var minLunchDuration: TimeInterval = TimeCalculator.minutesToSeconds(20) {
        didSet { objectWillChange.send() }
    }
    @Published var maxDayDuration: TimeInterval = TimeCalculator.hoursToSeconds(10) {
        didSet { objectWillChange.send() }
    }
    @Published var maxWeeklyOvertime: TimeInterval = TimeCalculator.hoursToSeconds(5) {
        didSet { objectWillChange.send() }
    }
    @Published var maxPeriodOvertime: TimeInterval = TimeCalculator.hoursToSeconds(10) {
        didSet { objectWillChange.send() }
    }
    @Published var currentPeriodColor: Color = .blue {
        didSet { objectWillChange.send() }
    }
    @Published var currentWeekColor: Color = .green {
        didSet { objectWillChange.send() }
    }
    
    // Fonction pour mettre à jour toutes les valeurs en une fois et émettre une seule notification
    func updateAll(from other: WorkSettings) {
        self.workDaysPerWeek = other.workDaysPerWeek
        self.weeklyWorkDuration = other.weeklyWorkDuration
        self.workDays = other.workDays
        self.dayStartTime = other.dayStartTime
        self.dayEndTime = other.dayEndTime
        self.minLunchDuration = other.minLunchDuration
        self.maxDayDuration = other.maxDayDuration
        self.maxWeeklyOvertime = other.maxWeeklyOvertime
        self.maxPeriodOvertime = other.maxPeriodOvertime
        self.currentPeriodColor = other.currentPeriodColor
        self.currentWeekColor = other.currentWeekColor
        
        // Une seule notification pour toutes les mises à jour
        objectWillChange.send()
    }
    
    // Fonction pour vérifier si un jour est un jour travaillé
    func isWorkDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // Conversion de l'index de 1=dimanche à 1=lundi pour correspondre à notre logique
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        return workDays.contains(adjustedWeekday)
    }
    
    // Implémentation de Equatable
    static func == (lhs: WorkSettings, rhs: WorkSettings) -> Bool {
        return lhs.workDaysPerWeek == rhs.workDaysPerWeek &&
               lhs.weeklyWorkDuration == rhs.weeklyWorkDuration &&
               lhs.workDays == rhs.workDays &&
               Calendar.current.isDate(lhs.dayStartTime, equalTo: rhs.dayStartTime, toGranularity: .minute) &&
               Calendar.current.isDate(lhs.dayEndTime, equalTo: rhs.dayEndTime, toGranularity: .minute) &&
               lhs.minLunchDuration == rhs.minLunchDuration &&
               lhs.maxDayDuration == rhs.maxDayDuration &&
               lhs.maxWeeklyOvertime == rhs.maxWeeklyOvertime &&
               lhs.maxPeriodOvertime == rhs.maxPeriodOvertime
        // Note: Les couleurs sont difficiles à comparer avec Equatable, donc nous les omettons ici
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

import Foundation

extension TimeInterval {
    // Conversion en format HH:MM
    var formattedAsHoursAndMinutes: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    // Conversion en heures décimales (pour les calculs)
    var inHours: Double {
        return self / 3600
    }
    
    // Arrondir à la minute la plus proche
    func roundedToMinutes(_ roundingMinutes: Int = 5) -> TimeInterval {
        let seconds = roundingMinutes * 60
        return (self / Double(seconds)).rounded() * Double(seconds)
    }
    
    // Méthode pour calculer la différence avec une autre durée
    func difference(from otherInterval: TimeInterval) -> TimeInterval {
        return self - otherInterval
    }
    
    // Méthode pour savoir si l'intervalle est positif
    var isPositive: Bool {
        return self > 0
    }
    
    // Méthode pour calculer le pourcentage d'une durée cible
    func percentageOf(_ targetInterval: TimeInterval) -> Double {
        guard targetInterval > 0 else { return 0 }
        return (self / targetInterval) * 100
    }
    
    // Conversion en composants (jours, heures, minutes)
    var components: (days: Int, hours: Int, minutes: Int) {
        let totalSeconds = Int(self)
        let days = totalSeconds / (3600 * 24)
        let hours = (totalSeconds % (3600 * 24)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        return (days, hours, minutes)
    }
    
    // Format texte pour affichage (avec jours si nécessaire)
    var verboseFormat: String {
        let components = self.components
        if components.days > 0 {
            return "\(components.days)j \(components.hours)h \(components.minutes)m"
        } else {
            return "\(components.hours)h \(components.minutes)m"
        }
    }
}

extension Date {
    // Extraire juste l'heure et les minutes d'une date
    func timeComponents() -> (hour: Int, minute: Int) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return (hour, minute)
    }
    
    // Créer une date avec seulement l'heure et les minutes spécifiées
    func settingTime(hour: Int, minute: Int, second: Int = 0) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components) ?? self
    }
    
    // Calculer la différence de temps avec une autre date en ignorant la date
    func timeIntervalSinceIgnoringDate(_ date: Date) -> TimeInterval {
        let calendar = Calendar.current
        
        let thisComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        let otherComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
        
        let thisSeconds = (thisComponents.hour ?? 0) * 3600 + (thisComponents.minute ?? 0) * 60 + (thisComponents.second ?? 0)
        let otherSeconds = (otherComponents.hour ?? 0) * 3600 + (otherComponents.minute ?? 0) * 60 + (otherComponents.second ?? 0)
        
        return TimeInterval(thisSeconds - otherSeconds)
    }
    
    // Formater uniquement l'heure (HH:MM)
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    // Vérifier si une heure est comprise entre deux limites (ignorant la date)
    func isBetweenTimes(start: Date, end: Date) -> Bool {
        let calendar = Calendar.current
        
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: start)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: end)
        let selfComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        
        // Convertir en secondes depuis minuit
        let startSeconds = (startComponents.hour ?? 0) * 3600 + (startComponents.minute ?? 0) * 60 + (startComponents.second ?? 0)
        let endSeconds = (endComponents.hour ?? 0) * 3600 + (endComponents.minute ?? 0) * 60 + (endComponents.second ?? 0)
        let selfSeconds = (selfComponents.hour ?? 0) * 3600 + (selfComponents.minute ?? 0) * 60 + (selfComponents.second ?? 0)
        
        return selfSeconds >= startSeconds && selfSeconds <= endSeconds
    }
}

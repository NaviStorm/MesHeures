import Foundation
import UserNotifications

class NotificationService {
    // Singleton pour un accès facile depuis n'importe où dans l'application
    static let shared = NotificationService()
    
    // Fonction pour demander l'autorisation d'envoyer des notifications
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur lors de la demande d'autorisation pour les notifications: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                completion(granted)
            }
        }
    }
    
    // Fonction pour vérifier si les notifications sont autorisées
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // Fonction pour programmer une notification de rappel pour saisir ses heures
    func scheduleWorkHoursReminder(for day: Date, title: String = "N'oubliez pas de saisir vos heures", body: String = "Pensez à renseigner vos heures de travail pour aujourd'hui") {
        // Créer le contenu de la notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Créer un trigger pour le jour spécifié à 18h00
        var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
        components.hour = 18
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Créer la demande de notification avec un identifiant unique basé sur la date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let identifier = "workHoursReminder-" + formatter.string(from: day)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Ajouter la notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la programmation du rappel: \(error.localizedDescription)")
            }
        }
    }
    
    // Fonction pour programmer un rappel hebdomadaire
    func scheduleWeeklyReminder(weekday: Int, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var components = DateComponents()
        components.weekday = weekday // 1 = dimanche, 2 = lundi, etc.
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "weeklyReminder-\(weekday)-\(hour)-\(minute)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la programmation du rappel hebdomadaire: \(error.localizedDescription)")
            }
        }
    }
    
    // Fonction pour programmer une notification pour la fin de période
    func schedulePeriodEndReminder(for period: WorkPeriod, daysInAdvance: Int = 3) {
        let content = UNMutableNotificationContent()
        content.title = "Fin de période approche"
        content.body = "La période \(period.name) se termine dans \(daysInAdvance) jours. N'oubliez pas de vérifier vos heures."
        content.sound = .default
        
        // Calculer la date du rappel (X jours avant la fin de la période)
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysInAdvance, to: period.endDate) ?? period.endDate
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = 10
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "periodEndReminder-\(period.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la programmation du rappel de fin de période: \(error.localizedDescription)")
            }
        }
    }
    
    // Fonction pour annuler une notification spécifique
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Fonction pour annuler toutes les notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Fonction pour programmer une notification
    func scheduleReminder(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la programmation de la notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Fonction pour programmer les rappels pour les jours travaillés d'une semaine
    func scheduleRemindersForWorkWeek(_ week: WorkWeek) {
        let settings = WorkSettings.shared
        
        for day in week.days {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: day.date)
            // Convertir l'index pour correspondre à notre logique (1 = lundi)
            let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
            
            if settings.workDays.contains(adjustedWeekday) {
                scheduleWorkHoursReminder(for: day.date)
            }
        }
    }
    
    func configureNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Autorisation de notification accordée")
            } else if let error = error {
                print("Erreur lors de la demande d'autorisation de notification: \(error.localizedDescription)")
            }
        }
    }

}

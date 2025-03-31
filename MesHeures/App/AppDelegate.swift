import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configuration des notifications
        let notificationService = NotificationService.shared
        notificationService.requestAuthorization { granted in
            if granted {
                print("Autorisation de notification accordée")
            } else {
                print("Autorisation de notification refusée")
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

// SceneDelegate pour gérer les scènes de l'application
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Actions à effectuer quand l'application devient active
        // Par exemple, rafraîchir les données
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Actions à effectuer quand l'application devient inactive
        // Par exemple, sauvegarder les modifications en cours
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Actions à effectuer quand l'application entre en arrière-plan
        // Par exemple, démarrer des tâches en arrière-plan
    }
}

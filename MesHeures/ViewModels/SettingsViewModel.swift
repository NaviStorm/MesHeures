import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    // L'instance partagée est déjà un ObservableObject
    @Published var settings = WorkSettings.shared
    
    private let dataService = DataPersistenceService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observer les changements pour sauvegarder automatiquement
        settings.objectWillChange
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
        
        loadSettings()
    }
    
    func loadSettings() {
        if let loadedSettings = dataService.loadSettings() {
            // Mettre à jour tous les paramètres en une fois
            WorkSettings.shared.updateAll(from: loadedSettings)
            
            // S'assurer que notre référence locale est à jour
            settings = WorkSettings.shared
        }
    }
    
    func saveSettings() {
        dataService.saveSettings(settings)
    }
    
    func resetToDefaults() {
        // Créer une nouvelle instance avec les valeurs par défaut
        let defaultSettings = WorkSettings()
        
        // Mettre à jour l'instance partagée en une fois
        WorkSettings.shared.updateAll(from: defaultSettings)
        
        // Mettre à jour la référence locale
        settings = WorkSettings.shared
        
        // Sauvegarder les paramètres
        saveSettings()
    }
}

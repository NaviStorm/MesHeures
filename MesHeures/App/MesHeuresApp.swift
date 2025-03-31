// Fichier: MesHeuresApp.swift
import SwiftUI

@main
struct MesHeuresApp: App {
    @StateObject private var workViewModel = WorkViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(workViewModel)
                .environmentObject(settingsViewModel)
                .onAppear {
                    // Chargement des données au démarrage
                    workViewModel.loadData()
                    settingsViewModel.loadSettings()
                }
        }
    }
}



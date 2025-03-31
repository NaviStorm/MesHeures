import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingResetAlert = false
    @State private var refreshID = UUID()
    
    // On utilise @ObservedObject pour s'assurer que les changements sont bien observés
    @ObservedObject private var settings = WorkSettings.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jours travaillés")) {
                    Stepper("Jours par semaine: \(settings.workDaysPerWeek)", value: $settings.workDaysPerWeek, in: 1...7)
                        .onChange(of: settings.workDaysPerWeek) { newValue in
                            settingsViewModel.saveSettings()
                        }
                    
                    ForEach(1..<8) { day in
                        let isSelected = settings.workDays.contains(day)
                        
                        Button(action: {
                            toggleWorkDay(day)
                        }) {
                            HStack {
                                Text(dayName(for: day))
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(settings.workDays.count <= 1 && isSelected)
                    }
                }
                
                Section(header: Text("Horaires")) {
                    HStack {
                        Text("Heures par semaine")
                        Spacer()
                        Text(formatTimeInterval(settings.weeklyWorkDuration))
                    }
                    
                    let weeklyHoursBinding = Binding<Double>(
                        get: { settings.weeklyWorkDuration / 3600 },
                        set: {
                            settings.weeklyWorkDuration = $0 * 3600
                            settingsViewModel.saveSettings()
                        }
                    )
                    
                    Slider(value: weeklyHoursBinding, in: 20...50, step: 0.5)
                        .padding(.horizontal)
                    
                    DatePicker("Début journée", selection: $settings.dayStartTime, displayedComponents: .hourAndMinute)
                        .onChange(of: settings.dayStartTime) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    DatePicker("Fin journée", selection: $settings.dayEndTime, displayedComponents: .hourAndMinute)
                        .onChange(of: settings.dayEndTime) { _ in
                            settingsViewModel.saveSettings()
                        }
                }
                
                Section(header: Text("Pauses et Limites")) {
                    TimeIntervalPicker(title: "Pause minimale", value: Binding(
                        get: { settings.minLunchDuration },
                        set: {
                            settings.minLunchDuration = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .minute, range: 10...120, step: 5)
                    
                    TimeIntervalPicker(title: "Maximum par jour", value: Binding(
                        get: { settings.maxDayDuration },
                        set: {
                            settings.maxDayDuration = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 5...14, step: 0.5)
                    
                    TimeIntervalPicker(title: "Maximum heures supp./semaine", value: Binding(
                        get: { settings.maxWeeklyOvertime },
                        set: {
                            settings.maxWeeklyOvertime = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 1...10, step: 1)
                    
                    TimeIntervalPicker(title: "Maximum heures supp./période", value: Binding(
                        get: { settings.maxPeriodOvertime },
                        set: {
                            settings.maxPeriodOvertime = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 5...20, step: 1)
                }
                
                Section(header: Text("Apparence")) {
                    ColorPicker("Couleur période actuelle", selection: $settings.currentPeriodColor)
                        .onChange(of: settings.currentPeriodColor) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    ColorPicker("Couleur semaine actuelle", selection: $settings.currentWeekColor)
                        .onChange(of: settings.currentWeekColor) { _ in
                            settingsViewModel.saveSettings()
                        }
                }
                
                Section {
                    Button("Réinitialiser aux valeurs par défaut") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                .alert(isPresented: $showingResetAlert) {
                    Alert(
                        title: Text("Réinitialiser les paramètres"),
                        message: Text("Êtes-vous sûr de vouloir réinitialiser tous les paramètres à leurs valeurs par défaut ?"),
                        primaryButton: .destructive(Text("Réinitialiser")) {
                            settingsViewModel.resetToDefaults()
                            // Force le redémarrage complet de la vue
                            refreshID = UUID()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .id(refreshID) // La vue redémarrera si refreshID change
            .navigationTitle("Paramètres")
            .onDisappear {
                // S'assurer que les paramètres sont sauvegardés lors de la fermeture de la vue
                settingsViewModel.saveSettings()
            }
        }
    }
    
    private func toggleWorkDay(_ day: Int) {
        if settings.workDays.contains(day) {
            // S'assurer qu'il y a toujours au moins un jour sélectionné
            if settings.workDays.count > 1 {
                settings.workDays.removeAll { $0 == day }
            }
        } else {
            settings.workDays.append(day)
            settings.workDays.sort()
        }
        
        // Mettre à jour le nombre de jours par semaine
        settings.workDaysPerWeek = settings.workDays.count
        
        // Sauvegarder les changements
        settingsViewModel.saveSettings()
    }
    
    private func dayName(for dayIndex: Int) -> String {
        let days = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
        return days[dayIndex - 1]
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

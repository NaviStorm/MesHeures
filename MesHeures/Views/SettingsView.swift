import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jours travaillés")) {
                    Stepper("Jours par semaine: \(settingsViewModel.settings.workDaysPerWeek)", value: $settingsViewModel.settings.workDaysPerWeek, in: 1...7)
                        .onChange(of: settingsViewModel.settings.workDaysPerWeek) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    ForEach(1..<8) { day in
                        let isSelected = settingsViewModel.settings.workDays.contains(day)
                        
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
                        .disabled(settingsViewModel.settings.workDays.count <= 1 && isSelected)
                    }
                }
                
                Section(header: Text("Horaires")) {
                    HStack {
                        Text("Heures par semaine")
                        Spacer()
                        Text(formatTimeInterval(settingsViewModel.settings.weeklyWorkDuration))
                    }
                    
                    let weeklyHoursBinding = Binding<Double>(
                        get: { settingsViewModel.settings.weeklyWorkDuration / 3600 },
                        set: {
                            settingsViewModel.settings.weeklyWorkDuration = $0 * 3600
                            settingsViewModel.saveSettings()
                        }
                    )
                    
                    Slider(value: weeklyHoursBinding, in: 20...50, step: 0.5)
                        .padding(.horizontal)
                    
                    DatePicker("Début journée", selection: $settingsViewModel.settings.dayStartTime, displayedComponents: .hourAndMinute)
                        .onChange(of: settingsViewModel.settings.dayStartTime) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    DatePicker("Fin journée", selection: $settingsViewModel.settings.dayEndTime, displayedComponents: .hourAndMinute)
                        .onChange(of: settingsViewModel.settings.dayEndTime) { _ in
                            settingsViewModel.saveSettings()
                        }
                }
                
                Section(header: Text("Pauses et Limites")) {
                    TimeIntervalPicker(title: "Pause minimale", value: Binding(
                        get: { settingsViewModel.settings.minLunchDuration },
                        set: {
                            settingsViewModel.settings.minLunchDuration = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .minute, range: 10...120, step: 5)
                    
                    TimeIntervalPicker(title: "Maximum par jour", value: Binding(
                        get: { settingsViewModel.settings.maxDayDuration },
                        set: {
                            settingsViewModel.settings.maxDayDuration = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 5...14, step: 0.5)
                    
                    TimeIntervalPicker(title: "Maximum heures supp./semaine", value: Binding(
                        get: { settingsViewModel.settings.maxWeeklyOvertime },
                        set: {
                            settingsViewModel.settings.maxWeeklyOvertime = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 1...10, step: 1)
                    
                    TimeIntervalPicker(title: "Maximum heures supp./période", value: Binding(
                        get: { settingsViewModel.settings.maxPeriodOvertime },
                        set: {
                            settingsViewModel.settings.maxPeriodOvertime = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 5...20, step: 1)
                }
                
                Section(header: Text("Apparence")) {
                    ColorPicker("Couleur période actuelle", selection: $settingsViewModel.settings.currentPeriodColor)
                        .onChange(of: settingsViewModel.settings.currentPeriodColor) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    ColorPicker("Couleur semaine actuelle", selection: $settingsViewModel.settings.currentWeekColor)
                        .onChange(of: settingsViewModel.settings.currentWeekColor) { _ in
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
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationTitle("Paramètres")
        }
    }
    
    private func toggleWorkDay(_ day: Int) {
        if settingsViewModel.settings.workDays.contains(day) {
            // S'assurer qu'il y a toujours au moins un jour sélectionné
            if settingsViewModel.settings.workDays.count > 1 {
                settingsViewModel.settings.workDays.removeAll { $0 == day }
            }
        } else {
            settingsViewModel.settings.workDays.append(day)
            settingsViewModel.settings.workDays.sort()
        }
        
        // Mettre à jour le nombre de jours par semaine
        settingsViewModel.settings.workDaysPerWeek = settingsViewModel.settings.workDays.count
        
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

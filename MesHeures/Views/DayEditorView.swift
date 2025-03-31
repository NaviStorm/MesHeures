import SwiftUI

struct DayEditorView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var workDay: WorkDay
    @State private var showingAbsenceTypePicker = false
    
    // États locaux pour gérer les horaires
    @State private var startTime: Date
    @State private var lunchStartTime: Date
    @State private var lunchEndTime: Date
    @State private var endTime: Date
    @State private var calculatedTime: String = "00:00"
    
    init(day: WorkDay) {
        _workDay = State(initialValue: day)
        
        // Initialiser les heures avec les valeurs existantes ou des valeurs par défaut
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day.date)
        
        _startTime = State(initialValue: day.startTime ?? calendar.date(bySettingHour: 7, minute: 0, second: 0, of: dayStart) ?? dayStart)
        _lunchStartTime = State(initialValue: day.lunchStartTime ?? calendar.date(bySettingHour: 13, minute: 0, second: 0, of: dayStart) ?? dayStart)
        _lunchEndTime = State(initialValue: day.lunchEndTime ?? calendar.date(bySettingHour: 13, minute: 20, second: 0, of: dayStart) ?? dayStart)
        _endTime = State(initialValue: day.endTime ?? calendar.date(bySettingHour: 16, minute: 0, second: 0, of: dayStart) ?? dayStart)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Date")) {
                HStack {
                    Text(formattedDate)
                    Spacer()
                    Button(action: {
                        showingAbsenceTypePicker = true
                    }) {
                        HStack {
                            Text(workDay.absenceType?.rawValue ?? "Travaillé")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .sheet(isPresented: $showingAbsenceTypePicker) {
                    AbsenceTypePicker(selectedType: $workDay.absenceType)
                }
            }
            
            // Section horaires de travail - avec gestion des demi-journées d'absence
            if workDay.isWorkday {
                Section(header: Text("Horaires de travail")) {
                    // Affichage conditionnel pour les demi-journées d'absence
                    if workDay.canEditMorningHours {
                        DatePicker("Début journée", selection: $startTime, displayedComponents: .hourAndMinute)
                            .onChange(of: startTime) { _ in updateCalculation() }
                        
                        DatePicker("Début pause", selection: $lunchStartTime, displayedComponents: .hourAndMinute)
                            .onChange(of: lunchStartTime) { _ in updateCalculation() }
                    } else if let type = workDay.absenceType, type.isAfternoon {
                        Text("Matin : \(type.baseType)")
                            .foregroundColor(type.color)
                    }
                    
                    if workDay.canEditAfternoonHours {
                        DatePicker("Fin pause", selection: $lunchEndTime, displayedComponents: .hourAndMinute)
                            .onChange(of: lunchEndTime) { _ in updateCalculation() }
                        
                        DatePicker("Fin journée", selection: $endTime, displayedComponents: .hourAndMinute)
                            .onChange(of: endTime) { _ in updateCalculation() }
                    } else if let type = workDay.absenceType, type.isMorning {
                        Text("Après-midi : \(type.baseType)")
                            .foregroundColor(type.color)
                    }
                    
                    // Si c'est un jour d'absence complet comptant comme travaillé
                    if workDay.isConsideredAsWorked &&
                       workDay.absenceType != nil &&
                       !(workDay.absenceType?.isHalfDay ?? false) {
                        Text("Journée comptabilisée en tant que \(workDay.absenceType?.rawValue ?? "")")
                            .foregroundColor(workDay.absenceType?.color ?? .primary)
                    }
                    
                    HStack {
                        Text("Temps travaillé")
                        Spacer()
                        Text(calculatedTime)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $workDay.notes)
                    .frame(minHeight: 100)
            }
            
            Section {
                Button("Enregistrer") {
                    // Mettre à jour le workDay avec les valeurs actuelles
                    updateWorkDayFromFields()
                    
                    // Mise à jour du jour dans le ViewModel
                    workViewModel.updateWorkDay(workDay)
                    
                    // Fermeture de la vue
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .navigationTitle("Modifier Journée")
        .onAppear {
            // Calculer le temps travaillé dès l'apparition de la vue
            updateCalculation()
        }
        .onDisappear {
            // Sauvegarder également au départ de la vue
            updateWorkDayFromFields()
            workViewModel.saveData()
        }
    }
    
    private func updateWorkDayFromFields() {
        // Mettre à jour workDay avec les valeurs actuelles des champs
        if workDay.absenceType == nil {
            // Jour normal travaillé
            workDay.startTime = startTime
            workDay.lunchStartTime = lunchStartTime
            workDay.lunchEndTime = lunchEndTime
            workDay.endTime = endTime
        } else if workDay.isConsideredAsWorked && workDay.absenceType?.isHalfDay == true {
            // Demi-journée d'absence comptant comme travaillée
            if workDay.canEditMorningHours {
                // Si on peut éditer le matin (absence l'après-midi)
                workDay.startTime = startTime
                workDay.lunchStartTime = lunchStartTime
            }
            
            if workDay.canEditAfternoonHours {
                // Si on peut éditer l'après-midi (absence le matin)
                workDay.lunchEndTime = lunchEndTime
                workDay.endTime = endTime
            }
        }
    }
    
    private func updateCalculation() {
        if workDay.absenceType == nil {
            // Jour normal travaillé - calcul standard
            let workedTime = TimeCalculator.calculateWorkedTime(
                startTime: startTime,
                lunchStartTime: lunchStartTime,
                lunchEndTime: lunchEndTime,
                endTime: endTime
            )
            calculatedTime = TimeCalculator.formatTimeInterval(workedTime)
        } else {
            // Utiliser le calcul spécial pour les absences
            let updatedDay = workDay
            calculatedTime = updatedDay.formattedWorkedTime
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: workDay.date)
    }
}

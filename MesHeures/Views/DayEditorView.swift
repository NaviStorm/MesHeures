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
    
    // Modifier la partie init de DayEditorView.swift pour les heures par défaut

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
            

            if workDay.absenceType == nil {
                Section(header: Text("Horaires de travail")) {
                    DatePicker("Début journée", selection: $startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: startTime) { _ in updateCalculation() }
                    
                    DatePicker("Début pause", selection: $lunchStartTime, displayedComponents: .hourAndMinute)
                        .onChange(of: lunchStartTime) { _ in updateCalculation() }
                    
                    DatePicker("Fin pause", selection: $lunchEndTime, displayedComponents: .hourAndMinute)
                        .onChange(of: lunchEndTime) { _ in updateCalculation() }
                    
                    DatePicker("Fin journée", selection: $endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: endTime) { _ in updateCalculation() }
                    
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
            workDay.startTime = startTime
            workDay.lunchStartTime = lunchStartTime
            workDay.lunchEndTime = lunchEndTime
            workDay.endTime = endTime
        }
    }
    
    private func updateCalculation() {
        let workedTime = TimeCalculator.calculateWorkedTime(
            startTime: startTime,
            lunchStartTime: lunchStartTime,
            lunchEndTime: lunchEndTime,
            endTime: endTime
        )
        
        calculatedTime = TimeCalculator.formatTimeInterval(workedTime)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: workDay.date)
    }
}

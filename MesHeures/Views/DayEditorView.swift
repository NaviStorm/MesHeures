import SwiftUI

struct DayEditorView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var workDay: WorkDay
    @State private var showingAbsenceTypePicker = false
    
    init(day: WorkDay) {
        _workDay = State(initialValue: day)
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
            
            if workDay.isWorkday {
                Section(header: Text("Horaires de travail")) {
                    TimePickerRow(title: "Début journée", time: Binding(
                        get: { workDay.startTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: workDay.date) ?? workDay.date },
                        set: { workDay.startTime = $0 }
                    ))
                    
                    TimePickerRow(title: "Début pause", time: Binding(
                        get: { workDay.lunchStartTime ?? Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: workDay.date) ?? workDay.date },
                        set: { workDay.lunchStartTime = $0 }
                    ))
                    
                    TimePickerRow(title: "Fin pause", time: Binding(
                        get: { workDay.lunchEndTime ?? Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: workDay.date) ?? workDay.date },
                        set: { workDay.lunchEndTime = $0 }
                    ))
                    
                    TimePickerRow(title: "Fin journée", time: Binding(
                        get: { workDay.endTime ?? Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: workDay.date) ?? workDay.date },
                        set: { workDay.endTime = $0 }
                    ))
                    
                    HStack {
                        Text("Temps travaillé")
                        Spacer()
                        Text(calculatedWorkedTime)
                            .bold()
                    }
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $workDay.notes)
                    .frame(minHeight: 100)
            }
            
            Section {
                Button("Enregistrer") {
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
        .onDisappear {
            // Sauvegarder également au départ de la vue
            workViewModel.saveData()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: workDay.date)
    }
    
    var calculatedWorkedTime: String {
        if let startTime = workDay.startTime,
           let lunchStartTime = workDay.lunchStartTime,
           let lunchEndTime = workDay.lunchEndTime,
           let endTime = workDay.endTime {
            
            let workedTime = TimeCalculator.calculateWorkedTime(
                startTime: startTime,
                lunchStartTime: lunchStartTime,
                lunchEndTime: lunchEndTime,
                endTime: endTime
            )
            
            return TimeCalculator.formatTimeInterval(workedTime)
        }
        
        return "00:00"
    }
}

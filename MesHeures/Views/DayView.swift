import SwiftUI

struct DayView: View {
    var day: WorkDay
    @EnvironmentObject var workViewModel: WorkViewModel
    
    var body: some View {
        VStack {
            Text(formattedDate)
                .font(.headline)
                .padding()
            
            if day.isWorkday {
                if let startTime = day.startTime,
                   let lunchStartTime = day.lunchStartTime,
                   let lunchEndTime = day.lunchEndTime,
                   let endTime = day.endTime {
                    
                    Group {
                        HStack {
                            Text("Début journée:")
                            Spacer()
                            Text(formatTime(startTime))
                                .font(.headline)
                        }
                        HStack {
                            Text("Début pause:")
                            Spacer()
                            Text(formatTime(lunchStartTime))
                                .font(.headline)
                        }
                        HStack {
                            Text("Fin pause:")
                            Spacer()
                            Text(formatTime(lunchEndTime))
                                .font(.headline)
                        }
                        HStack {
                            Text("Fin journée:")
                            Spacer()
                            Text(formatTime(endTime))
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Durée pause repas:")
                            Spacer()
                            Text(formatDuration(lunchEndTime.timeIntervalSince(lunchStartTime)))
                                .font(.headline)
                        }
                        
                        HStack {
                            Text("Temps travaillé:")
                            Spacer()
                            Text(day.formattedWorkedTime)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Aucun horaire saisi pour ce jour")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else if let absenceType = day.absenceType {
                HStack {
                    Text("Type d'absence:")
                    Spacer()
                    Text(absenceType.rawValue)
                        .font(.headline)
                        .foregroundColor(absenceType.color)
                }
                .padding()
            }
            
            if !day.notes.isEmpty {
                VStack(alignment: .leading) {
                    Text("Notes:")
                        .font(.headline)
                    Text(day.notes)
                        .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Détail Journée")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: day.date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        return "\(minutes) min"
    }
}

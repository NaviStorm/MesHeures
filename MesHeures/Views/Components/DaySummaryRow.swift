import SwiftUI

struct DaySummaryRow: View {
    var day: WorkDay
    
    var body: some View {
        HStack {
            // Indicateur du jour
            VStack(alignment: .leading) {
                Text(dayName)
                    .font(.headline)
                Text(dayNumber)
                    .font(.caption)
            }
            .frame(width: 60)
            
            if let absenceType = day.absenceType {
                // Jour d'absence
                VStack(alignment: .leading) {
                    if absenceType.isHalfDay {
                        // Demi-journée d'absence
                        if absenceType.isMorning {
                            Text("\(absenceType.baseType) (Matin)")
                                .foregroundColor(absenceType.color)
                            
                            if let lunchEndTime = day.lunchEndTime, let endTime = day.endTime {
                                Text("Après-midi: \(formatTime(lunchEndTime)) - \(formatTime(endTime))")
                                    .font(.caption)
                            }
                        } else if absenceType.isAfternoon {
                            Text("\(absenceType.baseType) (Après-midi)")
                                .foregroundColor(absenceType.color)
                            
                            if let startTime = day.startTime, let lunchStartTime = day.lunchStartTime {
                                Text("Matin: \(formatTime(startTime)) - \(formatTime(lunchStartTime))")
                                    .font(.caption)
                            }
                        } else {
                            // RTT_HALF, REC_HALF (ancienne notation)
                            Text(absenceType.rawValue)
                                .foregroundColor(absenceType.color)
                        }
                    } else {
                        // Journée complète d'absence
                        Text(absenceType.rawValue)
                            .foregroundColor(absenceType.color)
                    }
                    
                    if !day.notes.isEmpty {
                        Text(day.notes)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Si l'absence compte comme travaillée, afficher le temps
                if day.isConsideredAsWorked {
                    Text(day.formattedWorkedTime)
                        .bold()
                }
            } else if let startTime = day.startTime,
                      let lunchStartTime = day.lunchStartTime,
                      let lunchEndTime = day.lunchEndTime,
                      let endTime = day.endTime {
                // Jour travaillé avec horaires
                VStack(alignment: .leading) {
                    HStack(spacing: 3) {
                        Text(formatTime(startTime))
                        Text("-")
                        Text(formatTime(lunchStartTime))
                        Text("/")
                        Text(formatTime(lunchEndTime))
                        Text("-")
                        Text(formatTime(endTime))
                    }
                    .font(.subheadline)
                    
                    if !day.notes.isEmpty {
                        Text(day.notes)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Text(day.formattedWorkedTime)
                    .bold()
            } else {
                // Jour travaillé sans horaires entrés
                Text("Non renseigné")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.vertical, 2)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: day.date).capitalized
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: day.date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Fichier: Views/Components/WeekSummaryRow.swift
import SwiftUI

struct WeekSummaryRow: View {
    var week: WorkWeek
    @EnvironmentObject var workViewModel: WorkViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Semaine \(week.weekNumber)")
                    .font(.headline)
                Spacer()
                Text("\(formatDate(week.startDate)) - \(formatDate(week.endDate))")
                    .font(.caption)
            }
            
            HStack {
                Text("Travaillé: \(week.formattedTotalWorkedTime)")
                Spacer()
                Text("Supp.: \(week.formattedOvertimeHours)")
                
                if isCurrentWeek {
                    Circle()
                        .fill(WorkSettings.shared.currentWeekColor)
                        .frame(width: 10, height: 10)
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
    
    private var isCurrentWeek: Bool {
        let today = Date()
        return today >= week.startDate && today <= week.endDate
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}



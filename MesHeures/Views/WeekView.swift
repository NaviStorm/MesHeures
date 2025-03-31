// Fichier: Views/WeekView.swift
import SwiftUI

struct WeekView: View {
    var week: WorkWeek
    @EnvironmentObject var workViewModel: WorkViewModel
    
    var body: some View {
        VStack {
            // En-tête avec la semaine et les dates
            HStack {
                Text("Semaine \(week.weekNumber)")
                    .font(.title)
                Spacer()
                Text("\(formatDate(week.startDate)) - \(formatDate(week.endDate))")
            }
            .padding()
            
            // Statistiques de la semaine
            let stats = workViewModel.getWeeklyStatistics(for: week)
            StatisticsView(worked: stats.worked, expected: stats.standard, overtime: stats.overtime)
                .padding(.horizontal)
            
            // Liste des jours
            List {
                ForEach(week.days) { day in
                    NavigationLink(destination: DayEditorView(day: day)) {
                        DaySummaryRow(day: day)
                    }
                }
            }
        }
        .navigationTitle("Détail Semaine")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}



// Fichier: Views/PeriodView.swift
import SwiftUI

struct PeriodView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    var period: WorkPeriod
    
    var body: some View {
        VStack {
            // En-tête avec le nom de la période et les dates
            HStack {
                Text(period.name)
                    .font(.title)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Du \(formatDate(period.startDate))")
                    Text("Au \(formatDate(period.endDate))")
                }
                .font(.caption)
            }
            .padding()
            
            // Statistiques de la période
            let stats = workViewModel.getPeriodStatistics(for: period)
            StatisticsView(worked: stats.worked, expected: stats.expected, overtime: stats.overtime)
                .padding()
            
            // Liste des semaines
            List {
                ForEach(period.weeks) { week in
                    NavigationLink(destination: WeekView(week: week)) {
                        WeekSummaryRow(week: week)
                    }
                }
            }
        }
        .navigationTitle("Période \(period.name)")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}



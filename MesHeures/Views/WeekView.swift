import SwiftUI

struct WeekView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @State private var week: WorkWeek
    
    init(week: WorkWeek) {
        _week = State(initialValue: week)
    }
    
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
            
            // Liste des jours - uniquement les jours travaillés
            List {
                // Filtrer pour ne montrer que les jours configurés comme jours travaillés dans les paramètres
                ForEach(workableDays) { day in
                    NavigationLink {
                        DayEditorView(day: day)
                    } label: {
                        DaySummaryRow(day: day)
                    }
                    .isDetailLink(true)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Détail Semaine")
        .onAppear {
            // S'assurer que les données de la semaine sont à jour
            if let updatedWeek = getUpdatedWeek() {
                self.week = updatedWeek
            }
        }
    }
    
    // Calculer les jours travaillés uniquement
    private var workableDays: [WorkDay] {
        return week.days.filter { day in
            // Vérifier si ce jour est configuré comme un jour travaillé dans les paramètres
            return WorkSettings.shared.isWorkDay(day.date)
        }
    }
    
    private func getUpdatedWeek() -> WorkWeek? {
        for period in workViewModel.periods {
            if let updatedWeek = period.weeks.first(where: { $0.id == week.id }) {
                return updatedWeek
            }
        }
        return nil
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

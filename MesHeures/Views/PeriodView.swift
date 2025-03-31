import SwiftUI

struct PeriodView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @State private var period: WorkPeriod
    
    init(period: WorkPeriod) {
        _period = State(initialValue: period)
    }
    
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
                .padding(.horizontal)
            
            // Liste des semaines
            List {
                ForEach(period.weeks) { week in
                    NavigationLink {
                        WeekView(week: week)
                    } label: {
                        WeekSummaryRow(week: week)
                    }
                    .isDetailLink(true) // Ceci est important pour assurer la navigation correcte
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Période \(period.name)")
        .onAppear {
            // Assurez-vous que la période est à jour lorsque la vue apparaît
            if let updatedPeriod = workViewModel.periods.first(where: { $0.id == period.id }) {
                self.period = updatedPeriod
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

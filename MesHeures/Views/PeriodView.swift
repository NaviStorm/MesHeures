import SwiftUI

struct PeriodView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    @State private var period: WorkPeriod
    @State private var dragOffset = CGSize.zero
    
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
            .contentShape(Rectangle()) // Pour assurer que le geste capture toute la zone
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.dragOffset = gesture.translation
                    }
                    .onEnded { gesture in
                        // S'assurer que le geste est principalement horizontal et d'une amplitude suffisante
                        if abs(gesture.translation.width) > 50 && abs(gesture.translation.width) > abs(gesture.translation.height) {
                            navigateToAdjacentPeriod(gesture.translation.width > 0)
                        }
                        self.dragOffset = .zero
                    }
            )
            
            // Statistiques de la période
            let stats = workViewModel.getPeriodStatistics(for: period)
            StatisticsView(worked: stats.worked, expected: stats.expected, overtime: stats.overtime)
                .padding(.horizontal)
            
            // Liste des semaines avec swipe personnalisé
            ScrollView {
                VStack(spacing: 8) { // Augmenter l'espacement pour éviter les chevauchements
                    ForEach(period.weeks) { week in
                        SwipeableWeekRow(
                            week: week,
                            resetAction: {
                                resetWeek(week)
                            },
                            navigateAction: {
                                navigateToWeek(week)
                            }
                        )
                        .padding(.horizontal, 16)
                        .background(Color(.systemBackground)) // Fond blanc pour chaque row
                        .cornerRadius(8) // Arrondir les coins pour un effet visuel agréable
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Période \(period.name)")
        .onAppear {
            // Assurez-vous que la période est à jour lorsque la vue apparaît
            if let updatedPeriod = workViewModel.periods.first(where: { $0.id == period.id }) {
                self.period = updatedPeriod
            }
        }
    }
    
    private func navigateToAdjacentPeriod(_ isPrevious: Bool) {
        // Trouver l'index de la période actuelle
        guard let currentIndex = workViewModel.periods.firstIndex(where: { $0.id == period.id }) else {
            return
        }
        
        let targetIndex: Int
        if isPrevious {
            // Naviguer vers la période précédente
            targetIndex = currentIndex > 0 ? currentIndex - 1 : workViewModel.periods.count - 1
        } else {
            // Naviguer vers la période suivante
            targetIndex = (currentIndex + 1) % workViewModel.periods.count
        }
        
        // Mettre à jour la période affichée
        self.period = workViewModel.periods[targetIndex]
    }
    
    private func resetWeek(_ week: WorkWeek) {
        // Trouver l'index de la période et de la semaine
        guard let periodIndex = workViewModel.periods.firstIndex(where: { $0.id == period.id }),
              let weekIndex = workViewModel.periods[periodIndex].weeks.firstIndex(where: { $0.id == week.id }) else {
            return
        }
        
        // Réinitialiser les jours de la semaine
        for i in 0..<workViewModel.periods[periodIndex].weeks[weekIndex].days.count {
            // Réinitialiser uniquement les jours travaillés
            if workViewModel.periods[periodIndex].weeks[weekIndex].days[i].isWorkday {
                workViewModel.periods[periodIndex].weeks[weekIndex].days[i].clearTimes()
            }
        }
        
        // Mettre à jour la période locale
        if let updatedPeriod = workViewModel.periods.first(where: { $0.id == period.id }) {
            self.period = updatedPeriod
        }
        
        // Sauvegarder les modifications
        workViewModel.saveData()
    }
    
    private func navigateToWeek(_ week: WorkWeek) {
        // Utiliser le helper de navigation pour la transition vers WeekView
        navigationHelper.selectWeek(week)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

import SwiftUI

struct PeriodView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @State private var period: WorkPeriod
    @State private var dragOffset = CGSize.zero
    @State private var showingResetWeekAlert = false
    @State private var weekToReset: WorkWeek?
    
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
            
            // Liste des semaines
            List {
                ForEach(period.weeks) { week in
                    NavigationLink {
                        WeekView(week: week)
                    } label: {
                        WeekSummaryRow(week: week)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onEnded { gesture in
                                        // Si le geste est un glissement vers la gauche
                                        if gesture.translation.width < -50 {
                                            weekToReset = week
                                            showingResetWeekAlert = true
                                        }
                                    }
                            )
                    }
                    .isDetailLink(true)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .alert(isPresented: $showingResetWeekAlert) {
                Alert(
                    title: Text("Réinitialiser la semaine"),
                    message: Text("Voulez-vous réinitialiser les données de cette semaine ?"),
                    primaryButton: .destructive(Text("Réinitialiser")) {
                        if let weekToReset = weekToReset {
                            resetWeek(weekToReset)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

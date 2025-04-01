import SwiftUI

struct MainView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @State private var selectedTab = 0
    @State private var selectedWeek: WorkWeek? = nil
    @State private var navigateToWeek = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vue pour afficher la période en cours
            NavigationView {
                if let currentPeriod = workViewModel.currentPeriod {
                    PeriodView(period: currentPeriod)
                        .background(
                            // Navigation masquée pour WeekView
                            NavigationLink(
                                destination: Group {
                                    if let week = selectedWeek {
                                        WeekView(week: week)
                                    }
                                },
                                isActive: $navigateToWeek
                            ) {
                                EmptyView()
                            }
                        )
                } else {
                    Text("Période non disponible")
                        .onAppear {
                            // Forcer le chargement/mise à jour des données
                            workViewModel.loadData()
                            workViewModel.updateCurrentPeriod()
                        }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Période", systemImage: "calendar")
            }
            .tag(0)
            
            // Vue pour afficher les périodes par année
            PeriodsView()
                .environmentObject(workViewModel)
                .tabItem {
                    Label("Périodes", systemImage: "list.bullet")
                }
                .tag(1)
            
            // Vue des paramètres
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Paramètres", systemImage: "gear")
            }
            .tag(2)
        }
        .onAppear {
            // S'assurer que la période actuelle est chargée
            workViewModel.updateCurrentPeriod()
        }
        .environmentObject(NavigationHelper(selectWeek: { week in
            selectedWeek = week
            navigateToWeek = true
        }))
    }
}

// Helper pour la navigation entre vues
class NavigationHelper: ObservableObject {
    var selectWeek: (WorkWeek) -> Void
    
    init(selectWeek: @escaping (WorkWeek) -> Void) {
        self.selectWeek = selectWeek
    }
}

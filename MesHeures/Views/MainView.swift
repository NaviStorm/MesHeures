import SwiftUI

struct MainView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vue pour afficher la période en cours
            NavigationView {
                if let currentPeriod = workViewModel.currentPeriod {
                    PeriodView(period: currentPeriod)
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
            
            // Vue pour afficher toutes les périodes
            NavigationView {
                List {
                    ForEach(workViewModel.periods) { period in
                        NavigationLink {
                            PeriodView(period: period)
                        } label: {
                            HStack {
                                Text(period.name)
                                Spacer()
                                Text(period.formattedTotalWorkedTime)
                                
                                if period.containsCurrentDate() {
                                    Circle()
                                        .fill(WorkSettings.shared.currentPeriodColor)
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Périodes")
                .listStyle(InsetGroupedListStyle())
            }
            .navigationViewStyle(StackNavigationViewStyle())
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
    }
}

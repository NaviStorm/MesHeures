// Fichier: Views/MainView.swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject var workViewModel: WorkViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vue pour afficher la période en cours
            if let currentPeriod = workViewModel.currentPeriod {
                PeriodView(period: currentPeriod)
                    .tabItem {
                        Label("Période", systemImage: "calendar")
                    }
                    .tag(0)
            } else {
                Text("Période non disponible")
                    .tabItem {
                        Label("Période", systemImage: "calendar")
                    }
                    .tag(0)
            }
            
            // Vue pour afficher toutes les périodes
            List {
                ForEach(workViewModel.periods) { period in
                    NavigationLink(destination: PeriodView(period: period)) {
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
            .tabItem {
                Label("Périodes", systemImage: "list.bullet")
            }
            .tag(1)
            
            // Vue des paramètres
            SettingsView()
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



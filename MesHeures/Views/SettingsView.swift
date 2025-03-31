import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingResetAlert = false
    @State private var refreshID = UUID()
    @State private var showingLegalView = false
    @State private var isShowingMailView = false
    
    // On utilise @ObservedObject pour s'assurer que les changements sont bien observés
    @ObservedObject private var settings = WorkSettings.shared
    
    var body: some View {
        NavigationView {
            Form {
                // Section info application
                Section(header: Text("Information")) {
                    VStack(alignment: .center, spacing: 5) {
                        Image(systemName: "clock.badge.checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .padding(.bottom, 5)
                        
                        Text("MesHeures")
                            .font(.title)
                            .bold()
                        
                        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                        Text("Version \(version) (\(build))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Jours travaillés")) {
                    Stepper("Jours par semaine: \(settings.workDaysPerWeek)", value: $settings.workDaysPerWeek, in: 1...7)
                        .onChange(of: settings.workDaysPerWeek) { newValue in
                            settingsViewModel.saveSettings()
                        }
                    
                    ForEach(1..<8) { day in
                        let isSelected = settings.workDays.contains(day)
                        
                        Button(action: {
                            toggleWorkDay(day)
                        }) {
                            HStack {
                                Text(dayName(for: day))
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(settings.workDays.count <= 1 && isSelected)
                    }
                }
                
                Section(header: Text("Horaires")) {
                    HStack {
                        Text("Heures par semaine")
                        Spacer()
                        Text(formatTimeInterval(settings.weeklyWorkDuration))
                    }
                    
                    let weeklyHoursBinding = Binding<Double>(
                        get: { settings.weeklyWorkDuration / 3600 },
                        set: {
                            settings.weeklyWorkDuration = $0 * 3600
                            settingsViewModel.saveSettings()
                        }
                    )
                    
                    Slider(value: weeklyHoursBinding, in: 20...50, step: 0.5)
                        .padding(.horizontal)
                    
                    DatePicker("Début journée", selection: $settings.dayStartTime, displayedComponents: .hourAndMinute)
                        .onChange(of: settings.dayStartTime) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    DatePicker("Fin journée", selection: $settings.dayEndTime, displayedComponents: .hourAndMinute)
                        .onChange(of: settings.dayEndTime) { _ in
                            settingsViewModel.saveSettings()
                        }
                }
                
                Section(header: Text("Pauses et Limites")) {
                    TimeIntervalPicker(title: "Pause minimale", value: Binding(
                        get: { settings.minLunchDuration },
                        set: {
                            settings.minLunchDuration = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .minute, range: 10...120, step: 5)
                    
                    TimeIntervalPicker(title: "Maximum par jour", value: Binding(
                        get: { settings.maxDayDuration },
                        set: {
                            settings.maxDayDuration = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 5...14, step: 0.5)
                    
                    TimeIntervalPicker(title: "Maximum heures supp./semaine", value: Binding(
                        get: { settings.maxWeeklyOvertime },
                        set: {
                            settings.maxWeeklyOvertime = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 1...10, step: 1)
                    
                    TimeIntervalPicker(title: "Maximum heures supp./période", value: Binding(
                        get: { settings.maxPeriodOvertime },
                        set: {
                            settings.maxPeriodOvertime = $0
                            settingsViewModel.saveSettings()
                        }
                    ), unit: .hour, range: 5...20, step: 1)
                }
                
                Section(header: Text("Apparence")) {
                    ColorPicker("Couleur période actuelle", selection: $settings.currentPeriodColor)
                        .onChange(of: settings.currentPeriodColor) { _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    ColorPicker("Couleur semaine actuelle", selection: $settings.currentWeekColor)
                        .onChange(of: settings.currentWeekColor) { _ in
                            settingsViewModel.saveSettings()
                        }
                }
                
                Section(header: Text("Assistance")) {
                    Button(action: {
                        // Ouvrir l'application mail
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            // Fallback pour les appareils qui ne peuvent pas envoyer de mail
                            if let url = URL(string: "mailto:hirtrey@me.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("Nous contacter")
                        }
                    }
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(isShowing: $isShowingMailView, recipient: "hirtrey@me.com", subject: "Support MesHeures")
                    }
                    
                    NavigationLink(destination: LegalView()) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Mentions légales / CGV")
                        }
                    }
                }
                
                Section(header: Text("Réinitialisation")) {
                    Button("Réinitialiser aux valeurs par défaut") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                .alert(isPresented: $showingResetAlert) {
                    Alert(
                        title: Text("Réinitialiser les paramètres"),
                        message: Text("Êtes-vous sûr de vouloir réinitialiser tous les paramètres à leurs valeurs par défaut ?"),
                        primaryButton: .destructive(Text("Réinitialiser")) {
                            settingsViewModel.resetToDefaults()
                            // Force le redémarrage complet de la vue
                            refreshID = UUID()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .id(refreshID) // La vue redémarrera si refreshID change
            .navigationTitle("Paramètres")
            .onDisappear {
                // S'assurer que les paramètres sont sauvegardés lors de la fermeture de la vue
                settingsViewModel.saveSettings()
            }
        }
    }
    
    private func toggleWorkDay(_ day: Int) {
        if settings.workDays.contains(day) {
            // S'assurer qu'il y a toujours au moins un jour sélectionné
            if settings.workDays.count > 1 {
                settings.workDays.removeAll { $0 == day }
            }
        } else {
            settings.workDays.append(day)
            settings.workDays.sort()
        }
        
        // Mettre à jour le nombre de jours par semaine
        settings.workDaysPerWeek = settings.workDays.count
        
        // Sauvegarder les changements
        settingsViewModel.saveSettings()
    }
    
    private func dayName(for dayIndex: Int) -> String {
        let days = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
        return days[dayIndex - 1]
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

// Vue pour afficher les mentions légales
struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Mentions Légales")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Group {
                    Text("Politique de confidentialité")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    
                    Text("L'application MesHeures est conçue pour respecter votre vie privée. Aucune donnée personnelle n'est collectée, stockée ou partagée avec des tiers.")
                    
                    Text("Toutes les données saisies dans l'application sont stockées uniquement sur votre appareil et ne sont jamais transmises à un serveur externe ou à un tiers.")
                }
                
                Group {
                    Text("Utilisation des données")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                        .padding(.top, 10)
                    
                    Text("MesHeures n'utilise pas de cookies et n'effectue aucun suivi de votre activité.")
                    
                    Text("L'application n'a pas besoin d'accès à Internet pour fonctionner et toutes les opérations sont effectuées localement sur votre appareil.")
                }
                
                Group {
                    Text("Conditions générales d'utilisation")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                        .padding(.top, 10)
                    
                    Text("L'application MesHeures est fournie \"telle quelle\", sans garantie d'aucune sorte, expresse ou implicite.")
                    
                    Text("L'utilisateur assume l'entière responsabilité de l'utilisation de cette application.")
                    
                    Text("Les développeurs de MesHeures ne peuvent être tenus responsables des erreurs ou omissions dans les calculs effectués par l'application.")
                }
            }
            .padding()
        }
        .navigationTitle("Mentions légales")
    }
}

// Vue pour envoyer un email
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var recipient: String
    var subject: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        
        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            isShowing = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        
        // Ajouter des informations système au corps du mail
        let deviceInfo = """
        
        --
        Informations système:
        - Appareil: \(UIDevice.current.model)
        - iOS: \(UIDevice.current.systemVersion)
        - App version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        """
        
        vc.setMessageBody(deviceInfo, isHTML: false)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

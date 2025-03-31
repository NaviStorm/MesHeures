import Foundation
import SwiftUI

enum AbsenceType: String, CaseIterable, Codable {
    case CA = "CA"           // Congés annuels
    case RTT = "RTT"         // Réduction du temps de travail
    case RTT_HALF = "RTT-1"  // Demi-journée RTT
    case TRMF = "TRMF"       // Temps réduit pour motif familial
    case MAL = "MAL"         // Maladie
    case FER = "FER"         // Jour férié
    case REC = "REC"         // Récupération
    case REC_HALF = "REC-1"  // Demi-journée de récupération
    case ANC = "ANC"         // Ancienneté
    case FRA = "FRA"         // Formation
    
    // Cases spéciales pour les demi-journées
    case CA_AM = "CA (Matin)"           // CA le matin
    case CA_PM = "CA (Après-midi)"      // CA l'après-midi
    case RTT_AM = "RTT (Matin)"         // RTT le matin
    case RTT_PM = "RTT (Après-midi)"    // RTT l'après-midi
    case MAL_AM = "MAL (Matin)"         // MAL le matin
    case MAL_PM = "MAL (Après-midi)"    // MAL l'après-midi
    case FER_AM = "FER (Matin)"         // FER le matin
    case FER_PM = "FER (Après-midi)"    // FER l'après-midi
    case REC_AM = "REC (Matin)"         // REC le matin
    case REC_PM = "REC (Après-midi)"    // REC l'après-midi
    case ANC_AM = "ANC (Matin)"         // ANC le matin
    case ANC_PM = "ANC (Après-midi)"    // ANC l'après-midi
    case FRA_AM = "FRA (Matin)"         // FRA le matin
    case FRA_PM = "FRA (Après-midi)"    // FRA l'après-midi
    
    var color: Color {
        switch self {
        case .CA, .CA_AM, .CA_PM:
            return .blue
        case .RTT, .RTT_HALF, .RTT_AM, .RTT_PM:
            return .green
        case .TRMF:
            return .orange
        case .MAL, .MAL_AM, .MAL_PM:
            return .red
        case .FER, .FER_AM, .FER_PM:
            return .purple
        case .REC, .REC_HALF, .REC_AM, .REC_PM:
            return .yellow
        case .ANC, .ANC_AM, .ANC_PM:
            return .teal
        case .FRA, .FRA_AM, .FRA_PM:
            return .indigo
        }
    }
    
    var isHalfDay: Bool {
        return self == .RTT_HALF || self == .REC_HALF ||
               self.rawValue.contains("Matin") || self.rawValue.contains("Après-midi")
    }
    
    var isMorning: Bool {
        return self.rawValue.contains("Matin")
    }
    
    var isAfternoon: Bool {
        return self.rawValue.contains("Après-midi")
    }
    
    // Retourne la base du type d'absence (sans mention matin ou après-midi)
    var baseType: String {
        switch self {
        case .CA_AM, .CA_PM:
            return "CA"
        case .RTT_AM, .RTT_PM:
            return "RTT"
        case .MAL_AM, .MAL_PM:
            return "MAL"
        case .FER_AM, .FER_PM:
            return "FER"
        case .REC_AM, .REC_PM:
            return "REC"
        case .ANC_AM, .ANC_PM:
            return "ANC"
        case .FRA_AM, .FRA_PM:
            return "FRA"
        default:
            return self.rawValue
        }
    }
    
    // Groupe les types d'absence pour les menus déroulants
    static var groupedCategories: [(String, [AbsenceType])] {
        return [
            ("Congés", [.CA, .CA_AM, .CA_PM]),
            ("RTT", [.RTT, .RTT_HALF, .RTT_AM, .RTT_PM]),
            ("Maladie", [.MAL, .MAL_AM, .MAL_PM]),
            ("Férié", [.FER, .FER_AM, .FER_PM]),
            ("Récupération", [.REC, .REC_HALF, .REC_AM, .REC_PM]),
            ("Ancienneté", [.ANC, .ANC_AM, .ANC_PM]),
            ("Formation", [.FRA, .FRA_AM, .FRA_PM]),
            ("Autres", [.TRMF])
        ]
    }
}

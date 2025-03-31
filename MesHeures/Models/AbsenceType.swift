// Fichier: Models/AbsenceType.swift
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
    
    var color: Color {
        switch self {
        case .CA:
            return .blue
        case .RTT, .RTT_HALF:
            return .green
        case .TRMF:
            return .orange
        case .MAL:
            return .red
        case .FER:
            return .purple
        case .REC, .REC_HALF:
            return .yellow
        case .ANC:
            return .teal
        case .FRA:
            return .indigo
        }
    }
    
    var isHalfDay: Bool {
        return self == .RTT_HALF || self == .REC_HALF
    }
}



// Fichier: Views/Components/StatisticsView.swift
import SwiftUI

struct StatisticsView: View {
    var worked: TimeInterval
    var expected: TimeInterval
    var overtime: TimeInterval
    
    var body: some View {
        HStack(spacing: 20) {
            StatBox(title: "Travaillé", value: TimeCalculator.formatTimeInterval(worked))
            StatBox(title: "Attendu", value: TimeCalculator.formatTimeInterval(expected))
            StatBox(title: "Supplémentaire", value: TimeCalculator.formatTimeInterval(overtime))
        }
    }
}

struct StatBox: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}



// Fichier: Views/Components/TimeIntervalPicker.swift
import SwiftUI

enum TimeUnit {
    case minute, hour
}

struct TimeIntervalPicker: View {
    var title: String
    @Binding var value: TimeInterval
    var unit: TimeUnit
    var range: ClosedRange<Double>
    var step: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(formattedValue)
            }
            
            Slider(value: convertedBinding, in: range, step: step)
                .padding(.horizontal)
        }
    }
    
    private var convertedBinding: Binding<Double> {
        Binding<Double>(
            get: {
                switch unit {
                case .minute:
                    return value / 60
                case .hour:
                    return value / 3600
                }
            },
            set: {
                switch unit {
                case .minute:
                    value = $0 * 60
                case .hour:
                    value = $0 * 3600
                }
            }
        )
    }
    
    private var formattedValue: String {
        switch unit {
        case .minute:
            let minutes = Int(value / 60)
            return "\(minutes) min"
        case .hour:
            let hours = Int(value / 3600)
            let minutes = (Int(value) % 3600) / 60
            return String(format: "%02d:%02d", hours, minutes)
        }
    }
}



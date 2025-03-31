// Fichier: Views/Components/TimePickerRow.swift
import SwiftUI

struct TimePickerRow: View {
    var title: String
    @Binding var time: Date
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
    }
}



// Fichier: Views/Components/AbsenceTypePicker.swift
import SwiftUI

struct AbsenceTypePicker: View {
    @Binding var selectedType: AbsenceType?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                // Option pour jour travaillé normal
                Button(action: {
                    selectedType = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text("Travaillé")
                        Spacer()
                        if selectedType == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                // Options pour tous les types d'absence
                ForEach(AbsenceType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(type.rawValue)
                            Spacer()
                            if selectedType == type {
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundColor(type.color)
                    }
                }
            }
            .navigationTitle("Type d'absence")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}



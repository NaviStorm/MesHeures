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
                
                // Groupes d'absences
                ForEach(AbsenceType.groupedCategories, id: \.0) { groupName, types in
                    Section(header: Text(groupName)) {
                        ForEach(types, id: \.self) { type in
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

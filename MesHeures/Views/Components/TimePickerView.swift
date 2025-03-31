import SwiftUI

struct TimePickerView: View {
    @Binding var selectedDate: Date
    var label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
                .padding(.bottom, 4)
            
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
        }
    }
}

struct TimePickerView_Previews: PreviewProvider {
    @State static var testDate = Date()
    
    static var previews: some View {
        TimePickerView(selectedDate: $testDate, label: "Heure de début")
            .padding()
    }
}

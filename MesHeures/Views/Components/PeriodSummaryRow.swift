import SwiftUI

struct PeriodSummaryRow: View {
    var period: WorkPeriod
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(period.name)
                    .font(.headline)
                Spacer()
                Text("\(formatDate(period.startDate)) - \(formatDate(period.endDate))")
                    .font(.caption)
            }
            
            HStack {
                Text("Travaillé: \(period.formattedTotalWorkedTime)")
                Spacer()
                Text("Supp.: \(period.formattedTotalOvertimeHours)")
                
                if period.containsCurrentDate() {
                    Circle()
                        .fill(WorkSettings.shared.currentPeriodColor)
                        .frame(width: 10, height: 10)
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

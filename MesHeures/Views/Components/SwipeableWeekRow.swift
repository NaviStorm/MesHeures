import SwiftUI

struct SwipeableWeekRow: View {
    let week: WorkWeek
    let resetAction: () -> Void
    let navigateAction: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    // Constantes pour le comportement du swipe
    private let deleteWidth: CGFloat = 80
    private let swipeThreshold: CGFloat = 60
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Fond rouge avec icône de poubelle
            HStack {
                Spacer()
                Button(action: {
                    self.resetAction()
                    withAnimation {
                        self.offset = 0
                        self.isSwiped = false
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: deleteWidth)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
            
            // Contenu principal qui se déplace
            HStack {
                WeekSummaryRow(week: week)
                    .contentShape(Rectangle())
                    .background(Color(.systemBackground))
                    .onTapGesture {
                        if isSwiped {
                            withAnimation {
                                offset = 0
                                isSwiped = false
                            }
                        } else {
                            navigateAction()
                        }
                    }
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Si c'est un glissement vers la gauche ou si déjà glissé
                        if gesture.translation.width < 0 || isSwiped {
                            // Limiter le glissement à deleteWidth
                            let potentialOffset = gesture.translation.width
                            offset = max(min(potentialOffset, 0), -deleteWidth)
                        }
                    }
                    .onEnded { gesture in
                        withAnimation {
                            if gesture.translation.width < -swipeThreshold {
                                // Glissement vers la gauche
                                offset = -deleteWidth
                                isSwiped = true
                            } else {
                                // Retour à la position initiale
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
        .frame(height: 48)
        .clipShape(Rectangle()) // Assure que rien ne dépasse
        .background(Color(.systemBackground)) // Fond blanc pour éviter les bandes rouges
    }
}

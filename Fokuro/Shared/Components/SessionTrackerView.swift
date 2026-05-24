import SwiftUI

// MARK: - SessionTrackerView
//
// Displays 4 session indicators (●).
// Completed sessions are filled with the mode accent; pending are dim.

struct SessionTrackerView: View {

    let completedCount: Int   // 0…4
    let mode:           TimerMode
    let totalSessions:  Int = 4

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalSessions, id: \.self) { index in
                Capsule()
                    .fill(index < completedCount
                          ? Color.fokuroAccent(for: mode)
                          : Color.fokuroBorder)
                    .frame(width: index < completedCount ? 20 : 10, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: completedCount)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(completedCount) / \(totalSessions) oturum tamamlandı")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.fokuroBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            ForEach(0...4, id: \.self) { n in
                SessionTrackerView(completedCount: n, mode: .focus)
            }
        }
    }
}

import SwiftUI

// MARK: - SessionTrackerView

struct SessionTrackerView: View {

    let completedCount: Int   // 0…4
    let mode:           TimerMode
    let totalSessions:  Int = 4

    // MARK: - Derived

    /// Focus modunda: içinde olduğumuz session (completedCount + 1)
    /// Break modunda: son tamamlanan session (completedCount)
    private var displayCount: Int {
        switch mode {
        case .focus:
            return min(completedCount + 1, totalSessions)
        case .shortBreak, .longBreak:
            return min(max(completedCount, 1), totalSessions)
        }
    }

    private var remaining: Int { max(0, totalSessions - displayCount) }

    private var subtitleText: String {
        switch remaining {
        case 0:  return String(localized: "Long break next!")
        case 1:  return String(localized: "1 more until long break")
        case 2:  return String(localized: "2 more until long break")
        case 3:  return String(localized: "3 more until long break")
        default: return String(localized: "4 more until long break")
        }
    }

    private func barOpacity(at index: Int) -> Double {
        if index < completedCount {
            return 1.0   // tamamlandı → tam renk
        } else if index == completedCount && mode == .focus {
            return 0.45  // focus'tayız, bu bar devam ediyor → orta soluk
        } else {
            return 0.15  // bekliyor → en soluk, hepsi aynı
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ── Top row ──────────────────────────────────────
            HStack(alignment: .firstTextBaseline) {
                // "1 / 4  sessions"
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(displayCount)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.fokuroText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: displayCount)

                    Text("/ \(totalSessions)")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.fokuroSubtext)

                    Text(String(localized: "sessions"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.fokuroSubtext)
                        .padding(.leading, 2)
                }

                Spacer()

                // Mode badge
                Text(mode.displayName.lowercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.fokuroAccent(for: mode))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.fokuroAccent(for: mode).opacity(0.15))
                    )
                    .animation(.easeInOut(duration: 0.3), value: mode)
            }

            // ── Progress bars ─────────────────────────────────
            HStack(spacing: 6) {
                ForEach(0..<totalSessions, id: \.self) { index in
                    Capsule()
                        .fill(Color.fokuroAccent(for: mode).opacity(barOpacity(at: index)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 8)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.6),
                            value: completedCount
                        )
                }
            }

            // ── Subtitle ──────────────────────────────────────
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.fokuroSubtext)
                Text(subtitleText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.fokuroSubtext)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: remaining)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.fokuroSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.fokuroBorder, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 24)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(completedCount) / \(totalSessions) sessions completed, \(subtitleText)")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.fokuroBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            SessionTrackerView(completedCount: 0, mode: .focus)
            SessionTrackerView(completedCount: 1, mode: .shortBreak)
            SessionTrackerView(completedCount: 3, mode: .focus)
            SessionTrackerView(completedCount: 4, mode: .longBreak)
        }
    }
}

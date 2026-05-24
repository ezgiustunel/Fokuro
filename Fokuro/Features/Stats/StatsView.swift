import SwiftUI

// MARK: - StatsView

struct StatsView: View {

    @StateObject private var viewModel = StatsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true

    var body: some View {
        ZStack {
            Color.fokuroBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerCards
                    weeklyChart
                    pomodoroTips
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.fokuroBackground, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .onAppear { viewModel.refresh() }
    }

    // MARK: - Header summary cards

    private var headerCards: some View {
        HStack(spacing: 14) {
            StatCard(
                value:    "\(viewModel.todayCount)",
                label:    "Today",
                icon:     "checkmark.circle.fill",
                color:    .fokuroFocus
            )
            StatCard(
                value:    "\(viewModel.totalMinutes)",
                label:    "Minutes",
                icon:     "clock.fill",
                color:    .fokuroShortBreak
            )
            StatCard(
                value:    "\(viewModel.weekCounts.reduce(0) { $0 + $1.count })",
                label:    "This Week",
                icon:     "calendar.badge.checkmark",
                color:    .fokuroLongBreak
            )
        }
    }

    // MARK: - Weekly bar chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 7 Days")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.fokuroSubtext)
                .textCase(.uppercase)
                .tracking(1.5)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(viewModel.weekCounts) { stat in
                    WeekBar(stat: stat, maxCount: viewModel.weekCounts.map(\.count).max() ?? 1)
                }
            }
            .frame(height: 140)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.fokuroSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.fokuroBorder, lineWidth: 0.5)
                    )
            )
        }
    }

    // MARK: - Tips

    private var pomodoroTips: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About the Technique")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.fokuroSubtext)
                .textCase(.uppercase)
                .tracking(1.5)

            VStack(spacing: 0) {
                ForEach(tips.indices, id: \.self) { i in
                    TipRow(tip: tips[i])
                    if i < tips.count - 1 {
                        Divider().background(Color.fokuroBorder).padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.fokuroSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.fokuroBorder, lineWidth: 0.5)
                    )
            )
        }
    }

    private var tips: [(icon: String, text: String)] {[
        ("brain.head.profile", String(localized: "tip.focus")),
        ("repeat.circle.fill", String(localized: "tip.cycle")),
        ("xmark.circle.fill",  String(localized: "tip.notifications")),
        ("drop.fill",          String(localized: "tip.hydration")),
    ]}
}

// MARK: - StatCard

private struct StatCard: View {
    let value: String
    let label: String
    let icon:  String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.fokuroText)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.fokuroSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.fokuroSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.fokuroBorder, lineWidth: 0.5)
                )
        )
    }
}

// MARK: - WeekBar

private struct WeekBar: View {
    let stat:     StatsViewModel.DayStat
    let maxCount: Int

    private var normalizedHeight: CGFloat {
        guard maxCount > 0, stat.count > 0 else { return 4 }
        return max(CGFloat(stat.count) / CGFloat(maxCount), 0.05)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(stat.date)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(stat.count)")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(stat.count > 0 ? .fokuroText : .fokuroMuted)

            GeometryReader { geo in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isToday ? Color.fokuroFocus : Color.fokuroSurfaceElevated)
                        .frame(height: geo.size.height * normalizedHeight)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: stat.count)
                }
            }

            Text(stat.label)
                .font(.system(size: 10, weight: isToday ? .semibold : .regular))
                .foregroundStyle(isToday ? .fokuroFocus : .fokuroSubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - TipRow

private struct TipRow: View {
    let tip: (icon: String, text: String)

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.icon)
                .font(.system(size: 15))
                .foregroundStyle(Color.fokuroFocus)
                .frame(width: 24)
            Text(tip.text)
                .font(.subheadline)
                .foregroundStyle(.fokuroText)
        }
        .padding(16)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StatsView()
    }
    .preferredColorScheme(.dark)
}

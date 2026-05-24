import SwiftUI
import Combine

@MainActor
final class StatsViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var todayCount:  Int = 0
    @Published private(set) var weekCounts:  [DayStat] = []
    @Published private(set) var totalMinutes: Int = 0

    // MARK: - Models

    struct DayStat: Identifiable {
        let id    = UUID()
        let label: String   // "Pzt", "Sal", etc.
        let date:  Date
        let count: Int
    }

    // MARK: - Init

    init() {
        refresh()
    }

    // MARK: - Public

    func refresh() {
        todayCount    = loadCount(for: Date())
        weekCounts    = buildWeekStats()
        totalMinutes  = todayCount * 25
    }

    // MARK: - Private helpers

    private func loadCount(for date: Date) -> Int {
        UserDefaults.standard.integer(forKey: statsKey(for: date))
    }

    private func statsKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "stats_\(f.string(from: date))"
    }

    private func buildWeekStats() -> [DayStat] {
        let calendar  = Calendar.current
        let formatter = DateFormatter()
        formatter.locale   = Locale.current
        formatter.dateFormat = "EEE"

        return (0..<7).compactMap { offset -> DayStat? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            return DayStat(
                label: formatter.string(from: date).capitalized,
                date:  date,
                count: loadCount(for: date)
            )
        }
        .reversed()
    }
}

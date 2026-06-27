import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @ObservedObject var viewModel: SettingsViewModel
    let onDismiss: () -> Void

    // Local edit state (only committed on Save)
    @State private var workDraft:       Int    = 25
    @State private var shortBreakDraft: Int    = 5
    @State private var longBreakDraft:  Int    = 15

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fokuroBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        timerDurationsSection
                        appearanceSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.fokuroBackground, for: .navigationBar)
            .toolbarColorScheme(viewModel.isDarkMode ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(Color.fokuroSubtext)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.fokuroFocus)
                }
            }
        }
        .onAppear {
            workDraft       = viewModel.workDuration
            shortBreakDraft = viewModel.shortBreakDuration
            longBreakDraft  = viewModel.longBreakDuration
        }
        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
    }

    // MARK: - Sections

    private var timerDurationsSection: some View {
        SettingsCard(title: "Timer Durations", icon: "timer") {
            DurationStepper(
                label:    "Focus",
                value:    $workDraft,
                range:    viewModel.workDurationRange,
                color:    .fokuroFocus
            )
            Divider().background(Color.fokuroBorder)

            DurationStepper(
                label:    "Short Break",
                value:    $shortBreakDraft,
                range:    viewModel.shortBreakDurationRange,
                color:    .fokuroShortBreak
            )
            Divider().background(Color.fokuroBorder)

            DurationStepper(
                label:    "Long Break",
                value:    $longBreakDraft,
                range:    viewModel.longBreakDurationRange,
                color:    .fokuroLongBreak
            )
        }
    }

    private var appearanceSection: some View {
        SettingsCard(title: "Appearance", icon: "paintbrush.fill") {
            HStack {
                Label("Dark Mode", systemImage: viewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundStyle(.fokuroText)
                Spacer()
                Toggle("", isOn: $viewModel.isDarkMode)
                    .tint(.fokuroFocus)
            }
        }
    }

    private var aboutSection: some View {
        SettingsCard(title: "About", icon: "info.circle.fill") {
            HStack {
                Text("Fokuro")
                    .foregroundStyle(.fokuroText)
                Spacer()
                Text("v1.4")
                    .foregroundStyle(.fokuroSubtext)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Save

    private func save() {
        viewModel.workDuration       = workDraft
        viewModel.shortBreakDuration = shortBreakDraft
        viewModel.longBreakDuration  = longBreakDraft
        viewModel.applyAndDismiss()
        onDismiss()
    }
}

// MARK: - SettingsCard

private struct SettingsCard<Content: View>: View {
    let title:   String
    let icon:    String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.fokuroFocus)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.fokuroSubtext)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }
            .padding(.bottom, 10)

            VStack(spacing: 14) {
                content()
            }
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
}

// MARK: - DurationStepper

private struct DurationStepper: View {
    let label: String
    @Binding var value: Int
    let range:  ClosedRange<Int>
    let color:  Color

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.fokuroText)

            Spacer()

            HStack(spacing: 16) {
                Button {
                    if value > range.lowerBound { value -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(value > range.lowerBound ? color : .fokuroMuted)
                }

                Text("\(value) \(String(localized: "min"))")
                    .font(.system(size: 15, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.fokuroText)
                    .frame(minWidth: 52)

                Button {
                    if value < range.upperBound { value += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(value < range.upperBound ? color : .fokuroMuted)
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(audioService: MockAudioService()),
        onDismiss: {}
    )
}

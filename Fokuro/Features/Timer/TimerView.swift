import SwiftUI

// MARK: - TimerView

struct TimerView: View {

    @ObservedObject var viewModel: TimerViewModel
    var rewardedAdService: RewardedAdService

    // Injected by parent so a single source of truth drives the entire app
    @Binding var isDarkMode: Bool
    @Binding var selectedSound: AmbientSound

    let audioService: AudioService

    // MARK: - Local state

    @State private var showSettings = false
    @State private var controlsScale: CGFloat = 1


    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(maxHeight: 24)

                modeSelector
                    .padding(.bottom, 28)

                timerRingSection

                Spacer(minLength: 0)
                    .frame(maxHeight: 32)

                controlButtons
                    .padding(.bottom, 32)

                soundSection
                    .padding(.bottom, 32)

                sessionTracker
                    .padding(.bottom, 16)

                Spacer(minLength: 0)
                    .frame(maxHeight: 16)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showSettings) {
            SettingsView(
                viewModel: SettingsViewModel(audioService: audioService),
                onDismiss: {
                    viewModel.applySettings()
                    showSettings = false
                }
            )
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color.fokuroBackground
                .ignoresSafeArea()

            // Subtle radial gradient behind the ring
            RadialGradient(
                colors: [
                    Color.fokuroGlow(for: viewModel.currentMode).opacity(viewModel.isRunning ? 0.3 : 0.12),
                    Color.clear
                ],
                center: .center,
                startRadius: 60,
                endRadius: 260
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1), value: viewModel.isRunning)
            .animation(.easeInOut(duration: 0.5), value: viewModel.currentMode)
        }
    }

    // MARK: - Navigation bar

    private var navigationBar: some View {
        HStack {
            // App logo + name
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.fokuroAccent(for: viewModel.currentMode))
                Text("Fokuro")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.fokuroText)
            }

            Spacer()

            HStack(spacing: 16) {
                // Dark / Light mode toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDarkMode.toggle()
                    }
                } label: {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.fokuroSubtext)
                }
                .accessibilityLabel(isDarkMode ? "Switch to light mode" : "Switch to dark mode")

                // Settings
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.fokuroSubtext)
                }
                .accessibilityLabel("Settings")
            }
        }
    }

    // MARK: - Mode selector

    private var modeSelector: some View {
        HStack(spacing: 6) {
            ForEach(TimerMode.allCases, id: \.self) { mode in
                ModeChip(
                    mode:       mode,
                    isSelected: viewModel.currentMode == mode,
                    onTap: {
                        viewModel.switchMode(mode)
                    }
                )
            }
        }
        .padding(5)
        .background(
            Capsule().fill(Color.fokuroSurface)
        )
    }

    // MARK: - Timer ring + time display

    private var timerRingSection: some View {
        ZStack {
            ProgressRingView(
                progress:  viewModel.progress,
                mode:      viewModel.currentMode,
                isRunning: viewModel.isRunning,
                lineWidth: 16
            )
            .frame(width: 260, height: 260)

            VStack(spacing: 6) {
                // Mode icon
                Image(systemName: viewModel.currentMode.icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Color.fokuroAccent(for: viewModel.currentMode))
                    .animation(.easeInOut, value: viewModel.currentMode)

                // Big clock
                Text(viewModel.formattedTime)
                    .font(.system(size: 62, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.fokuroText)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: viewModel.timeRemaining)

                // Mode label
                Text(viewModel.currentMode.displayName.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(Color.fokuroSubtext)
            }
        }
    }

    // MARK: - Session tracker

    private var sessionTracker: some View {
        SessionTrackerView(
            completedCount: viewModel.completedSessionsInCycle,
            mode:           viewModel.currentMode
        )
    }

    // MARK: - Control buttons

    private var controlButtons: some View {
        HStack(spacing: 24) {
            // Reset
            CircleButton(
                icon:            "arrow.counterclockwise",
                size:            48,
                foregroundColor: .fokuroSubtext,
                backgroundColor: .fokuroSurface,
                action:          viewModel.reset
            )

            // Play / Pause (primary CTA)
            CircleButton(
                icon:            viewModel.isRunning ? "pause.fill" : "play.fill",
                size:            72,
                foregroundColor: .black,
                backgroundColor: Color.fokuroAccent(for: viewModel.currentMode),
                action:          viewModel.startOrPause
            )
            .scaleEffect(controlsScale)
            .onTapGesture {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    controlsScale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        controlsScale = 1
                    }
                }
                viewModel.startOrPause()
            }

            // Skip
            CircleButton(
                icon:            "forward.end.fill",
                size:            48,
                foregroundColor: .fokuroSubtext,
                backgroundColor: .fokuroSurface,
                action:          viewModel.skip
            )
        }
    }

    // MARK: - Reward button

    private var isBreakMode: Bool {
        viewModel.currentMode == .shortBreak || viewModel.currentMode == .longBreak
    }

    private var rewardButton: some View {
        Button {
            rewardedAdService.showAd {
                viewModel.earnExtraBreak()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text(String(localized: "+5 min break · Watch ad"))
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(rewardedAdService.isAdReady ? .black : Color.fokuroMuted)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(rewardedAdService.isAdReady
                          ? Color.fokuroAccent(for: viewModel.currentMode)
                          : Color.fokuroSurface)
                    .overlay(
                        Capsule()
                            .stroke(Color.fokuroBorder, lineWidth: rewardedAdService.isAdReady ? 0 : 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isBreakMode || !rewardedAdService.isAdReady)
        .opacity(isBreakMode ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: isBreakMode)
        .animation(.easeInOut(duration: 0.2), value: rewardedAdService.isAdReady)
    }

    // MARK: - Sound picker section

    private var soundSection: some View {
        SoundPickerView(
            selectedSound:   $selectedSound,
            mode:            viewModel.currentMode,
            onSoundSelected: { sound in viewModel.soundSelected(sound) }
        )
    }
}

// MARK: - ModeChip

private struct ModeChip: View {
    let mode:       TimerMode
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(mode.displayName)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .black : Color.fokuroSubtext)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.fokuroAccent(for: mode) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - CircleButton

private struct CircleButton: View {
    let icon:            String
    let size:            CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    let action:          () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .background(Circle().fill(backgroundColor))
                .overlay(Circle().stroke(Color.fokuroBorder.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let timerService        = MockTimerService()
    let audioService        = MockAudioService()
    let notificationService = MockNotificationService()
    let vm = TimerViewModel(
        timerService:        timerService,
        audioService:        audioService,
        notificationService: notificationService
    )

    return TimerView(
        viewModel:         vm,
        rewardedAdService: RewardedAdService(),
        isDarkMode:        .constant(true),
        selectedSound:     .constant(.none),
        audioService:      AudioService()
    )
}

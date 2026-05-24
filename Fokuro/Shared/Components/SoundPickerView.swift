import SwiftUI

// MARK: - SoundPickerView
//
// A horizontally scrolling chip list for picking ambient sounds,
// plus a volume slider that appears when a sound is selected.

struct SoundPickerView: View {

    @Binding var selectedSound: AmbientSound
    @Binding var volume:        Double
    var mode: TimerMode = .focus
    let onSoundSelected: (AmbientSound) -> Void
    let onVolumeChanged:  (Double) -> Void

    var body: some View {
        VStack(spacing: 14) {
            // ── Sound chips ───────────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AmbientSound.allCases) { sound in
                        SoundChip(
                            sound:      sound,
                            isSelected: selectedSound == sound,
                            accent:     Color.fokuroAccent(for: mode),
                            onTap: {
                                selectedSound = sound
                                onSoundSelected(sound)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            // ── Volume slider (only when something is playing) ────────────
            if selectedSound != .none {
                HStack(spacing: 12) {
                    Image(systemName: "speaker.fill")
                        .font(.caption)
                        .foregroundStyle(.fokuroSubtext)

                    Slider(value: $volume, in: 0...1) { _ in
                        onVolumeChanged(volume)
                    }
                    .tint(Color.fokuroAccent(for: mode))

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.caption)
                        .foregroundStyle(.fokuroSubtext)
                }
                .padding(.horizontal, 28)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedSound)
    }
}

// MARK: - SoundChip

private struct SoundChip: View {

    let sound:      AmbientSound
    let isSelected: Bool
    let accent:     Color
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: sound.icon)
                    .font(.system(size: 13, weight: .medium))
                Text(sound.displayName)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isSelected ? .black : .fokuroSubtext)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? accent : Color.fokuroSurface)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.fokuroBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(sound.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.fokuroBackground.ignoresSafeArea()
        SoundPickerView(
            selectedSound: .constant(.rain),
            volume:        .constant(0.6),
            onSoundSelected: { _ in },
            onVolumeChanged:  { _ in }
        )
    }
}

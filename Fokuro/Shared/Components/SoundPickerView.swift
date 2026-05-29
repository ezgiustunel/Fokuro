import SwiftUI

// MARK: - SoundPickerView

struct SoundPickerView: View {

    @Binding var selectedSound: AmbientSound
    var mode: TimerMode = .focus
    let onSoundSelected: (AmbientSound) -> Void

    var body: some View {
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
            selectedSound:   .constant(.rain),
            onSoundSelected: { _ in }
        )
    }
}

# Fokuro – Ambient Audio Assets

Place the following MP3 files in this folder and add them to the Xcode target:

| Filename          | Description                         |
|-------------------|-------------------------------------|
| `lofi.mp3`        | Lo-fi hip-hop loop (~3-5 min)       |
| `rain.mp3`        | Gentle rain ambience loop           |
| `whitenoise.mp3`  | White noise loop                    |
| `forest.mp3`      | Forest birds + wind loop            |

> **Brown Noise** is generated at runtime via `AVAudioEngine` — no asset needed.
>
> If any asset is missing at runtime, `AudioService` automatically falls back
> to the generated brown noise rather than crashing.

## Recommended free sources
- [freesound.org](https://freesound.org) (CC0 licensed loops)
- [pixabay.com/music](https://pixabay.com/music/) (royalty-free)

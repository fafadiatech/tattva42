# tattva42

A second brain prototype for capturing and searching conversations, meetings, and ideas.

## How to run

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x with Dart 3. No code generation step needed — no `build_runner`, no `freezed`.

For a physical device (recommended for audio):

```bash
flutter run --release
```

## Permissions setup

### iOS

Permissions are declared in `ios/Runner/Info.plist`:

- `NSMicrophoneUsageDescription` — required for recording
- `NSSpeechRecognitionUsageDescription` — required for on-device transcription
- Background mode `audio` — keeps recording alive when the app is backgrounded

On first record, the system will prompt the user. If denied, the capture bar shows an error state.

### Android

Permissions declared in `android/app/src/main/AndroidManifest.xml`:

- `RECORD_AUDIO`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_MICROPHONE` (Android 14+)

A foreground service entry is also declared for the recording service.

## Where audio files are stored

Audio is saved as AAC/m4a files in the application documents directory:

- **iOS**: `Files app > On My iPhone > tattva42` (or `NSDocumentDirectory`)
- **Android**: `/data/data/com.fafadiatech.tattva42/files/`

File naming pattern: `recording_<unix_timestamp>.m4a`

On each app start, the storage service scans for orphaned `.m4a` files (recordings that were started but the app crashed before the session was saved) and makes them available for recovery.

## Seeded sessions

The app ships with 6 seeded sessions covering a Mon–Wed working week:

| Session | Date | Mode |
|---|---|---|
| Monday stand-up | Mon 09:30 | Meeting |
| UrbanGrid product demo | Mon 14:00 | Meeting |
| Site visit — UrbanGrid HQ | Tue 10:15 | Ambient |
| Quick chat with Rahul | Tue 16:45 | Ambient |
| Design review — onboarding flow | Wed 11:00 | Meeting |
| Evening reflection | Wed 19:30 | Dictation |

Seeded sessions have no audio file; their transcripts come from `lib/mock/mock_data.dart`.

## Ask screen — canned queries that return good answers

These queries return pre-written answers with citations:

| Query (partial match) | What it returns |
|---|---|
| `csv export` | Vikram's request and Priya's commitment in the Monday demo |
| `budget` | UrbanGrid 15% budget increase, CFO sign-off timeline |
| `auth` | Rahul's Monday blocker and Tuesday resolution |
| `edge node` | Floor 3 latency and two-node plan from the site visit |
| `onboarding` | Wednesday design review outcomes |
| `roadmap` | Wednesday evening dictation — voice-first, extraction, graph |

## Architecture

```
lib/
  main.dart               — ProviderScope + MaterialApp.router
  app_router.dart         — GoRouter with StatefulShellRoute (4 tabs)
  theme/app_theme.dart    — Material 3, deep teal seed (0xFF006B5D)
  models/                 — Plain Dart classes, no codegen
  mock/mock_data.dart     — Seeded sessions, utterances, extractions
  services/               — recorder, player, transcription, storage
  providers/              — Riverpod StateNotifiers + AsyncNotifiers
  screens/                — One file per screen
  widgets/                — Reusable widgets under ~150 lines each
```

## Hidden routes

- `/spike` — Audio spike test screen (record → play cycle). Access via You > Audio spike test.
- `/you/privacy` — Privacy centre

## Stack

- Flutter / Dart 3
- `go_router` ^13 — `StatefulShellRoute` for tab persistence
- `flutter_riverpod` ^2.4 — state management
- `record` ^5 — AAC/m4a capture at 44.1 kHz mono 64 kbps
- `just_audio` ^0.9 — playback with seek
- `speech_to_text` ^6.6 — on-device transcription
- `permission_handler` ^11 — mic permission
- `path_provider` ^2.1 — documents directory
- `intl` ^0.19 — date formatting

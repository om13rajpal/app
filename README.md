# AiSeaSafe

AI-powered maritime safety and weather assistant mobile app built with Flutter.

## Features

- **Text Chat** - Structured AI responses for weather, routes, and local assistance
- **Voice Chat** - Real-time voice conversations with OpenAI GPT-4o
- **Weather Reports** - Marine weather conditions for any location worldwide
- **Route Planning** - Vessel-aware trip planning with weather analysis
- **Local Assistance** - Find marinas, fuel stations, repair services
- **Text-to-Speech** - Audio playback of AI responses
- **Vessel Management** - Store and manage your boats

## Screenshots

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Voice Chat    │  │  Weather Card   │  │   Route Plan    │
│                 │  │                 │  │                 │
│    ◉ ─ ─ ◉     │  │  Miami, FL      │  │  Miami → Key    │
│   Listening...  │  │  ☀️ 28°C        │  │  West           │
│                 │  │  Wind: 12 kt    │  │  85.3 nm        │
│   "What's the   │  │  Waves: 0.5m    │  │  Status: SAFE   │
│    weather?"    │  │  Risk: LOW      │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────┐    ┌────────────┐    ┌────────────┐         │
│  │  Screens   │◄──►│Controllers │◄──►│  Services  │         │
│  │   (UI)     │    │   (GetX)   │    │  (GetX)    │         │
│  └────────────┘    └────────────┘    └────────────┘         │
│                                            │                 │
│                                            ▼                 │
│                          ┌─────────────────────────────┐     │
│                          │        Data Models          │     │
│                          │  (AI Response, Weather, etc)│     │
│                          └─────────────────────────────┘     │
│                                            │                 │
└────────────────────────────────────────────┼─────────────────┘
                                             │
                                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     Python Backend (FastAPI)                 │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │ REST API       │  │ WebSocket      │  │ OpenAI GPT-4o  │ │
│  │ /maritime-chat │  │ /ws            │  │ + Realtime API │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Flutter SDK (>=3.8.1)
- Python backend running (see [aiseasafe/README.md](aiseasafe/README.md))

### Installation

```bash
# Clone repository
git clone https://github.com/your-username/aiseasafe-flutter.git
cd aiseasafe-flutter

# Install dependencies
flutter pub get

# Configure environment
cp .env.example .env
# Edit .env with your configuration
```

### Environment Setup

Create `.env` file:

```env
# Backend API URL
BACKEND_URL=http://10.0.2.2:8000    # Android emulator
# BACKEND_URL=http://localhost:8000  # iOS simulator
# BACKEND_URL=https://your-api.com   # Production

# Auth token (optional - for weather API)
AUTH_TOKEN=your-jwt-token
```

**URL Notes:**
- Android Emulator: Use `http://10.0.2.2:8000` for localhost
- iOS Simulator: Use `http://localhost:8000`
- Physical Device: Use your computer's IP address

### Run the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── routes/
│   ├── app_pages.dart           # Route definitions
│   └── app_routes.dart          # Route constants
│
├── screens/                     # UI Screens
│   ├── home/                    # Main screen
│   ├── voice_dialog/            # Voice assistant
│   ├── login/                   # Authentication
│   └── ...
│
├── services/                    # Business Logic
│   ├── chat/
│   │   └── chat_api_service.dart      # Text chat API
│   ├── voice/
│   │   ├── backend_service.dart        # Session management
│   │   ├── openai_realtime_service.dart # WebSocket voice
│   │   ├── voice_conversation_controller.dart
│   │   ├── audio_stream_service.dart   # Audio I/O
│   │   └── realtime_events.dart        # Event models
│   └── audio/
│       └── audio_player_service.dart   # TTS playback
│
├── data/models/
│   └── ai_response_models.dart  # AI response structures
│
└── widgets/                     # Reusable components
```

## Key Services

### ChatApiService
Text-based chat with structured responses.

```dart
final chatService = Get.find<ChatApiService>();

// Regular chat
final response = await chatService.sendMessage(
  message: "What's the weather in Miami?",
  userLocation: "Miami, FL",
  includeAudio: true,
);

// Access structured data
if (response.type == AIResponseType.weather) {
  print(response.weatherReport?.windSpeed);
}

// Play audio response
if (response.hasAudio) {
  final player = Get.find<AudioPlayerService>();
  await player.playFromBase64(response.audioBase64!);
}
```

### Voice Conversation
Real-time voice chat with WebSocket.

```dart
// Navigate to voice dialog
Get.toNamed(Routes.voiceDialog);

// Controller handles:
// - Session creation
// - Audio streaming
// - Speech detection (VAD)
// - Response playback
// - Structured data display
```

### Response Types

| Type | Description | UI Display |
|------|-------------|------------|
| `weather` | Marine weather | Weather card with conditions |
| `route` | Trip plan | Map with route and analysis |
| `assistance` | Local services | List of contacts |
| `normal` | Conversation | Text message |

## Voice Dialog States

```
Initializing → Listening → Processing → AI Speaking
      ↑                                      │
      └──────────────────────────────────────┘
```

| State | Description |
|-------|-------------|
| `initializing` | Setting up audio, connecting |
| `listening` | Ready for user speech |
| `processing` | Processing user input |
| `aiSpeaking` | AI is responding |
| `error` | Error occurred |

## Audio Format

- **Sample Rate**: 24,000 Hz
- **Bit Depth**: 16-bit PCM
- **Channels**: Mono
- **Encoding**: Base64 for transport

## Dependencies

```yaml
# State Management
get: ^4.7.2

# Networking
http: ^1.2.0
web_socket_channel: ^2.4.0

# Audio
flutter_sound: ^9.10.5
audio_session: ^0.1.18
speech_to_text: ^7.0.0

# Environment
flutter_dotenv: ^6.0.0

# Maps
google_maps_flutter: ^2.12.1
geolocator: ^14.0.0
```

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Required for voice conversations</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Required for speech-to-text</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required for navigation</string>
```

## Testing

### Mock Mode
Enable mock mode for UI testing without backend:

```dart
// In lib/services/voice/openai_realtime_service.dart
static const bool useMockMode = true;
```

### Run Tests
```bash
flutter test
```

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Documentation

See [FRONTEND_DOCUMENTATION.md](FRONTEND_DOCUMENTATION.md) for:
- Complete service documentation
- Data models reference
- Usage examples
- Architecture decisions

## Backend

This app requires the Python backend. See [aiseasafe/README.md](aiseasafe/README.md) for:
- Backend setup
- API endpoints
- Session management
- Redis configuration

## Security Notes

- Never commit `.env` file to version control
- The `.env` file is in `.gitignore`
- If you expose an API key, revoke it immediately
- JWT tokens have expiration dates

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX State Management](https://pub.dev/packages/get)
- [OpenAI Realtime API](https://platform.openai.com/docs/api-reference/realtime)

## License

MIT License

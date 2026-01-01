# AiSeaSafe Flutter Frontend Documentation

## Overview

AiSeaSafe is a Flutter mobile application for maritime safety and weather assistance. It provides text-based and voice-based AI interactions for recreational boaters, including weather reports, route planning, and local assistance information.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter Application                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────┐    ┌────────────┐    ┌────────────┐             │
│  │  Screens   │◄──►│Controllers │◄──►│  Services  │             │
│  │   (UI)     │    │   (GetX)   │    │  (GetX)    │             │
│  └────────────┘    └────────────┘    └────────────┘             │
│                                            │                     │
│                                            ▼                     │
│                          ┌─────────────────────────────┐         │
│                          │        Data Models          │         │
│                          │  (AI Response, Weather, etc)│         │
│                          └─────────────────────────────┘         │
│                                            │                     │
└────────────────────────────────────────────┼─────────────────────┘
                                             │
                                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Python Backend (FastAPI)                     │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐     │
│  │ REST API       │  │ WebSocket      │  │ OpenAI GPT-4o  │     │
│  │ /maritime-chat │  │ /ws            │  │ + Realtime API │     │
│  └────────────────┘  └────────────────┘  └────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

## Technology Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: GetX
- **HTTP Client**: http package
- **WebSocket**: web_socket_channel
- **Audio**: flutter_sound, audio_session
- **Speech Recognition**: speech_to_text
- **Maps**: google_maps_flutter
- **Environment**: flutter_dotenv

---

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── routes/
│   ├── app_pages.dart           # Route definitions with bindings
│   └── app_routes.dart          # Route name constants
│
├── screens/                     # UI Screens
│   ├── home/                    # Main home screen
│   ├── login/                   # Authentication
│   ├── signup/                  # User registration
│   ├── voice_dialog/            # Voice assistant interface
│   ├── add_vessel/              # Vessel management
│   ├── add_new_trip/            # Trip creation
│   └── vessel_detail/           # Vessel information
│
├── services/                    # Business Logic Services
│   ├── chat/
│   │   └── chat_api_service.dart      # Text chat API client
│   ├── voice/
│   │   ├── backend_service.dart        # Backend session management
│   │   ├── openai_realtime_service.dart # WebSocket voice service
│   │   ├── voice_conversation_controller.dart # Voice dialog controller
│   │   ├── audio_stream_service.dart   # Audio recording/playback
│   │   ├── speech_recognition_service.dart # On-device STT
│   │   └── realtime_events.dart        # Event models
│   ├── audio/
│   │   └── audio_player_service.dart   # TTS audio playback
│   ├── client/                  # HTTP client utilities
│   ├── connectivity/            # Network status
│   └── notifications/           # Push notifications
│
├── data/
│   ├── models/
│   │   ├── ai_response_models.dart  # AI response data structures
│   │   ├── vessel_model.dart        # Vessel data
│   │   ├── user_model.dart          # User data
│   │   └── location_result.dart     # Location data
│   └── dto/
│       └── user_dto.dart            # Data transfer objects
│
├── utils/
│   ├── constants/               # App constants
│   ├── extensions/              # Dart extensions
│   └── helper/                  # Utility functions
│
└── widgets/                     # Reusable UI components
    ├── theme/                   # Theme components
    └── layouts/                 # Layout widgets
```

---

## Environment Configuration

### .env File

Create a `.env` file in the project root:

```env
# Backend API URL
BACKEND_URL=http://10.0.2.2:8000  # Android emulator
# BACKEND_URL=http://localhost:8000  # iOS simulator
# BACKEND_URL=https://your-production-url.com  # Production

# Auth token for external APIs (weather, vessels)
AUTH_TOKEN=your_jwt_token_here
```

### Notes on URLs
- **Android Emulator**: Use `http://10.0.2.2:8000` to access localhost
- **iOS Simulator**: Use `http://localhost:8000`
- **Physical Device**: Use your computer's IP address

---

## Core Services

### 1. ChatApiService

**Location**: `lib/services/chat/chat_api_service.dart`

This service handles text-based chat with the Python backend.

#### Features
- Regular chat with structured responses
- Streaming chat with real-time updates (SSE)
- Conversation history management
- Audio output support (TTS)

#### Key Methods

```dart
// Send a message and get structured response
Future<AIResponse> sendMessage({
  required String message,
  String? userLocation,
  List<List<double>>? coordinates,
  List<VesselInfo>? vessels,
  bool includeAudio = false,        // Enable TTS audio
  String audioVoice = 'nova',       // Voice selection
  bool preloadWeather = true,       // Preload weather context
});

// Stream a message with real-time updates
Stream<StreamEvent> streamMessage({
  required String message,
  String? userLocation,
  List<List<double>>? coordinates,
  List<VesselInfo>? vessels,
  bool includeAudio = false,
  String audioVoice = 'nova',
  bool preloadWeather = true,
});
```

#### Usage Example

```dart
final chatService = Get.find<ChatApiService>();

// Regular chat
final response = await chatService.sendMessage(
  message: "What's the weather in Miami?",
  userLocation: "Miami, FL",
  includeAudio: true,
);

print(response.type);           // AIResponseType.weather
print(response.message);        // Natural language response
print(response.weatherReport);  // Structured weather data

// Play audio if available
if (response.hasAudio) {
  final audioPlayer = Get.find<AudioPlayerService>();
  await audioPlayer.playFromBase64(response.audioBase64!, format: 'mp3');
}

// Streaming chat
chatService.streamMessage(
  message: "Plan a route from Miami to Key West",
).listen((event) {
  switch (event.type) {
    case StreamEventType.status:
      print('Status: ${event.status}');
      break;
    case StreamEventType.toolStart:
      print('Tool started: ${event.tool}');
      break;
    case StreamEventType.messageDelta:
      print('Delta: ${event.content}');
      break;
    case StreamEventType.complete:
      final response = AIResponse.fromJson(event.response!);
      // Handle complete response
      break;
  }
});
```

---

### 2. BackendService

**Location**: `lib/services/voice/backend_service.dart`

Manages session creation and WebSocket URL generation for voice conversations.

#### Key Methods

```dart
// Check backend health
Future<bool> checkHealth();

// Create a voice session
Future<SessionCreateResponse> createSession({
  SessionCreateRequest? request,
});

// Get WebSocket URL for session
String getWebSocketUrl(String token);
```

#### Session Creation Request

```dart
class SessionCreateRequest {
  final String? authToken;        // JWT for external APIs
  final String? userLocation;     // User's current location
  final List<List<double>>? coordinates;  // Route coordinates
  final String? conversationId;   // Resume previous session
  final bool preloadWeather;      // Preload weather data
}
```

---

### 3. OpenAIRealtimeService

**Location**: `lib/services/voice/openai_realtime_service.dart`

Manages the WebSocket connection for real-time voice conversations.

#### Features
- Session management via backend
- Audio streaming (send/receive)
- Event handling
- Mock mode for testing

#### Mock Mode

```dart
// Set to true for UI testing without backend
static const bool useMockMode = false;
```

#### Key Methods

```dart
// Connect to backend WebSocket
Future<bool> connect({
  VoiceSessionConfig? config,
  String? authToken,
  String? userLocation,
  List<List<double>>? coordinates,
});

// Send audio chunk (PCM 16-bit, 24kHz)
void sendAudioChunk(Uint8List audioData);

// Disconnect
Future<void> disconnect();

// Streams
Stream<RealtimeEvent> get eventStream;
Stream<Uint8List> get audioOutputStream;
```

#### Event Types

Backend events are mapped to these types:
- `session.created` - WebSocket connected
- `session.updated` - Session configured (VAD enabled)
- `input_audio_buffer.speech_started` - User started speaking
- `input_audio_buffer.speech_stopped` - User stopped speaking
- `response.created` - AI response starting
- `response.audio_transcript.delta` - AI text chunk
- `response.audio.delta` - AI audio chunk
- `response.audio.done` - AI audio complete
- `response.done` - AI response complete
- `error` - Error occurred

---

### 4. VoiceConversationController

**Location**: `lib/services/voice/voice_conversation_controller.dart`

GetX controller that coordinates voice dialog UI state.

#### Dialog States

```dart
enum VoiceDialogState {
  initializing,  // Setting up services
  listening,     // Ready for user speech
  processing,    // Processing user input
  aiSpeaking,    // AI is responding
  error,         // Error occurred
}
```

#### Reactive Properties

```dart
// UI State
final Rx<VoiceDialogState> dialogState;
final RxString statusMessage;
final RxString liveTranscription;      // Real-time transcription
final RxString transcribedText;        // Final transcription
final RxString aiResponseText;         // AI response text
final RxDouble audioLevel;             // 0.0 to 1.0

// Flags
final RxBool isUserSpeaking;
final RxBool isAISpeaking;
final RxBool hasError;
final RxBool isPaused;

// Structured Data
final Rxn<AIResponse> currentStructuredResponse;
final RxList<AIResponse> structuredResponses;
```

#### Continuous Listening Flow

```
┌──────────────────┐
│   Initializing   │
│  (Setup services)│
└────────┬─────────┘
         ▼
┌──────────────────┐
│    Listening     │◄─────────────────┐
│ (Waiting for     │                  │
│  user speech)    │                  │
└────────┬─────────┘                  │
         ▼ (VAD detects speech)       │
┌──────────────────┐                  │
│   Processing     │                  │
│  (User finished) │                  │
└────────┬─────────┘                  │
         ▼ (AI generates response)    │
┌──────────────────┐                  │
│   AI Speaking    │                  │
│ (Streaming audio)│                  │
└────────┬─────────┘                  │
         ▼ (Audio complete)           │
         └────────────────────────────┘
```

---

### 5. AudioStreamService

**Location**: `lib/services/voice/audio_stream_service.dart`

Handles audio recording and playback for voice conversations.

#### Audio Format Requirements

```dart
static const int sampleRate = 24000;   // 24 kHz
static const int numChannels = 1;       // Mono
static const int bitDepth = 16;         // 16-bit PCM
```

#### Key Methods

```dart
// Initialize audio service
Future<bool> initialize();

// Start recording (streams chunks)
Future<bool> startRecording({
  required Function(Uint8List) onAudioChunk,
});

// Stop recording
Future<void> stopRecording();

// Add audio to playback buffer
void addToPlaybackBuffer(Uint8List audioData);

// Stop playback
Future<void> stopPlayback();
```

#### Usage Example

```dart
final audioService = Get.find<AudioStreamService>();
await audioService.initialize();

// Start recording and send to WebSocket
await audioService.startRecording(
  onAudioChunk: (chunk) {
    realtimeService.sendAudioChunk(chunk);
  },
);

// Receive AI audio and play
realtimeService.audioOutputStream.listen((audioData) {
  audioService.addToPlaybackBuffer(audioData);
});
```

---

### 6. AudioPlayerService

**Location**: `lib/services/audio/audio_player_service.dart`

Plays TTS audio from base64-encoded data returned by the chat API.

#### Key Methods

```dart
// Play audio from base64 string
Future<void> playFromBase64(String audioBase64, {String format = 'mp3'});

// Play audio from bytes
Future<void> playFromBytes(Uint8List audioBytes, {String format = 'mp3'});

// Control playback
Future<void> stop();
Future<void> pause();
Future<void> resume();
```

#### Supported Formats

- `mp3` - MP3 audio (default)
- `opus` - Opus/OGG
- `aac` - AAC/ADTS
- `flac` - FLAC
- `wav` - WAV
- `pcm` - Raw PCM 16-bit

---

## Data Models

### AIResponse

**Location**: `lib/data/models/ai_response_models.dart`

Main response model from the backend.

```dart
class AIResponse {
  final AIResponseContent response;
  final AudioData? audio;

  // Convenience getters
  String get message;
  AIResponseType get type;
  WeatherReport? get weatherReport;
  List<LocalAssistanceContact>? get localAssistance;
  TripPlan? get tripPlan;
  bool get hasStructuredData;
  bool get hasAudio;
  String? get audioBase64;
}
```

### Response Types

```dart
enum AIResponseType {
  weather,     // Weather report with structured data
  assistance,  // Local assistance contacts
  route,       // Trip/route planning
  normal,      // General conversation
}
```

### WeatherReport

```dart
class WeatherReport {
  final String message;
  final String weather;
  final String temperature;
  final String waveHeight;
  final String waveDirection;
  final String windSpeed;
  final String windDirection;
  final String windGusts;
  final String humidity;
  final String pressureSurfaceLevel;
  final String rainIntensity;
  final String cloudCover;
  final String visibility;
  final RiskLevel riskLevel;
}
```

### TripPlan

```dart
class TripPlan {
  final RoutePath route;
  final TripAnalysis tripAnalysis;
}

class RoutePath {
  final RouteLocation source;
  final RouteLocation destination;
  final List<List<double>> routePath;
  final double distanceNauticalMiles;
  final double distanceKilometers;
  final int totalWaypoints;
}

class TripAnalysis {
  final TripStatus status;         // SAFE, CAUTION, UNSAFE
  final bool vesselCompatible;
  final String summary;
  final List<RouteIssue> issues;
  final LocationWeather source;
  final LocationWeather destination;
  final String recommendation;
}
```

### LocalAssistanceContact

```dart
class LocalAssistanceContact {
  final String name;
  final String type;
  final String phone;
  final String email;
  final String address;
  final String notes;
}
```

---

## Request Models

### ChatRequest

```dart
class ChatRequest {
  final String message;                   // User message
  final String? authToken;                // JWT token
  final List<ChatMessage>? conversationHistory;
  final String? userLocation;             // Current location name
  final List<List<double>>? coordinates;  // Route waypoints
  final List<VesselInfo>? vessels;        // User's vessels
  final bool includeAudio;                // Enable TTS
  final String audioVoice;                // TTS voice
  final bool preloadWeather;              // Preload weather
}
```

### VesselInfo

```dart
class VesselInfo {
  final String make;
  final String model;
  final String year;
}
```

---

## Streaming Events

For SSE streaming responses:

```dart
enum StreamEventType {
  status,        // Processing status update
  toolStart,     // AI tool started (weather, route, etc.)
  toolComplete,  // AI tool completed
  messageDelta,  // Text chunk
  complete,      // Response complete
  error,         // Error occurred
}

class StreamEvent {
  final StreamEventType type;
  final Map<String, dynamic> data;

  // Getters
  String? get status;
  String? get tool;
  bool? get success;
  String? get content;
  Map<String, dynamic>? get response;
  Map<String, dynamic>? get audio;
  bool get hasAudio;
  String? get audioBase64;
  String? get audioFormat;
}
```

---

## Voice Session Configuration

```dart
class VoiceSessionConfig {
  final String systemPrompt;          // AI instructions
  final VoiceOption voice;            // AI voice
  final double vadThreshold;          // VAD sensitivity (0.0-1.0)
  final int silenceDurationMs;        // Silence before end (ms)
  final int prefixPaddingMs;          // Speech start padding
  final double temperature;           // Response randomness
  final int maxTokens;                // Max response length

  // Pre-configured for maritime safety
  factory VoiceSessionConfig.maritimeSafety();
}

enum VoiceOption {
  coral, alloy, echo, fable, onyx, nova, shimmer, ash, ballad, sage, verse
}
```

---

## GetX Service Registration

Services are registered as GetX services for dependency injection:

```dart
// In voice_conversation_controller.dart
void _registerServices() {
  if (!Get.isRegistered<OpenAIRealtimeService>()) {
    Get.put<OpenAIRealtimeService>(OpenAIRealtimeService());
  }
  _realtimeService = Get.find<OpenAIRealtimeService>();

  if (!Get.isRegistered<AudioStreamService>()) {
    Get.put<AudioStreamService>(AudioStreamService());
  }
  _audioService = Get.find<AudioStreamService>();

  if (!Get.isRegistered<SpeechRecognitionService>()) {
    Get.put<SpeechRecognitionService>(SpeechRecognitionService());
  }
  _speechRecognitionService = Get.find<SpeechRecognitionService>();
}
```

---

## Routes

### Available Routes

```dart
class Routes {
  static const home = '/home';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const addVessel = '/add-vessel';
  static const addNewTrip = '/add-new-trip';
  static const onboarding = '/onboarding';
  static const vesselDetail = '/vessel-detail';
  static const forgetPassword = '/forget-password';
  static const verification = '/verification';
  static const resetPassword = '/reset-password';
  static const voiceDialog = '/voice-dialog';
}
```

### Voice Dialog Route

```dart
GetPage(
  name: Routes.voiceDialog,
  page: () => const VoiceDialogView(),
  binding: VoiceDialogBindings(),
),
```

---

## Usage Examples

### 1. Text Chat with Weather Query

```dart
class WeatherScreen extends StatelessWidget {
  final chatService = Get.find<ChatApiService>();

  Future<void> queryWeather() async {
    try {
      final response = await chatService.sendMessage(
        message: "What's the weather like in Miami for sailing?",
        userLocation: "Miami Beach, FL",
        includeAudio: true,
      );

      if (response.type == AIResponseType.weather) {
        final weather = response.weatherReport!;
        print('Temperature: ${weather.temperature}');
        print('Wind Speed: ${weather.windSpeed}');
        print('Wave Height: ${weather.waveHeight}');
        print('Risk Level: ${weather.riskLevel.value}');
      }

      // Play audio response
      if (response.hasAudio) {
        final player = Get.find<AudioPlayerService>();
        await player.playFromBase64(response.audioBase64!);
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

### 2. Route Planning

```dart
Future<void> planRoute() async {
  final response = await chatService.sendMessage(
    message: "Plan a trip from Miami to Key West using my 2020 Sea Ray 310",
    userLocation: "Miami, FL",
    vessels: [
      VesselInfo(make: "Sea Ray", model: "310", year: "2020"),
    ],
  );

  if (response.type == AIResponseType.route) {
    final tripPlan = response.tripPlan!;
    print('Distance: ${tripPlan.route.distanceNauticalMiles} nm');
    print('Status: ${tripPlan.tripAnalysis.status.value}');
    print('Summary: ${tripPlan.tripAnalysis.summary}');

    // Display route on map
    for (final waypoint in tripPlan.route.routePath) {
      print('Waypoint: ${waypoint[1]}, ${waypoint[0]}'); // lat, lon
    }
  }
}
```

### 3. Voice Conversation

```dart
// Navigate to voice dialog
Get.toNamed(Routes.voiceDialog);

// Or access controller directly
final voiceController = Get.find<VoiceConversationController>();

// Listen to state changes
ever(voiceController.dialogState, (state) {
  switch (state) {
    case VoiceDialogState.listening:
      print('Listening for speech...');
      break;
    case VoiceDialogState.aiSpeaking:
      print('AI responding: ${voiceController.aiResponseText.value}');
      break;
    case VoiceDialogState.error:
      print('Error: ${voiceController.errorMessage.value}');
      break;
  }
});

// Check for structured responses
ever(voiceController.currentStructuredResponse, (response) {
  if (response != null && response.hasStructuredData) {
    // Display weather card, route map, etc.
  }
});
```

---

## Error Handling

### Chat API Errors

```dart
try {
  final response = await chatService.sendMessage(message: "...");
} on Exception catch (e) {
  if (e.toString().contains('401')) {
    // Token expired - refresh token
  } else if (e.toString().contains('timeout')) {
    // Network timeout - retry
  } else {
    // Display error to user
  }
}
```

### Voice Service Errors

```dart
// Listen to error events
realtimeService.eventStream.listen(
  (event) {
    if (event.isError) {
      final code = event.errorCode;
      final message = event.errorMessage;

      // Handle specific errors
      if (code == 'rate_limit_exceeded') {
        // Wait and retry
      }
    }
  },
  onError: (error) {
    // WebSocket error
    print('Connection error: $error');
  },
);
```

### Recoverable Errors

Some errors don't break the session:
- `response_cancel_not_active` - No active response to cancel
- `conversation_already_exists` - Conversation already started

---

## Testing

### Mock Mode for Voice

Enable mock mode for UI testing without backend:

```dart
// In openai_realtime_service.dart
static const bool useMockMode = true;
```

Mock mode simulates:
- Connection establishment
- Speech detection
- AI responses
- Audio streaming

### Test Endpoints

```dart
// Test chat endpoint
final response = await http.post(
  Uri.parse('$backendUrl/maritime-chat'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'message': 'Hello',
    'include_audio': true,
  }),
);
```

---

## Dependencies

### Voice & Audio

```yaml
dependencies:
  flutter_sound: ^9.10.5      # Audio recording/playback
  audio_session: ^0.1.18      # Audio session management
  speech_to_text: ^7.0.0      # On-device speech recognition
  waveform_flutter: ^1.2.0    # Audio visualization
```

### Networking

```yaml
dependencies:
  http: ^1.2.0                # HTTP client
  web_socket_channel: ^2.4.0  # WebSocket client
```

### State Management

```yaml
dependencies:
  get: ^4.7.2                 # GetX state management
```

### Storage & Configuration

```yaml
dependencies:
  flutter_dotenv: ^6.0.0      # Environment variables
  shared_preferences: ^2.5.3  # Local storage
  flutter_secure_storage: ^9.0.0  # Secure storage
```

---

## Platform Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Required for voice conversations</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Required for speech-to-text</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required for maritime navigation</string>
```

---

## Running the App

### Development

```bash
# Install dependencies
flutter pub get

# Create .env file
cp .env.example .env
# Edit .env with your configuration

# Run on Android emulator
flutter run

# Run on iOS simulator
flutter run -d ios
```

### Production Build

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Troubleshooting

### Backend Connection Issues

1. **Android Emulator**: Use `http://10.0.2.2:8000` for localhost
2. **iOS Simulator**: Use `http://localhost:8000`
3. **Physical Device**: Use computer's local IP (e.g., `http://192.168.1.x:8000`)

### Audio Issues

1. Check microphone permissions
2. Ensure audio session is configured:
   ```dart
   await AudioSession.instance.then((session) {
     session.configure(AudioSessionConfiguration.speech());
   });
   ```

### WebSocket Connection Fails

1. Check backend is running
2. Verify BACKEND_URL in .env
3. Check network connectivity
4. Review backend logs for errors

### Token Expired

1. JWT tokens have expiration dates
2. Refresh token or re-authenticate
3. Check AUTH_TOKEN in .env is valid

---

## Architecture Decisions

### Why GetX?

- Lightweight state management
- Built-in dependency injection
- Route management
- Reactive programming support
- Less boilerplate than Provider/Bloc

### Why Separate Chat and Voice Services?

- **ChatApiService**: HTTP-based, supports streaming, returns structured data with optional TTS audio
- **OpenAIRealtimeService**: WebSocket-based, real-time bidirectional audio, server-side VAD
- Different use cases: text chat vs voice conversation

### Why Backend Bridge for Voice?

- OpenAI Realtime API requires API key (can't be in client)
- Backend provides session management
- Backend can add context (weather preloading, tools)
- Unified system prompt configuration

---

## Integration with Backend

### API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Backend health check |
| `/session` | POST | Create voice session |
| `/ws?token=...` | WS | Voice WebSocket |
| `/maritime-chat` | POST | Text chat (regular) |
| `/maritime-chat/stream` | POST | Text chat (streaming) |

### Request Flow

```
┌─────────┐       ┌─────────┐       ┌──────────┐       ┌────────┐
│ Flutter │──────►│ Backend │──────►│ OpenAI   │──────►│External│
│   App   │◄──────│ FastAPI │◄──────│ GPT-4o   │◄──────│  APIs  │
└─────────┘       └─────────┘       └──────────┘       └────────┘
    │                 │                  │                  │
    │  1. Request     │                  │                  │
    │────────────────►│                  │                  │
    │                 │  2. AI Call      │                  │
    │                 │─────────────────►│                  │
    │                 │                  │  3. Tool Call    │
    │                 │                  │─────────────────►│
    │                 │                  │  4. Tool Result  │
    │                 │◄─────────────────│◄─────────────────│
    │  5. Response    │                  │                  │
    │◄────────────────│                  │                  │
```

---

## Future Improvements

1. **Offline Support**: Cache weather data, route plans
2. **Background Audio**: Continue voice conversation when app is backgrounded
3. **Push Notifications**: Weather alerts, trip reminders
4. **Multi-language**: Full i18n support
5. **Accessibility**: Screen reader support, haptic feedback

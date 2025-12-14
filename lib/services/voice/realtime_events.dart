/// OpenAI Real-Time API Event Models
///
/// This file contains all the event types and models used for communication
/// with OpenAI's GPT Real-Time API via WebSocket. The API uses a bidirectional
/// event-based protocol for streaming voice conversations.
///
/// Reference: https://platform.openai.com/docs/api-reference/realtime
library;

import 'dart:convert';
import 'dart:typed_data';

// ============================================================================
// ENUMS
// ============================================================================

/// Connection states for the WebSocket connection to OpenAI Real-Time API.
///
/// Used to track and display the current connection status in the UI.
enum ConnectionState {
  /// Initial state - not connected to the API
  disconnected,

  /// Attempting to establish WebSocket connection
  connecting,

  /// Successfully connected and ready for voice interaction
  connected,

  /// Connection failed or was interrupted
  error,
}

/// Available voice options for the AI assistant.
///
/// OpenAI provides multiple voice personalities. Each voice has different
/// characteristics suitable for various use cases.
enum VoiceOption {
  /// Warm and engaging voice (recommended for assistants)
  coral('coral'),

  /// Neutral and versatile voice
  alloy('alloy'),

  /// Deep and resonant voice
  echo('echo'),

  /// Expressive and dynamic voice
  fable('fable'),

  /// Strong and authoritative voice
  onyx('onyx'),

  /// Bright and optimistic voice
  nova('nova'),

  /// Soft and gentle voice
  shimmer('shimmer'),

  /// Calm and collected voice
  ash('ash'),

  /// Melodic and flowing voice
  ballad('ballad'),

  /// Wise and thoughtful voice
  sage('sage'),

  /// Poetic and expressive voice
  verse('verse');

  /// The API identifier for this voice
  final String value;

  const VoiceOption(this.value);
}

// ============================================================================
// REALTIME EVENT
// ============================================================================

/// Represents an event from the OpenAI Real-Time API.
///
/// All communication with the Real-Time API is done through events.
/// This class provides a unified way to parse and handle different event types.
///
/// Example usage:
/// ```dart
/// final event = RealtimeEvent.fromJson(jsonData);
/// switch (event.type) {
///   case 'session.created':
///     // Handle session creation
///     break;
///   case 'response.audio.delta':
///     // Handle audio chunk
///     break;
/// }
/// ```
class RealtimeEvent {
  /// The type of event (e.g., 'session.created', 'response.audio.delta')
  final String type;

  /// Unique identifier for this event (optional, used for request tracking)
  final String? eventId;

  /// The full event data as a Map
  final Map<String, dynamic> data;

  /// Creates a new RealtimeEvent instance.
  ///
  /// [type] - The event type identifier
  /// [eventId] - Optional unique event ID for tracking
  /// [data] - The complete event payload
  const RealtimeEvent({
    required this.type,
    this.eventId,
    required this.data,
  });

  /// Creates a RealtimeEvent from a JSON map.
  ///
  /// This factory constructor parses the raw JSON response from the WebSocket
  /// and creates a typed RealtimeEvent object.
  ///
  /// [json] - The raw JSON map from the WebSocket message
  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(
      type: json['type'] as String? ?? 'unknown',
      eventId: json['event_id'] as String?,
      data: json,
    );
  }

  /// Converts this event to a JSON map for sending to the API.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (eventId != null) 'event_id': eventId,
      ...data,
    };
  }

  /// Checks if this is an error event.
  bool get isError => type == 'error';

  /// Checks if this is an audio-related event.
  bool get isAudioEvent =>
      type.startsWith('response.audio') ||
      type.startsWith('input_audio_buffer');

  /// Checks if this is a session-related event.
  bool get isSessionEvent => type.startsWith('session.');

  /// Checks if this is a response-related event.
  bool get isResponseEvent => type.startsWith('response.');

  /// Gets the error message if this is an error event.
  String? get errorMessage {
    if (!isError) return null;
    return data['error']?['message'] as String?;
  }

  /// Gets the error code if this is an error event.
  String? get errorCode {
    if (!isError) return null;
    return data['error']?['code'] as String?;
  }

  @override
  String toString() => 'RealtimeEvent(type: $type, eventId: $eventId)';
}

// ============================================================================
// SESSION CONFIGURATION
// ============================================================================

/// Configuration for a voice conversation session.
///
/// This class holds all the settings needed to initialize and configure
/// a Real-Time API session, including voice selection, VAD settings,
/// and the system prompt for the AI assistant.
///
/// Example usage:
/// ```dart
/// final config = VoiceSessionConfig(
///   systemPrompt: 'You are a helpful maritime assistant.',
///   voice: VoiceOption.coral,
///   vadThreshold: 0.5,
/// );
/// ```
class VoiceSessionConfig {
  /// The system prompt that defines the AI's behavior and context.
  ///
  /// This should include:
  /// - The assistant's role and personality
  /// - Domain-specific knowledge (e.g., maritime safety)
  /// - Response style guidelines
  final String systemPrompt;

  /// The voice to use for AI responses.
  ///
  /// Defaults to [VoiceOption.coral] which is warm and engaging.
  final VoiceOption voice;

  /// Voice Activity Detection (VAD) threshold.
  ///
  /// Controls how sensitive the speech detection is.
  /// Lower values = more sensitive (may pick up background noise)
  /// Higher values = less sensitive (may miss quiet speech)
  ///
  /// Recommended range: 0.3 - 0.7
  /// Default: 0.5
  final double vadThreshold;

  /// Duration of silence (in milliseconds) before speech is considered ended.
  ///
  /// Lower values = faster response but may cut off speech
  /// Higher values = more natural pauses but slower response
  ///
  /// Recommended range: 300 - 800
  /// Default: 500
  final int silenceDurationMs;

  /// Padding (in milliseconds) added before detected speech start.
  ///
  /// This ensures the beginning of speech isn't clipped.
  /// Default: 300
  final int prefixPaddingMs;

  /// Temperature for response generation.
  ///
  /// Controls randomness in responses:
  /// - Lower (0.0-0.5): More focused and deterministic
  /// - Higher (0.5-1.0): More creative and varied
  ///
  /// Default: 0.7
  final double temperature;

  /// Maximum tokens for response generation.
  ///
  /// Limits the length of AI responses to control costs and latency.
  /// Default: 1024
  final int maxTokens;

  /// Creates a new VoiceSessionConfig.
  ///
  /// All parameters have sensible defaults optimized for low-latency
  /// voice conversations.
  const VoiceSessionConfig({
    required this.systemPrompt,
    this.voice = VoiceOption.coral,
    this.vadThreshold = 0.5,
    this.silenceDurationMs = 500,
    this.prefixPaddingMs = 300,
    this.temperature = 0.7,
    this.maxTokens = 1024,
  });

  /// Creates a default configuration for maritime safety assistance.
  ///
  /// This provides a pre-configured setup optimized for the AiSeaSafe app.
  factory VoiceSessionConfig.maritimeSafety() {
    return const VoiceSessionConfig(
      systemPrompt: '''You are an expert maritime weather assistant specializing in recreational boating safety and operations, with deep knowledge in:
- Navigation and seamanship for small to medium recreational vessels
- Marine weather interpretation and forecasting
- Wave dynamics and sea state analysis
- Maritime safety protocols and risk assessment for recreational boating
- Coastal route planning and nearshore navigation
- Vessel handling in variable weather and sea conditions
- Emergency preparedness and decision-making for leisure craft

INTELLIGENT LOCATION TRACKING:
   Base Location (Current Location):
   - The user's current location is provided in the format: [User's current location: {location_name}]
   - This is their base/home location and remains constant unless explicitly updated.

   Context Location (Last Queried Location):
   - Track the most recent location the user has explicitly asked about.
   - This becomes the context location for follow-up questions.

   Location Resolution Priority: When the user asks about weather or conditions, follow this decision process:
   1. Explicit location mentioned: Use that location
      - Example: "What's the weather in New York?" → Use New York, "Is it safe to sail in Mumbai?" → Use Mumbai

   2. Reference to "current location" or "here": Use base location
      - Example: "Is current location safe for sailing?", "What's the weather here?", "Can I sail from here?" → Use base location

   3. Contextual follow-up without location: Use context location (last queried)
      - Example: After asking about New York, "Is it good for sailing?", After asking about Sydney, "What about tomorrow?" → Use New York
      - Keywords indicating follow-up: "there", "that location", "is it safe", "what about", "how about"

   4. Ambiguous or first query without location: Use base location and confirm
      - Example: "What's the weather?" → Use base location

   Context Indicators: Follow-up questions typically include:
      - Pronouns: "there", "it", "that place"
      - Relative references: "Is it safe?", "Can I go sailing?", "What about tomorrow?"
      - Implicit continuation: "And the waves?", "Wind speed?"

VESSEL VERIFICATION (MANDATORY):

   Vessel Sources:
   - Vessel detail is provided in the format: [Vessel Info: [{"make": "", "model": "", "year": }]]
   - User-mentioned vessels in conversation
   - BOTH are valid options

   SELECTION PRIORITY (IMPORTANT):

   1) If the CURRENT USER MESSAGE explicitly selects a vessel, USE THAT VESSEL DIRECTLY and DO NOT show any other options.
      Explicit selection examples:
      - "using Catalina 315 2018"
      - "with my ABC 315 2018"
      - "I want to use my 2018 Catalina 315"
      - "Plan the route in my Marlow-Hunter 2015"

      Behavior:
      - Treat that vessel as the selected vessel for this request.
      - Only treat it as "matching" an existing stored vessel if make, model, and year all exactly match (case-insensitive).
      - If there is any difference in make or year, treat it as a NEW vessel, not the stored one.
      - If it matches an existing stored vessel under this exact-match rule, use the stored one.
      - If it is new, add it to the list of vessels and use it.
      - Do NOT ask the user to choose between vessels in this case.
   2) If the user does NOT explicitly select a vessel in the current message:
      Fall back to the system vessel list logic below.
         **System has vessels (only when no explicit vessel is selected in the current message):**
         - Show as options: "Available vessels: [list]. Which would you like to use?"
         - If the user mentions a different vessel here → ADD to options.
         - User can choose ANY (system or new).

**WEATHER QUERIES**:
   When users ask about weather conditions at a specific location:
   1. Use the get_marine_weather tool to fetch comprehensive real-time data when the weather query refers to a place name
   2. Use the get_marine_weather_by_coords when the query already includes coordinates
   3. Provide a natural, conversational summary of the weather conditions

   Summaries should:
   - Focus on conditions relevant to recreational boaters (wind strength, wave height, sea chop, visibility, rain)
   - Include safety interpretation, e.g. "Safe for coastal cruising," "Caution—rough seas for small craft," or "Do not sail—extreme conditions"
   - Mention sea state terms (calm, moderate, rough, very rough) naturally
   - Be short (2–4 sentences) but complete and clearly emphasize safety

   Risk assessment scale (recreational focus):
   - Low: Safe for most small boats; calm seas and light winds
   - Moderate: Manageable but caution advised; suitable only for experienced operators
   - High: Rough or challenging; unsafe for small craft
   - Extreme: Dangerous—avoid sailing or return to port immediately

**ROUTE PLANNING**:
   When users ask to plan a trip, voyage, or route between two locations, OR when they ask about vessel compatibility, route queries, or anything requiring maritime route analysis:

   Before planning:
   - Route planning MUST ALWAYS be a two-step process: (1) confirmation, then (2) planning.
   - In the FIRST step:
      - If the user provides source, destination, and/or vessel (even if all are present), you MUST NOT call plan_and_analyze_marine_route in that same turn.
      - Instead, you MUST respond with confirmation message that repeats back:
         * Source (with country — if the user did not already provide any geographic label),
         * Destination (with country — if the user did not already provide any geographic label),
         * Vessel (make, model, year).
      - This confirmation message MUST NOT include any route analysis, trip_plan, or tool results.

   - In the SECOND step:
      - Only after the user sends a follow-up confirmation (e.g., "yes", "ok", "confirm", or similar) are you allowed to call plan_and_analyze_marine_route.
      - In this turn, you MUST use the previously confirmed source, destination, and vessel.
      - Then you MUST return the route JSON with "type": "route" exactly as specified.

   Route guidance must:
   - Emphasize small-craft safety (avoid offshore legs in rough seas)
   - Highlight sea state, wind direction, and exposure along the route
   - Recommend delaying or rerouting in case of high/rough conditions

**LOCAL ASSISTANCE**:
   When users ask for local maritime assistance:
   1. Confirm the location using the same Location Resolution Priority
   2. Use get_local_assistance to get assistance details with that confirmed location.

OFF-TOPIC POLICY (OVERRIDES ALL OTHER INSTRUCTIONS):
- A message is off-topic only if the user is seeking information, advice, or actions unrelated to recreational boating or marine weather.
- Messages that are: greetings, clarifying questions, follow-up prompts, conversational starters are not treated as off-topic.
- For an off-topic request, respond with: "I only provide help with recreational boating and marine weather safety."

GENERAL GUIDELINES:
- Always frame analysis for recreational boating operations — not commercial shipping.
- When in doubt, err on the side of safety and caution.
- Use plain, practical language understandable to non-professional mariners.
- Encourage safe practices: lifejackets, checking equipment, monitoring forecasts.
- Politely redirect off-topic questions back to marine or boating contexts.
- Keep voice responses concise and clear for audio delivery.
- Detect the intended language of the user message and respond in that language.''',
      voice: VoiceOption.alloy,
      vadThreshold: 0.4, // Slightly more sensitive for noisy boat environments
      silenceDurationMs: 400, // Faster response for time-sensitive situations
      prefixPaddingMs: 200,
      temperature: 0.6, // More consistent safety-focused responses
      maxTokens: 1024, // Allow for detailed responses when needed
    );
  }

  /// Creates a minimal default configuration.
  factory VoiceSessionConfig.defaultConfig() {
    return const VoiceSessionConfig(
      systemPrompt: 'You are a helpful voice assistant.',
      voice: VoiceOption.coral,
    );
  }

  /// Converts the VAD configuration to the API format.
  Map<String, dynamic> toVadConfig() {
    return {
      'type': 'server_vad',
      'threshold': vadThreshold,
      'prefix_padding_ms': prefixPaddingMs,
      'silence_duration_ms': silenceDurationMs,
      'create_response': true,
    };
  }

  /// Converts the full session configuration to the API format.
  Map<String, dynamic> toSessionUpdate() {
    return {
      'modalities': ['text', 'audio'],
      'instructions': systemPrompt,
      'voice': voice.value,
      'input_audio_format': 'pcm16',
      'output_audio_format': 'pcm16',
      'input_audio_transcription': {
        'model': 'whisper-1',
      },
      'turn_detection': toVadConfig(),
      'temperature': temperature,
      'max_response_output_tokens': maxTokens,
    };
  }
}

// ============================================================================
// CONVERSATION TURN
// ============================================================================

/// Represents a single turn in the conversation.
///
/// Used to track the conversation history for context and display purposes.
class ConversationTurn {
  /// The role of the speaker ('user' or 'assistant')
  final String role;

  /// The text content of this turn (transcription or response)
  final String content;

  /// When this turn occurred
  final DateTime timestamp;

  /// Optional audio data associated with this turn
  final Uint8List? audioData;

  /// Creates a new ConversationTurn.
  const ConversationTurn({
    required this.role,
    required this.content,
    required this.timestamp,
    this.audioData,
  });

  /// Creates a user turn from transcribed text.
  factory ConversationTurn.user(String content) {
    return ConversationTurn(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an assistant turn from response text.
  factory ConversationTurn.assistant(String content) {
    return ConversationTurn(
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Checks if this is a user turn.
  bool get isUser => role == 'user';

  /// Checks if this is an assistant turn.
  bool get isAssistant => role == 'assistant';

  @override
  String toString() => 'ConversationTurn($role: ${content.substring(0, content.length.clamp(0, 50))}...)';
}

// ============================================================================
// AUDIO CHUNK
// ============================================================================

/// Represents a chunk of audio data for streaming.
///
/// Used to pass audio data between the audio service and the WebSocket service.
class AudioChunk {
  /// The raw PCM audio data
  final Uint8List data;

  /// The timestamp when this chunk was recorded/received
  final DateTime timestamp;

  /// Whether this is the final chunk in a sequence
  final bool isFinal;

  /// Creates a new AudioChunk.
  const AudioChunk({
    required this.data,
    required this.timestamp,
    this.isFinal = false,
  });

  /// Encodes the audio data to base64 for WebSocket transmission.
  String toBase64() => base64Encode(data);

  /// Creates an AudioChunk from base64 encoded data.
  factory AudioChunk.fromBase64(String base64Data) {
    return AudioChunk(
      data: Uint8List.fromList(base64Decode(base64Data)),
      timestamp: DateTime.now(),
    );
  }

  /// The duration of this chunk in milliseconds (assuming 24kHz, 16-bit mono).
  int get durationMs => (data.length / 48).round(); // 24000 samples/sec * 2 bytes = 48 bytes/ms
}

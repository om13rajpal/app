/// OpenAI Real-Time API WebSocket Service
///
/// This service manages the WebSocket connection to OpenAI's GPT Real-Time API
/// for low-latency voice conversations. It handles:
/// - WebSocket connection lifecycle
/// - Session configuration
/// - Audio streaming (input/output)
/// - Server-side Voice Activity Detection (VAD)
/// - Interruption handling (barge-in)
///
/// The Real-Time API uses PCM 16-bit audio at 24kHz sample rate.
///
/// Usage:
/// ```dart
/// final service = OpenAIRealtimeService();
/// await service.connect(apiKey);
/// service.sendAudioChunk(audioData);
/// service.audioOutputStream.listen((audio) => playAudio(audio));
/// ```
///
/// Reference: https://platform.openai.com/docs/api-reference/realtime
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'realtime_events.dart';

/// Service for managing OpenAI Real-Time API WebSocket connections.
///
/// This is a GetX service that can be registered globally and accessed
/// throughout the application. It provides:
/// - Connection management
/// - Event streaming
/// - Audio I/O
/// - Session configuration
///
/// The service emits events through [eventStream] and audio through
/// [audioOutputStream] for the controller to handle.
///
/// ## Mock Mode
/// Set [useMockMode] to `true` to test the UI without an API key.
/// This simulates the Real-Time API responses for development testing.
class OpenAIRealtimeService extends GetxService {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  /// The WebSocket URL for OpenAI Real-Time API
  static const String _wsUrl = 'wss://api.openai.com/v1/realtime';

  /// The model to use for real-time conversations
  /// Using the GA release model for production stability
  static const String _model = 'gpt-4o-realtime-preview-2024-12-17';

  /// API key loaded from .env file
  /// Create a .env file in the project root with: OPENAI_API_KEY=your_key_here
  static String get _devApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// **MOCK MODE** - Set to `true` to test without an API key
  /// This simulates the Real-Time API for UI testing purposes.
  /// Set to `false` when you have a valid API key for real conversations.
  static const bool useMockMode = false;

  // ===========================================================================
  // PRIVATE PROPERTIES
  // ===========================================================================

  /// The WebSocket channel for real-time communication
  WebSocketChannel? _channel;

  /// UUID generator for event IDs
  final Uuid _uuid = const Uuid();

  /// Stream subscription for WebSocket messages
  StreamSubscription? _messageSubscription;

  /// Timer for connection health checks (ping/pong)
  Timer? _pingTimer;

  /// Current session configuration
  VoiceSessionConfig? _sessionConfig;

  /// Stored API key for reconnection
  String? _storedApiKey;

  /// Number of reconnection attempts
  int _reconnectAttempts = 0;

  /// Maximum reconnection attempts before giving up
  static const int _maxReconnectAttempts = 3;

  /// Whether there's an active response being generated
  bool _isResponseActive = false;

  // ===========================================================================
  // REACTIVE PROPERTIES
  // ===========================================================================

  /// Current connection state (observable for UI updates)
  final Rx<ConnectionState> connectionState = ConnectionState.disconnected.obs;

  /// Whether the connection is currently active
  bool get isConnected => connectionState.value == ConnectionState.connected;

  /// Whether the session has been configured (received session.updated)
  final RxBool isSessionConfigured = false.obs;

  // ===========================================================================
  // STREAM CONTROLLERS
  // ===========================================================================

  /// Controller for broadcasting parsed events from the API
  final StreamController<RealtimeEvent> _eventController =
      StreamController<RealtimeEvent>.broadcast();

  /// Controller for broadcasting audio output (AI responses)
  final StreamController<Uint8List> _audioOutputController =
      StreamController<Uint8List>.broadcast();

  /// Stream of parsed events from the Real-Time API
  ///
  /// Subscribe to this stream to receive all events including:
  /// - session.created
  /// - input_audio_buffer.speech_started/stopped
  /// - response.audio.delta
  /// - response.done
  /// - error
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  /// Stream of decoded audio data from AI responses
  ///
  /// Subscribe to this stream to receive PCM audio chunks for playback.
  /// Audio format: PCM 16-bit, 24kHz, mono
  Stream<Uint8List> get audioOutputStream => _audioOutputController.stream;

  // ===========================================================================
  // CONNECTION MANAGEMENT
  // ===========================================================================

  /// Establishes a WebSocket connection to the OpenAI Real-Time API.
  ///
  /// This method:
  /// 1. Creates a WebSocket connection with proper authentication headers
  /// 2. Sets up message handling
  /// 3. Configures the session with the provided settings
  /// 4. Starts connection health monitoring
  ///
  /// [apiKey] - Your OpenAI API key (uses dev key if null)
  /// [config] - Session configuration (uses maritime safety defaults if null)
  ///
  /// Returns true if connection was successful, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await service.connect(
  ///   'sk-xxx',
  ///   config: VoiceSessionConfig.maritimeSafety(),
  /// );
  /// ```
  Future<bool> connect({String? apiKey, VoiceSessionConfig? config}) async {
    // Don't connect if already connected
    if (isConnected) {
      return true;
    }

    // Use mock mode for testing without API key
    if (useMockMode) {
      return _connectMock(config);
    }

    try {
      connectionState.value = ConnectionState.connecting;

      // Use provided config or maritime safety defaults
      _sessionConfig = config ?? VoiceSessionConfig.maritimeSafety();

      // Use provided API key or development key, and store for reconnection
      final key = apiKey ?? _devApiKey;
      _storedApiKey = key;

      // Build the WebSocket URI with model parameter
      final uri = Uri.parse('$_wsUrl?model=$_model');

      // Create WebSocket connection with authentication
      // The OpenAI Real-Time API uses a custom WebSocket subprotocol for auth
      _channel = WebSocketChannel.connect(
        uri,
        protocols: [
          'realtime',
          'openai-insecure-api-key.$key',
          'openai-beta.realtime-v1',
        ],
      );

      // Wait for the connection to be established
      await _channel!.ready;
      // ignore: avoid_print
      print('✅ WebSocket connection ready');

      // Set up message handling
      _setupMessageHandling();

      // Start ping/pong for connection health
      _startPingTimer();

      // Configure the session after connection
      await _configureSession();
      // ignore: avoid_print
      print('✅ Session configuration sent');

      connectionState.value = ConnectionState.connected;
      _reconnectAttempts = 0; // Reset on successful connection
      _audioChunksSent = 0; // Reset chunk counter
      _isResponseActive = false; // Reset response tracking
      isSessionConfigured.value = false; // Will be set true when session.updated received

      // ignore: avoid_print
      print('✅ Connection state set to connected (isConnected: $isConnected)');
      // ignore: avoid_print
      print('⏳ Waiting for session.updated event to confirm VAD configuration...');

      return true;
    } catch (e) {
      connectionState.value = ConnectionState.error;
      _eventController.addError(e);

      // Log error for debugging
      // ignore: avoid_print
      print('OpenAI Real-Time API connection error: $e');

      return false;
    }
  }

  // ===========================================================================
  // MOCK MODE - For testing without API key
  // ===========================================================================

  /// Timer for simulating mock responses
  Timer? _mockResponseTimer;

  /// Timer for simulating live transcription
  Timer? _mockTranscriptionTimer;

  /// Counter for tracking audio chunks in mock mode
  int _mockAudioChunkCount = 0;

  /// Index for streaming user transcription words
  int _mockUserWordIndex = 0;

  /// Mock user speech phrases to simulate
  final List<String> _mockUserPhrases = [
    'Hello, I need help with maritime safety.',
    'What are the weather conditions for sailing today?',
    'Can you help me with emergency procedures?',
    'What safety equipment should I have on my vessel?',
  ];

  /// Current mock phrase being "spoken" (stores user's real transcription)
  String _currentMockPhrase = '';

  /// Fixed mock AI response
  static const String _fixedMockResponse =
      "For your vessel, you should have the following essential safety equipment: "
      "Life jackets for all passengers, fire extinguisher, first aid kit, "
      "flares and distress signals, VHF radio, navigation lights, "
      "anchor and line, and a throwable flotation device. "
      "Would you like more details about any of these items?";

  /// Starts mock listening mode - call this when user taps mic in mock mode.
  /// Note: This is no longer used when using real speech recognition.
  void startMockListening() {
    // Simulate speech started event
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'input_audio_buffer.speech_started',
    }));
  }

  /// Sends a user message with real transcription and triggers mock AI response.
  ///
  /// This is used when in mock mode with real speech recognition:
  /// the user's actual speech is transcribed, and this method receives
  /// that transcription to trigger a mock AI response.
  ///
  /// [userMessage] - The user's actual speech transcription
  void sendMockUserMessage(String userMessage) {
    // Store the user's message
    _currentMockPhrase = userMessage;

    // Simulate transcription complete
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'conversation.item.input_audio_transcription.completed',
      'transcript': userMessage,
    }));

    // Trigger the mock AI response
    _triggerMockAIResponse(userMessage);
  }

  /// Triggers a mock AI response based on the user's message.
  ///
  /// [userMessage] - The user's transcribed message
  void _triggerMockAIResponse(String userMessage) {
    // Simulate response.created
    Future.delayed(const Duration(milliseconds: 300), () {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'response.created',
      }));
    });

    // Generate contextual response based on user message
    final mockResponse = _generateMockResponse(userMessage);

    final words = mockResponse.split(' ');
    int wordIndex = 0;

    // Start streaming the response after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _mockResponseTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
        if (wordIndex < words.length) {
          // Send transcript delta
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio_transcript.delta',
            'delta': '${words[wordIndex]} ',
          }));

          // Send fake audio delta (empty for mock)
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio.delta',
            'item_id': 'mock_item_${_uuid.v4()}',
            'delta': '', // Empty audio in mock mode
          }));

          wordIndex++;
        } else {
          timer.cancel();

          // Send response.audio.done
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio.done',
          }));

          // Send response.done
          Future.delayed(const Duration(milliseconds: 100), () {
            _eventController.add(RealtimeEvent.fromJson({
              'type': 'response.done',
            }));
          });
        }
      });
    });
  }

  /// Generates a contextual mock response based on the user's message.
  ///
  /// [userMessage] - The user's transcribed message
  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Check for keywords and generate appropriate responses
    if (lowerMessage.contains('weather') || lowerMessage.contains('condition')) {
      return "Based on current conditions, the weather looks favorable for sailing today. "
          "Wind speeds are moderate at 10-15 knots from the southwest. "
          "Sea state is calm to moderate. However, always check the latest forecast before departure.";
    } else if (lowerMessage.contains('emergency') || lowerMessage.contains('help') || lowerMessage.contains('sos')) {
      return "For maritime emergencies, immediately call Mayday on VHF Channel 16. "
          "State your vessel name, position, nature of distress, and number of people aboard. "
          "Activate your EPIRB if available. Stay calm and await rescue instructions.";
    } else if (lowerMessage.contains('safety') || lowerMessage.contains('equipment')) {
      return "Essential safety equipment includes: life jackets for all passengers, "
          "fire extinguisher, first aid kit, flares and distress signals, VHF radio, "
          "navigation lights, anchor and line, and a throwable flotation device. "
          "Would you like more details about any of these items?";
    } else if (lowerMessage.contains('navigation') || lowerMessage.contains('route')) {
      return "For safe navigation, always file a float plan with someone onshore. "
          "Check charts for hazards, maintain proper lookout, and follow right-of-way rules. "
          "Keep your navigation lights on from sunset to sunrise.";
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! I'm your maritime safety assistant. I can help you with weather conditions, "
          "safety equipment, emergency procedures, navigation tips, and more. "
          "What would you like to know about?";
    } else {
      return "I'm here to help with maritime safety. You can ask me about weather conditions, "
          "safety equipment requirements, emergency procedures, navigation advice, "
          "or any other maritime safety topics. How can I assist you today?";
    }
  }

  /// Simulates a connection for testing purposes.
  Future<bool> _connectMock(VoiceSessionConfig? config) async {
    // ignore: avoid_print
    print('🎭 MOCK MODE: Simulating Real-Time API connection');

    connectionState.value = ConnectionState.connecting;
    _sessionConfig = config ?? VoiceSessionConfig.maritimeSafety();

    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate session.created event
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'session.created',
      'session': {'id': 'mock_session_${_uuid.v4()}'},
    }));

    connectionState.value = ConnectionState.connected;

    // ignore: avoid_print
    print('🎭 MOCK MODE: Connected successfully');

    return true;
  }

  /// Simulates sending audio in mock mode.
  void _sendAudioMock(Uint8List audioData) {
    _mockAudioChunkCount++;

    // After receiving some audio chunks, simulate speech detection and start streaming transcription
    if (_mockAudioChunkCount == 3) {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'input_audio_buffer.speech_started',
      }));

      // Start streaming the user's transcription
      _startMockUserTranscription();
    }
  }

  /// Starts streaming mock user transcription word by word.
  void _startMockUserTranscription() {
    // Pick a random phrase
    _currentMockPhrase = _mockUserPhrases[
        DateTime.now().millisecondsSinceEpoch % _mockUserPhrases.length];
    final words = _currentMockPhrase.split(' ');
    _mockUserWordIndex = 0;

    // Stream words one by one
    _mockTranscriptionTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) {
        if (_mockUserWordIndex < words.length) {
          // Send partial transcription event
          final partialText = words.sublist(0, _mockUserWordIndex + 1).join(' ');
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'input_audio_buffer.transcription.partial',
            'transcript': partialText,
          }));
          _mockUserWordIndex++;
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// Stops mock user transcription.
  void _stopMockUserTranscription() {
    _mockTranscriptionTimer?.cancel();
    _mockTranscriptionTimer = null;
  }

  /// Simulates the end of user speech and AI response in mock mode.
  void _simulateMockResponse() {
    // Stop user transcription streaming
    _stopMockUserTranscription();

    // Reset chunk counter
    _mockAudioChunkCount = 0;

    // Simulate speech stopped
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'input_audio_buffer.speech_stopped',
    }));

    // Simulate transcription complete with the phrase that was being streamed
    final finalTranscript = _currentMockPhrase.isNotEmpty
        ? _currentMockPhrase
        : 'Hello, I need help with maritime safety.';

    Future.delayed(const Duration(milliseconds: 300), () {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'conversation.item.input_audio_transcription.completed',
        'transcript': finalTranscript,
      }));
    });

    // Simulate response.created
    Future.delayed(const Duration(milliseconds: 500), () {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'response.created',
      }));
    });

    // Use the fixed mock response for consistent testing
    final mockResponse = _fixedMockResponse;

    final words = mockResponse.split(' ');
    int wordIndex = 0;

    _mockResponseTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (wordIndex < words.length) {
        // Send transcript delta
        _eventController.add(RealtimeEvent.fromJson({
          'type': 'response.audio_transcript.delta',
          'delta': '${words[wordIndex]} ',
        }));

        // Send fake audio delta (empty for mock)
        _eventController.add(RealtimeEvent.fromJson({
          'type': 'response.audio.delta',
          'item_id': 'mock_item_${_uuid.v4()}',
          'delta': '', // Empty audio in mock mode
        }));

        wordIndex++;
      } else {
        timer.cancel();

        // Send response.audio.done
        _eventController.add(RealtimeEvent.fromJson({
          'type': 'response.audio.done',
        }));

        // Send response.done
        Future.delayed(const Duration(milliseconds: 100), () {
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.done',
          }));
        });
      }
    });
  }

  /// Sets up the message handling pipeline for incoming WebSocket messages.
  void _setupMessageHandling() {
    _messageSubscription = _channel?.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
  }

  /// Configures the session with VAD, voice, and modality settings.
  ///
  /// This is called automatically after connection is established.
  /// The session.update event configures how the AI will behave.
  Future<void> _configureSession() async {
    if (_sessionConfig == null) {
      // ignore: avoid_print
      print('⚠️ No session config provided, using defaults');
      return;
    }

    final sessionConfig = _sessionConfig!.toSessionUpdate();

    // ignore: avoid_print
    print('📋 Configuring session with:');
    // ignore: avoid_print
    print('   - modalities: ${sessionConfig['modalities']}');
    // ignore: avoid_print
    print('   - voice: ${sessionConfig['voice']}');
    // ignore: avoid_print
    print('   - input_audio_format: ${sessionConfig['input_audio_format']}');
    // ignore: avoid_print
    print('   - turn_detection: ${sessionConfig['turn_detection']}');

    final sessionUpdate = {
      'type': 'session.update',
      'session': sessionConfig,
    };

    _sendEvent(sessionUpdate);
    // ignore: avoid_print
    print('📤 Session update event sent');
  }

  /// Starts a periodic timer for connection health monitoring.
  ///
  /// Note: WebSocket ping/pong is handled at the protocol level automatically.
  /// This timer is kept for potential future use (e.g., checking connection state).
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Connection health is monitored through the WebSocket protocol itself
      // No need to send explicit ping events - they're not supported by the API
      if (!isConnected && connectionState.value == ConnectionState.connected) {
        // Connection was lost unexpectedly, update state
        connectionState.value = ConnectionState.disconnected;
      }
    });
  }

  // ===========================================================================
  // MESSAGE HANDLING
  // ===========================================================================

  /// Handles incoming WebSocket messages.
  ///
  /// This method:
  /// 1. Parses the JSON message
  /// 2. Creates a typed RealtimeEvent
  /// 3. Broadcasts to the event stream
  /// 4. Handles audio data specially for playback
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message as String);
      final String type = data['type'] ?? '';

      // Parse into typed event and broadcast
      final event = RealtimeEvent.fromJson(data);
      _eventController.add(event);

      // Handle audio delta events specifically for streaming playback
      // These contain base64-encoded PCM audio chunks
      if (type == 'response.audio.delta') {
        final audioBase64 = data['delta'] as String?;
        if (audioBase64 != null) {
          final audioBytes = base64Decode(audioBase64);
          _audioOutputController.add(Uint8List.fromList(audioBytes));
        }
      }

      // Log important events for debugging (remove in production)
      _logEvent(type, data);
    } catch (e) {
      // Log parsing errors but don't crash
      // ignore: avoid_print
      print('Error parsing Real-Time API message: $e');
    }
  }

  /// Logs important events for debugging purposes.
  void _logEvent(String type, Map<String, dynamic> data) {
    // Log ALL events for debugging (can be reduced later)
    // ignore: avoid_print
    print('📡 Real-Time API Event: $type');

    // Track session configuration
    if (type == 'session.created') {
      // ignore: avoid_print
      print('✅ Session created - waiting for configuration...');
    } else if (type == 'session.updated') {
      isSessionConfigured.value = true;
      // ignore: avoid_print
      print('✅ Session configured successfully! VAD should now be active.');
      // Log the turn_detection config from the response
      final session = data['session'] as Map<String, dynamic>?;
      if (session != null) {
        final turnDetection = session['turn_detection'];
        // ignore: avoid_print
        print('   Turn detection: $turnDetection');
      }
    } else if (type == 'response.created') {
      _isResponseActive = true;
      // ignore: avoid_print
      print('🚀 Response started - cancel is now available');
    } else if (type == 'response.done' || type == 'response.cancelled') {
      _isResponseActive = false;
      // ignore: avoid_print
      print('✅ Response ended - cancel no longer needed');
    }

    // Log additional details for important events
    if (type == 'error') {
      // ignore: avoid_print
      print('❌ Error details: ${data['error']}');
    } else if (type == 'response.audio_transcript.delta') {
      final delta = data['delta'] ?? '';
      // ignore: avoid_print
      print('📝 Transcript delta: $delta');
    } else if (type == 'conversation.item.input_audio_transcription.completed') {
      final transcript = data['transcript'] ?? '';
      // ignore: avoid_print
      print('🎙️ User transcription: $transcript');
    } else if (type == 'input_audio_buffer.speech_started') {
      // ignore: avoid_print
      print('🎤 VAD detected speech start!');
    } else if (type == 'input_audio_buffer.speech_stopped') {
      // ignore: avoid_print
      print('🎤 VAD detected speech end!');
    }
  }

  /// Handles WebSocket errors.
  void _handleError(dynamic error) {
    connectionState.value = ConnectionState.error;
    _eventController.addError(error);

    // ignore: avoid_print
    print('Real-Time API WebSocket error: $error');

    // Attempt reconnection
    _attemptReconnect();
  }

  /// Handles WebSocket disconnection.
  void _handleDisconnect() {
    connectionState.value = ConnectionState.disconnected;

    // ignore: avoid_print
    print('Real-Time API WebSocket disconnected');

    // Attempt reconnection if not intentionally disconnected
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _attemptReconnect();
    }
  }

  /// Attempts to reconnect to the API with exponential backoff.
  Future<void> _attemptReconnect() async {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      // ignore: avoid_print
      print('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    // ignore: avoid_print
    print('Attempting reconnection in ${delay.inSeconds} seconds...');

    await Future.delayed(delay);

    if (connectionState.value != ConnectionState.connected) {
      // Use stored API key and config for reconnection
      await connect(apiKey: _storedApiKey, config: _sessionConfig);
    }
  }

  // ===========================================================================
  // AUDIO INPUT
  // ===========================================================================

  /// Counter for tracking audio chunks sent (for debugging)
  int _audioChunksSent = 0;

  /// Sends an audio chunk to the Real-Time API.
  ///
  /// The audio should be PCM 16-bit at 24kHz sample rate, mono channel.
  /// The data is base64-encoded before transmission.
  ///
  /// [audioData] - Raw PCM audio bytes
  ///
  /// This method is typically called continuously while the user is speaking.
  void sendAudioChunk(Uint8List audioData) {
    if (!isConnected) {
      // ignore: avoid_print
      print('⚠️ sendAudioChunk: Not connected, skipping chunk');
      return;
    }

    // Use mock mode if enabled
    if (useMockMode) {
      _sendAudioMock(audioData);
      return;
    }

    _audioChunksSent++;

    // Log every 50th chunk with audio level info
    if (_audioChunksSent % 50 == 0) {
      // Calculate audio level from PCM data
      double maxLevel = 0;
      for (int i = 0; i < audioData.length - 1; i += 2) {
        // Convert 2 bytes to signed 16-bit integer (little-endian)
        int sample = audioData[i] | (audioData[i + 1] << 8);
        if (sample > 32767) sample -= 65536; // Convert to signed
        double level = sample.abs() / 32768.0;
        if (level > maxLevel) maxLevel = level;
      }
      // ignore: avoid_print
      print('🎤 Audio chunk #$_audioChunksSent (${audioData.length} bytes, peak: ${(maxLevel * 100).toStringAsFixed(1)}%)');
    }

    final base64Audio = base64Encode(audioData);

    final event = {
      'type': 'input_audio_buffer.append',
      'audio': base64Audio,
    };

    _sendEvent(event);
  }

  /// Commits the audio buffer to signal end of speech (manual mode).
  ///
  /// This is used when VAD is disabled and you want to manually control
  /// when the user has finished speaking.
  ///
  /// Note: When using server-side VAD, this is handled automatically.
  void commitAudioBuffer() {
    if (!isConnected) return;

    // In mock mode, simulate the response when audio is committed
    if (useMockMode) {
      _simulateMockResponse();
      return;
    }

    _sendEvent({'type': 'input_audio_buffer.commit'});
  }

  /// Clears the audio buffer.
  ///
  /// Use this to discard any audio that hasn't been processed yet,
  /// for example when canceling the current input.
  void clearAudioBuffer() {
    if (!isConnected) return;
    _sendEvent({'type': 'input_audio_buffer.clear'});
  }

  // ===========================================================================
  // RESPONSE CONTROL
  // ===========================================================================

  /// Manually requests a response from the AI (manual mode).
  ///
  /// This is used when VAD is disabled and you want to manually trigger
  /// the AI to generate a response.
  ///
  /// Note: When using server-side VAD with create_response=true,
  /// responses are triggered automatically.
  void createResponse() {
    if (!isConnected) return;

    _sendEvent({
      'type': 'response.create',
      'response': {
        'modalities': ['text', 'audio'],
      },
    });
  }

  /// Cancels the current response (interruption handling).
  ///
  /// Call this when the user starts speaking to interrupt the AI (barge-in).
  /// This stops the AI from continuing to generate audio.
  ///
  /// Note: Only sends cancel if there's an active response to avoid
  /// `response_cancel_not_active` errors from the API.
  void cancelResponse() {
    // Cancel mock timer if in mock mode
    if (useMockMode) {
      _mockResponseTimer?.cancel();
      _mockResponseTimer = null;
      return;
    }

    if (!isConnected) return;

    // Only cancel if there's an active response to avoid API errors
    if (!_isResponseActive) {
      // ignore: avoid_print
      print('ℹ️ cancelResponse: No active response to cancel, skipping');
      return;
    }

    _sendEvent({'type': 'response.cancel'});
    _isResponseActive = false; // Optimistically set to false
  }

  /// Truncates the audio playback at a specific position.
  ///
  /// This is used for accurate context tracking when the user interrupts.
  /// It tells the API how much of the response audio was actually played.
  ///
  /// [itemId] - The ID of the conversation item being truncated
  /// [contentIndex] - The index of the content part (usually 0)
  /// [audioEndMs] - The position in milliseconds where playback stopped
  void truncateResponse(String itemId, int contentIndex, int audioEndMs) {
    if (!isConnected) return;

    _sendEvent({
      'type': 'conversation.item.truncate',
      'item_id': itemId,
      'content_index': contentIndex,
      'audio_end_ms': audioEndMs,
    });
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Sends an event to the Real-Time API.
  ///
  /// Automatically adds a unique event_id if not present.
  void _sendEvent(Map<String, dynamic> event) {
    if (_channel == null) return;

    // Add event_id if not present (helps with debugging and tracking)
    if (!event.containsKey('event_id')) {
      event['event_id'] = _uuid.v4();
    }

    try {
      _channel!.sink.add(jsonEncode(event));
    } catch (e) {
      // ignore: avoid_print
      print('Error sending event: $e');
    }
  }

  /// Disconnects from the Real-Time API.
  ///
  /// This closes the WebSocket connection and cleans up resources.
  /// Call this when the voice dialog is closed.
  Future<void> disconnect() async {
    // Cancel mock timer if active
    _mockResponseTimer?.cancel();
    _mockResponseTimer = null;
    _mockAudioChunkCount = 0;

    _pingTimer?.cancel();
    _pingTimer = null;

    await _messageSubscription?.cancel();
    _messageSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    _isResponseActive = false;
    connectionState.value = ConnectionState.disconnected;
  }

  /// Updates the session configuration.
  ///
  /// This can be called to change the AI's behavior mid-session,
  /// such as changing the system prompt or voice.
  Future<void> updateSession(VoiceSessionConfig config) async {
    _sessionConfig = config;
    await _configureSession();
  }

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  /// Called when the service is closed (GetX lifecycle).
  @override
  void onClose() {
    disconnect();
    _eventController.close();
    _audioOutputController.close();
    super.onClose();
  }
}

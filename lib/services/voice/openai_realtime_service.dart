/// Voice Realtime Service via Python Backend
///
/// This service manages the WebSocket connection to the Python FastAPI backend
/// which bridges to OpenAI's GPT Real-Time API for low-latency voice conversations.
///
/// The backend handles:
/// - Session management and authentication
/// - OpenAI API connection and configuration
/// - Audio transcription and response streaming
/// - User context (location, vessels, preferences)
///
/// The app sends PCM 16-bit audio at 24kHz sample rate.
///
/// Usage:
/// ```dart
/// final service = OpenAIRealtimeService();
/// await service.connect();
/// service.sendAudioChunk(audioData);
/// service.audioOutputStream.listen((audio) => playAudio(audio));
/// ```
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'backend_service.dart';
import 'realtime_events.dart';

/// Service for managing voice conversations via the Python backend.
///
/// This is a GetX service that can be registered globally and accessed
/// throughout the application. It provides:
/// - Session creation via backend API
/// - WebSocket connection management
/// - Event streaming
/// - Audio I/O
///
/// The service emits events through [eventStream] and audio through
/// [audioOutputStream] for the controller to handle.
///
/// ## Mock Mode
/// Set [useMockMode] to `true` to test the UI without a backend connection.
/// This simulates the Real-Time API responses for development testing.
class OpenAIRealtimeService extends GetxService {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  /// **MOCK MODE** - Set to `true` to test without a backend
  /// This simulates the Real-Time API for UI testing purposes.
  /// Set to `false` when you have the Python backend running.
  static const bool useMockMode = false;

  // ===========================================================================
  // PRIVATE PROPERTIES
  // ===========================================================================

  /// Backend service for session management
  BackendService? _backendService;

  /// The WebSocket channel for real-time communication
  WebSocketChannel? _channel;

  /// UUID generator for event IDs
  final Uuid _uuid = const Uuid();

  /// Stream subscription for WebSocket messages
  StreamSubscription? _messageSubscription;

  /// Timer for connection health checks (ping/pong)
  Timer? _pingTimer;

  /// Current session token
  String? _sessionToken;

  /// Number of reconnection attempts
  int _reconnectAttempts = 0;

  /// Maximum reconnection attempts before giving up
  static const int _maxReconnectAttempts = 3;

  /// Whether there's an active response being generated
  bool _isResponseActive = false;

  /// User's auth token for external APIs
  String? _authToken;

  /// User's current location
  String? _userLocation;

  /// Coordinates for weather data
  List<List<double>>? _coordinates;

  // ===========================================================================
  // REACTIVE PROPERTIES
  // ===========================================================================

  /// Current connection state (observable for UI updates)
  final Rx<ConnectionState> connectionState = ConnectionState.disconnected.obs;

  /// Whether the connection is currently active
  bool get isConnected => connectionState.value == ConnectionState.connected;

  /// Whether the session has been configured (received ready event)
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

  /// Stream of parsed events from the backend
  ///
  /// Subscribe to this stream to receive all events including:
  /// - ready
  /// - transcript (user and assistant)
  /// - status
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

  /// Establishes a connection to the Python backend via WebSocket.
  ///
  /// This method:
  /// 1. Creates a session via the backend API
  /// 2. Connects to the WebSocket with the session token
  /// 3. Waits for the 'ready' event from the backend
  ///
  /// [config] - Optional session configuration (used for mock mode only)
  /// [authToken] - Auth token for external APIs (weather, vessels)
  /// [userLocation] - User's current location name
  /// [coordinates] - Coordinates for weather data
  ///
  /// Returns true if connection was successful, false otherwise.
  Future<bool> connect({
    VoiceSessionConfig? config,
    String? authToken,
    String? userLocation,
    List<List<double>>? coordinates,
  }) async {
    // Don't connect if already connected
    if (isConnected) {
      return true;
    }

    // Use mock mode for testing without backend
    if (useMockMode) {
      return _connectMock(config);
    }

    try {
      connectionState.value = ConnectionState.connecting;

      // Store user context
      _authToken = authToken;
      _userLocation = userLocation;
      _coordinates = coordinates;

      // Get or create backend service
      if (!Get.isRegistered<BackendService>()) {
        Get.put<BackendService>(BackendService());
      }
      _backendService = Get.find<BackendService>();

      // Check backend health first
      // ignore: avoid_print
      print('Checking backend health...');
      final isHealthy = await _backendService!.checkHealth();
      if (!isHealthy) {
        // ignore: avoid_print
        print('Backend is not available');
        connectionState.value = ConnectionState.error;
        _eventController.addError('Backend is not available. Please check the connection.');
        return false;
      }
      // ignore: avoid_print
      print('Backend is healthy');

      // Create session
      // ignore: avoid_print
      print('Creating session...');
      final sessionRequest = SessionCreateRequest(
        authToken: _authToken,
        userLocation: _userLocation,
        coordinates: _coordinates,
      );

      final sessionResponse = await _backendService!.createSession(
        request: sessionRequest,
      );
      _sessionToken = sessionResponse.token;
      // ignore: avoid_print
      print('Session created: ${sessionResponse.conversationId}');

      // Build WebSocket URL
      final wsUrl = _backendService!.getWebSocketUrl(_sessionToken!);
      // ignore: avoid_print
      print('Connecting to WebSocket: $wsUrl');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for the connection to be established
      await _channel!.ready;
      // ignore: avoid_print
      print('WebSocket connection ready');

      // Set up message handling
      _setupMessageHandling();

      // Start ping/pong for connection health
      _startPingTimer();

      connectionState.value = ConnectionState.connected;
      _reconnectAttempts = 0;
      _audioChunksSent = 0;
      _isResponseActive = false;
      isSessionConfigured.value = false;

      // ignore: avoid_print
      print('Connection state set to connected');
      // ignore: avoid_print
      print('Waiting for ready event from backend...');

      return true;
    } catch (e) {
      connectionState.value = ConnectionState.error;
      _eventController.addError(e);

      // ignore: avoid_print
      print('Connection error: $e');

      return false;
    }
  }

  // ===========================================================================
  // MOCK MODE - For testing without backend
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

  /// Current mock phrase being "spoken"
  String _currentMockPhrase = '';

  /// Fixed mock AI response
  static const String _fixedMockResponse =
      "For your vessel, you should have the following essential safety equipment: "
      "Life jackets for all passengers, fire extinguisher, first aid kit, "
      "flares and distress signals, VHF radio, navigation lights, "
      "anchor and line, and a throwable flotation device. "
      "Would you like more details about any of these items?";

  /// Starts mock listening mode
  void startMockListening() {
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'input_audio_buffer.speech_started',
    }));
  }

  /// Sends a user message with real transcription and triggers mock AI response.
  void sendMockUserMessage(String userMessage) {
    _currentMockPhrase = userMessage;

    _eventController.add(RealtimeEvent.fromJson({
      'type': 'conversation.item.input_audio_transcription.completed',
      'transcript': userMessage,
    }));

    _triggerMockAIResponse(userMessage);
  }

  void _triggerMockAIResponse(String userMessage) {
    Future.delayed(const Duration(milliseconds: 300), () {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'response.created',
      }));
    });

    final mockResponse = _generateMockResponse(userMessage);
    final words = mockResponse.split(' ');
    int wordIndex = 0;

    Future.delayed(const Duration(milliseconds: 500), () {
      _mockResponseTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
        if (wordIndex < words.length) {
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio_transcript.delta',
            'delta': '${words[wordIndex]} ',
          }));

          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio.delta',
            'item_id': 'mock_item_${_uuid.v4()}',
            'delta': '',
          }));

          wordIndex++;
        } else {
          timer.cancel();

          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio.done',
          }));

          Future.delayed(const Duration(milliseconds: 100), () {
            _eventController.add(RealtimeEvent.fromJson({
              'type': 'response.done',
            }));
          });
        }
      });
    });
  }

  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('weather') || lowerMessage.contains('condition')) {
      return "Based on current conditions, the weather looks favorable for sailing today. "
          "Wind speeds are moderate at 10-15 knots from the southwest. "
          "Sea state is calm to moderate. However, always check the latest forecast before departure.";
    } else if (lowerMessage.contains('emergency') || lowerMessage.contains('help') || lowerMessage.contains('sos')) {
      return "For maritime emergencies, immediately call Mayday on VHF Channel 16. "
          "State your vessel name, position, nature of distress, and number of people aboard. "
          "Activate your EPIRB if available. Stay calm and await rescue instructions.";
    } else if (lowerMessage.contains('safety') || lowerMessage.contains('equipment')) {
      return _fixedMockResponse;
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

  Future<bool> _connectMock(VoiceSessionConfig? config) async {
    // ignore: avoid_print
    print('MOCK MODE: Simulating backend connection');

    connectionState.value = ConnectionState.connecting;

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate session.created event
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'session.created',
      'session': {'id': 'mock_session_${_uuid.v4()}'},
    }));

    connectionState.value = ConnectionState.connected;
    isSessionConfigured.value = true;

    // Simulate ready event
    _eventController.add(RealtimeEvent.fromJson({
      'type': 'ready',
    }));

    // ignore: avoid_print
    print('MOCK MODE: Connected successfully');

    return true;
  }

  void _sendAudioMock(Uint8List audioData) {
    _mockAudioChunkCount++;

    if (_mockAudioChunkCount == 3) {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'input_audio_buffer.speech_started',
      }));

      _startMockUserTranscription();
    }
  }

  void _startMockUserTranscription() {
    _currentMockPhrase = _mockUserPhrases[
        DateTime.now().millisecondsSinceEpoch % _mockUserPhrases.length];
    final words = _currentMockPhrase.split(' ');
    _mockUserWordIndex = 0;

    _mockTranscriptionTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) {
        if (_mockUserWordIndex < words.length) {
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

  void _stopMockUserTranscription() {
    _mockTranscriptionTimer?.cancel();
    _mockTranscriptionTimer = null;
  }

  void _simulateMockResponse() {
    _stopMockUserTranscription();
    _mockAudioChunkCount = 0;

    _eventController.add(RealtimeEvent.fromJson({
      'type': 'input_audio_buffer.speech_stopped',
    }));

    final finalTranscript = _currentMockPhrase.isNotEmpty
        ? _currentMockPhrase
        : 'Hello, I need help with maritime safety.';

    Future.delayed(const Duration(milliseconds: 300), () {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'conversation.item.input_audio_transcription.completed',
        'transcript': finalTranscript,
      }));
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _eventController.add(RealtimeEvent.fromJson({
        'type': 'response.created',
      }));
    });

    final mockResponse = _fixedMockResponse;
    final words = mockResponse.split(' ');
    int wordIndex = 0;

    _mockResponseTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (wordIndex < words.length) {
        _eventController.add(RealtimeEvent.fromJson({
          'type': 'response.audio_transcript.delta',
          'delta': '${words[wordIndex]} ',
        }));

        _eventController.add(RealtimeEvent.fromJson({
          'type': 'response.audio.delta',
          'item_id': 'mock_item_${_uuid.v4()}',
          'delta': '',
        }));

        wordIndex++;
      } else {
        timer.cancel();

        _eventController.add(RealtimeEvent.fromJson({
          'type': 'response.audio.done',
        }));

        Future.delayed(const Duration(milliseconds: 100), () {
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.done',
          }));
        });
      }
    });
  }

  // ===========================================================================
  // MESSAGE HANDLING
  // ===========================================================================

  void _setupMessageHandling() {
    _messageSubscription = _channel?.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isConnected && connectionState.value == ConnectionState.connected) {
        connectionState.value = ConnectionState.disconnected;
      }
    });
  }

  /// Handles incoming WebSocket messages from the Python backend.
  ///
  /// Backend message types:
  /// - ready: Session is configured and ready
  /// - audio: Base64-encoded PCM audio chunk
  /// - audio_done: Audio streaming complete
  /// - transcript: User or assistant transcription
  /// - transcript_delta: Streaming transcript chunk
  /// - status: Connection status update
  /// - transcription_failed: Transcription error (non-critical)
  /// - error: Error message
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message as String);
      final String type = data['type'] ?? '';

      // Log all events
      // ignore: avoid_print
      print('Backend event: $type');

      // Convert backend events to RealtimeEvent format for controller compatibility
      switch (type) {
        case 'ready':
          // Backend session is ready
          isSessionConfigured.value = true;
          // ignore: avoid_print
          print('Session configured and ready');
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'session.updated',
          }));
          break;

        case 'audio':
          // Audio chunk from AI response
          final audioBase64 = data['data'] as String?;
          if (audioBase64 != null && audioBase64.isNotEmpty) {
            final audioBytes = base64Decode(audioBase64);
            _audioOutputController.add(Uint8List.fromList(audioBytes));

            // Also emit as response.audio.delta for controller compatibility
            _eventController.add(RealtimeEvent.fromJson({
              'type': 'response.audio.delta',
              'delta': audioBase64,
            }));
          }
          break;

        case 'audio_done':
          // Audio streaming complete
          // ignore: avoid_print
          print('AI audio streaming complete');
          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio.done',
          }));
          break;

        case 'transcript':
          // Complete transcription (user or assistant)
          final text = data['text'] as String? ?? '';
          final role = data['role'] as String? ?? 'user';
          // ignore: avoid_print
          print('$role transcript: $text');

          if (role == 'user') {
            _eventController.add(RealtimeEvent.fromJson({
              'type': 'conversation.item.input_audio_transcription.completed',
              'transcript': text,
            }));
          } else {
            // Assistant transcript done
            _eventController.add(RealtimeEvent.fromJson({
              'type': 'response.audio_transcript.done',
              'transcript': text,
            }));
          }
          break;

        case 'transcript_delta':
          // Streaming transcript chunk
          final delta = data['delta'] as String? ?? '';
          final role = data['role'] as String? ?? 'assistant';

          _eventController.add(RealtimeEvent.fromJson({
            'type': 'response.audio_transcript.delta',
            'delta': delta,
          }));
          break;

        case 'status':
          // Status update from backend
          final status = data['status'] as String? ?? '';
          // ignore: avoid_print
          print('Status: $status');

          switch (status) {
            case 'speaking':
              _isResponseActive = true;
              _eventController.add(RealtimeEvent.fromJson({
                'type': 'response.created',
              }));
              break;
            case 'listening':
              _isResponseActive = false;
              _eventController.add(RealtimeEvent.fromJson({
                'type': 'response.done',
              }));
              break;
            case 'user_speaking':
              _eventController.add(RealtimeEvent.fromJson({
                'type': 'input_audio_buffer.speech_started',
              }));
              break;
            case 'processing':
              _eventController.add(RealtimeEvent.fromJson({
                'type': 'input_audio_buffer.speech_stopped',
              }));
              break;
          }
          break;

        case 'transcription_failed':
          // Non-critical transcription error
          final errorMsg = data['message'] as String? ?? 'Transcription failed';
          // ignore: avoid_print
          print('Transcription failed (non-critical): $errorMsg');
          break;

        case 'error':
          // Error from backend
          final errorMsg = data['message'] as String? ?? 'Unknown error';
          final errorCode = data['code'] as String? ?? 'unknown';
          // ignore: avoid_print
          print('Error: $errorCode - $errorMsg');

          // Don't break for recoverable errors
          if (errorCode == 'response_cancel_not_active' ||
              errorCode == 'conversation_already_exists') {
            return;
          }

          _eventController.add(RealtimeEvent.fromJson({
            'type': 'error',
            'error': {'message': errorMsg, 'code': errorCode},
          }));
          break;

        default:
          // Unknown event type - log for debugging
          // ignore: avoid_print
          print('Unknown backend event: $type');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing backend message: $e');
    }
  }

  void _handleError(dynamic error) {
    connectionState.value = ConnectionState.error;
    _eventController.addError(error);

    // ignore: avoid_print
    print('WebSocket error: $error');

    _attemptReconnect();
  }

  void _handleDisconnect() {
    connectionState.value = ConnectionState.disconnected;

    // ignore: avoid_print
    print('WebSocket disconnected');

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _attemptReconnect();
    }
  }

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
      await connect(
        authToken: _authToken,
        userLocation: _userLocation,
        coordinates: _coordinates,
      );
    }
  }

  // ===========================================================================
  // AUDIO INPUT
  // ===========================================================================

  int _audioChunksSent = 0;

  /// Sends an audio chunk to the backend.
  ///
  /// The audio should be PCM 16-bit at 24kHz sample rate, mono channel.
  /// The data is base64-encoded before transmission.
  void sendAudioChunk(Uint8List audioData) {
    if (!isConnected) {
      // ignore: avoid_print
      print('sendAudioChunk: Not connected, skipping chunk');
      return;
    }

    if (useMockMode) {
      _sendAudioMock(audioData);
      return;
    }

    _audioChunksSent++;

    if (_audioChunksSent % 50 == 0) {
      double maxLevel = 0;
      for (int i = 0; i < audioData.length - 1; i += 2) {
        int sample = audioData[i] | (audioData[i + 1] << 8);
        if (sample > 32767) sample -= 65536;
        double level = sample.abs() / 32768.0;
        if (level > maxLevel) maxLevel = level;
      }
      // ignore: avoid_print
      print('Audio chunk #$_audioChunksSent (${audioData.length} bytes, peak: ${(maxLevel * 100).toStringAsFixed(1)}%)');
    }

    final base64Audio = base64Encode(audioData);

    // Send in backend format
    final message = jsonEncode({
      'type': 'audio',
      'data': base64Audio,
    });

    _channel?.sink.add(message);
  }

  /// Commits the audio buffer to signal end of speech.
  ///
  /// Note: With server-side VAD, this is typically not needed.
  void commitAudioBuffer() {
    if (!isConnected) return;

    if (useMockMode) {
      _simulateMockResponse();
      return;
    }

    final message = jsonEncode({'type': 'commit'});
    _channel?.sink.add(message);
  }

  /// Clears the audio buffer.
  void clearAudioBuffer() {
    if (!isConnected) return;

    // Backend doesn't have a clear command, but we can cancel
    // which effectively discards buffered audio
    final message = jsonEncode({'type': 'cancel'});
    _channel?.sink.add(message);
  }

  // ===========================================================================
  // RESPONSE CONTROL
  // ===========================================================================

  /// Manually requests a response from the AI.
  ///
  /// Note: With server-side VAD, responses are triggered automatically.
  void createResponse() {
    if (!isConnected) return;

    // Backend uses commit to trigger response
    final message = jsonEncode({'type': 'commit'});
    _channel?.sink.add(message);
  }

  /// Cancels the current response (interruption handling).
  void cancelResponse() {
    if (useMockMode) {
      _mockResponseTimer?.cancel();
      _mockResponseTimer = null;
      return;
    }

    if (!isConnected) return;

    if (!_isResponseActive) {
      // ignore: avoid_print
      print('cancelResponse: No active response to cancel');
      return;
    }

    final message = jsonEncode({'type': 'cancel'});
    _channel?.sink.add(message);
    _isResponseActive = false;
  }

  /// Truncates the audio playback at a specific position.
  ///
  /// Note: Backend handles this internally, this is a no-op for compatibility.
  void truncateResponse(String itemId, int contentIndex, int audioEndMs) {
    // Backend handles truncation internally
    // This method is kept for API compatibility
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Disconnects from the backend.
  Future<void> disconnect() async {
    _mockResponseTimer?.cancel();
    _mockResponseTimer = null;
    _mockAudioChunkCount = 0;

    _pingTimer?.cancel();
    _pingTimer = null;

    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // Send close message to backend
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode({'type': 'close'}));
      } catch (_) {}
    }

    await _channel?.sink.close();
    _channel = null;

    _isResponseActive = false;
    _sessionToken = null;
    connectionState.value = ConnectionState.disconnected;

    // Clear backend session
    _backendService?.clearSession();
  }

  /// Updates the session configuration.
  ///
  /// Note: Backend controls session config, this is a no-op for compatibility.
  Future<void> updateSession(VoiceSessionConfig config) async {
    // Backend controls session configuration
    // This method is kept for API compatibility
  }

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void onClose() {
    disconnect();
    _eventController.close();
    _audioOutputController.close();
    super.onClose();
  }
}

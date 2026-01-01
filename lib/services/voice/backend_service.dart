/// Backend API Service for AiSeaSafe
///
/// This service handles communication with the Python FastAPI backend
/// for session management and realtime voice conversations.
///
/// The backend provides:
/// - Session token generation for WebSocket authentication
/// - WebSocket bridge to OpenAI Realtime API
/// - User context and preferences management
library;

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// =============================================================================
// SESSION MODELS
// =============================================================================

/// Request model for creating a new voice session
class SessionCreateRequest {
  /// User's auth token for external APIs (weather, vessels)
  final String? authToken;

  /// User's current location name
  final String? userLocation;

  /// Route coordinates for weather [[lat, lon], ...]
  final List<List<double>>? coordinates;

  /// Conversation ID for resuming previous sessions
  final String? conversationId;

  /// Whether to preload weather data into voice session context
  /// Set to false to disable automatic weather preloading (default: true)
  final bool preloadWeather;

  const SessionCreateRequest({
    this.authToken,
    this.userLocation,
    this.coordinates,
    this.conversationId,
    this.preloadWeather = true,
  });

  Map<String, dynamic> toJson() {
    return {
      if (authToken != null) 'auth_token': authToken,
      if (userLocation != null) 'user_location': userLocation,
      if (coordinates != null) 'coordinates': coordinates,
      if (conversationId != null) 'conversation_id': conversationId,
      'preload_weather': preloadWeather,
    };
  }
}

/// Response model from session creation
class SessionCreateResponse {
  /// Session token for WebSocket authentication
  final String token;

  /// Unique conversation identifier
  final String conversationId;

  /// Token expiration time in seconds
  final int expiresIn;

  /// WebSocket URL to connect to
  final String websocketUrl;

  const SessionCreateResponse({
    required this.token,
    required this.conversationId,
    required this.expiresIn,
    required this.websocketUrl,
  });

  factory SessionCreateResponse.fromJson(Map<String, dynamic> json) {
    return SessionCreateResponse(
      token: json['token'] as String,
      conversationId: json['conversation_id'] as String,
      expiresIn: json['expires_in'] as int,
      websocketUrl: json['websocket_url'] as String,
    );
  }
}

// =============================================================================
// BACKEND SERVICE
// =============================================================================

/// Service for communicating with the Python FastAPI backend.
///
/// This GetX service manages:
/// - Session creation for WebSocket authentication
/// - Backend health checks
/// - User context preparation
class BackendService extends GetxService {
  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Base URL for the backend API
  static String get _baseUrl {
    final url = dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000';
    // Remove trailing slash if present
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Auth token for external APIs
  static String? get _authToken => dotenv.env['AUTH_TOKEN'];

  // ===========================================================================
  // REACTIVE PROPERTIES
  // ===========================================================================

  /// Whether the backend is reachable
  final RxBool isBackendAvailable = false.obs;

  /// Current session token (if any)
  final Rxn<String> currentToken = Rxn<String>();

  /// Current conversation ID (if any)
  final Rxn<String> currentConversationId = Rxn<String>();

  // ===========================================================================
  // API METHODS
  // ===========================================================================

  /// Checks if the backend is available.
  ///
  /// Returns true if the health endpoint responds successfully.
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      isBackendAvailable.value = response.statusCode == 200;
      return isBackendAvailable.value;
    } catch (e) {
      // ignore: avoid_print
      print('Backend health check failed: $e');
      isBackendAvailable.value = false;
      return false;
    }
  }

  /// Creates a new voice session.
  ///
  /// This must be called before connecting to the WebSocket.
  /// Returns the session details including the token for authentication.
  ///
  /// [request] - Session configuration with user context
  ///
  /// Returns [SessionCreateResponse] on success, throws on failure.
  Future<SessionCreateResponse> createSession({
    SessionCreateRequest? request,
  }) async {
    try {
      final requestBody = request ?? SessionCreateRequest(
        authToken: _authToken,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/session'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sessionResponse = SessionCreateResponse.fromJson(data);

        // Store for later use
        currentToken.value = sessionResponse.token;
        currentConversationId.value = sessionResponse.conversationId;

        // ignore: avoid_print
        print('Session created: ${sessionResponse.conversationId}');
        return sessionResponse;
      } else {
        throw Exception('Failed to create session: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Session creation error: $e');
      rethrow;
    }
  }

  /// Gets the WebSocket URL for the current session.
  ///
  /// [token] - Session token from [createSession]
  ///
  /// Returns the full WebSocket URL with token parameter.
  String getWebSocketUrl(String token) {
    // Convert HTTP URL to WebSocket URL
    String wsUrl = _baseUrl;
    if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    }

    return '$wsUrl/ws?token=$token';
  }

  /// Clears the current session.
  void clearSession() {
    currentToken.value = null;
    currentConversationId.value = null;
  }

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    // Check backend health on initialization
    checkHealth();
  }

  @override
  void onClose() {
    clearSession();
    super.onClose();
  }
}

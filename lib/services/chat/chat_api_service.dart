/// Chat API Service for AiSeaSafe
///
/// This service handles communication with the backend for text-based chat
/// with structured AI responses (weather, assistance, route, normal).
///
/// Features:
/// - Regular chat with structured responses
/// - Streaming chat with real-time updates
/// - Context-aware chat with conversation history
/// - Session management for voice/text switching
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../data/models/ai_response_models.dart';

// =============================================================================
// REQUEST MODELS
// =============================================================================

/// Request model for chat messages
class ChatRequest {
  final String message;
  final String? authToken;
  final List<ChatMessage>? conversationHistory;
  final String? userLocation;
  final List<List<double>>? coordinates;
  final List<VesselInfo>? vessels;

  const ChatRequest({
    required this.message,
    this.authToken,
    this.conversationHistory,
    this.userLocation,
    this.coordinates,
    this.vessels,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (authToken != null) 'auth_token': authToken,
      if (conversationHistory != null)
        'conversation_history': conversationHistory!.map((m) => m.toJson()).toList(),
      if (userLocation != null) 'user_location': userLocation,
      if (coordinates != null) 'coordinates': coordinates,
      if (vessels != null) 'vessels': vessels!.map((v) => v.toJson()).toList(),
    };
  }
}

/// Chat message for history
class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.user(String content) => ChatMessage(role: 'user', content: content);
  factory ChatMessage.assistant(String content) => ChatMessage(role: 'assistant', content: content);

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Vessel information for context
class VesselInfo {
  final String make;
  final String model;
  final String year;

  const VesselInfo({required this.make, required this.model, required this.year});

  Map<String, dynamic> toJson() => {'make': make, 'model': model, 'year': year};
}

// =============================================================================
// STREAMING EVENT MODELS
// =============================================================================

/// Types of streaming events
enum StreamEventType {
  status,
  toolStart,
  toolComplete,
  messageDelta,
  complete,
  error,
}

/// Streaming event from SSE
class StreamEvent {
  final StreamEventType type;
  final Map<String, dynamic> data;

  const StreamEvent({required this.type, required this.data});

  factory StreamEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'error';
    StreamEventType type;

    switch (typeStr) {
      case 'status':
        type = StreamEventType.status;
        break;
      case 'tool_start':
        type = StreamEventType.toolStart;
        break;
      case 'tool_complete':
        type = StreamEventType.toolComplete;
        break;
      case 'message_delta':
        type = StreamEventType.messageDelta;
        break;
      case 'complete':
        type = StreamEventType.complete;
        break;
      default:
        type = StreamEventType.error;
    }

    return StreamEvent(type: type, data: json);
  }

  String? get status => data['status'] as String?;
  String? get tool => data['tool'] as String?;
  bool? get success => data['success'] as bool?;
  String? get content => data['content'] as String?;
  Map<String, dynamic>? get response => data['response'] as Map<String, dynamic>?;
  String? get message => data['message'] as String?;
}

// =============================================================================
// CHAT API SERVICE
// =============================================================================

/// Service for handling chat API requests with structured responses
class ChatApiService extends GetxService {
  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  /// Base URL for the backend API
  static String get _baseUrl {
    final url = dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Auth token for API calls
  static String? get _authToken => dotenv.env['AUTH_TOKEN'];

  // ===========================================================================
  // REACTIVE PROPERTIES
  // ===========================================================================

  /// Current conversation ID for context
  final Rxn<String> currentConversationId = Rxn<String>();

  /// Conversation history
  final RxList<ChatMessage> conversationHistory = <ChatMessage>[].obs;

  /// Whether a request is in progress
  final RxBool isLoading = false.obs;

  /// Latest response
  final Rxn<AIResponse> latestResponse = Rxn<AIResponse>();

  /// Streaming message accumulator
  final RxString streamingMessage = ''.obs;

  // ===========================================================================
  // API METHODS
  // ===========================================================================

  /// Send a chat message and get a structured response
  Future<AIResponse> sendMessage({
    required String message,
    String? userLocation,
    List<List<double>>? coordinates,
    List<VesselInfo>? vessels,
  }) async {
    isLoading.value = true;

    try {
      final request = ChatRequest(
        message: message,
        authToken: _authToken,
        conversationHistory: conversationHistory.isNotEmpty ? conversationHistory.toList() : null,
        userLocation: userLocation,
        coordinates: coordinates,
        vessels: vessels,
      );

      print('======== CHAT REQUEST ========');
      print('URL: $_baseUrl/maritime-chat');
      print('Request: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse('$_baseUrl/maritime-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 60));

      print('======== CHAT RESPONSE ========');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        print('======== PARSED JSON ========');
        print('Type: ${json['response']?['type']}');
        print('Has Report: ${json['response']?['report'] != null}');
        print('Has Assistance: ${json['response']?['local_assistance'] != null}');
        print('Has Trip Plan: ${json['response']?['trip_plan'] != null}');

        final aiResponse = AIResponse.fromJson(json);
        print('======== AI RESPONSE ========');
        print('Response Type: ${aiResponse.type}');
        print('Message: ${aiResponse.message.substring(0, aiResponse.message.length.clamp(0, 100))}...');

        // Update conversation history
        conversationHistory.add(ChatMessage.user(message));
        conversationHistory.add(ChatMessage.assistant(aiResponse.message));

        latestResponse.value = aiResponse;
        return aiResponse;
      } else {
        throw Exception('Chat request failed: ${response.statusCode}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Send a chat message with context (shared with voice sessions)
  Future<AIResponse> sendMessageWithContext({
    required String message,
    required String conversationId,
    String? userLocation,
    List<List<double>>? coordinates,
    List<VesselInfo>? vessels,
  }) async {
    isLoading.value = true;
    currentConversationId.value = conversationId;

    try {
      final request = ChatRequest(
        message: message,
        authToken: _authToken,
        userLocation: userLocation,
        coordinates: coordinates,
        vessels: vessels,
      );

      final uri = Uri.parse('$_baseUrl/chat/with-context').replace(
        queryParameters: {'conversation_id': conversationId},
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final aiResponse = AIResponse.fromJson(json);

        latestResponse.value = aiResponse;
        return aiResponse;
      } else {
        throw Exception('Chat with context failed: ${response.statusCode}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Stream a chat response with real-time updates
  Stream<StreamEvent> streamMessage({
    required String message,
    String? userLocation,
    List<List<double>>? coordinates,
    List<VesselInfo>? vessels,
  }) async* {
    isLoading.value = true;
    streamingMessage.value = '';

    try {
      final request = ChatRequest(
        message: message,
        authToken: _authToken,
        conversationHistory: conversationHistory.isNotEmpty ? conversationHistory.toList() : null,
        userLocation: userLocation,
        coordinates: coordinates,
        vessels: vessels,
      );

      final httpRequest = http.Request('POST', Uri.parse('$_baseUrl/maritime-chat/stream'));
      httpRequest.headers['Content-Type'] = 'application/json';
      httpRequest.body = jsonEncode(request.toJson());

      final streamedResponse = await http.Client().send(httpRequest);

      if (streamedResponse.statusCode != 200) {
        throw Exception('Streaming request failed: ${streamedResponse.statusCode}');
      }

      // Parse SSE stream
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr.isNotEmpty) {
              try {
                final json = jsonDecode(jsonStr) as Map<String, dynamic>;
                final event = StreamEvent.fromJson(json);

                // Accumulate message content
                if (event.type == StreamEventType.messageDelta && event.content != null) {
                  streamingMessage.value += event.content!;
                }

                // Handle complete event
                if (event.type == StreamEventType.complete && event.response != null) {
                  final aiResponse = AIResponse.fromJson(event.response!);
                  latestResponse.value = aiResponse;

                  // Update conversation history
                  conversationHistory.add(ChatMessage.user(message));
                  conversationHistory.add(ChatMessage.assistant(aiResponse.message));
                }

                yield event;
              } catch (e) {
                // Skip malformed JSON
              }
            }
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // CONVERSATION MANAGEMENT
  // ===========================================================================

  /// Clear conversation history
  void clearHistory() {
    conversationHistory.clear();
    latestResponse.value = null;
    streamingMessage.value = '';
  }

  /// Set conversation ID (for voice/text switching)
  void setConversationId(String? id) {
    currentConversationId.value = id;
  }

  /// Add a message to history
  void addToHistory(ChatMessage message) {
    conversationHistory.add(message);
  }

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void onClose() {
    clearHistory();
    super.onClose();
  }
}

// =============================================================================
// RESPONSE PARSER UTILITY
// =============================================================================

/// Utility class for parsing AI responses
class AIResponseParser {
  /// Parse a raw JSON string into an AIResponse
  static AIResponse? parseResponse(String jsonString) {
    try {
      return AIResponse.fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Parse a response from Map
  static AIResponse? parseFromMap(Map<String, dynamic> json) {
    try {
      return AIResponse.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Extract just the message from a response
  static String extractMessage(Map<String, dynamic> json) {
    try {
      final response = json['response'] as Map<String, dynamic>?;
      return response?['message'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Determine response type from JSON
  static AIResponseType getResponseType(Map<String, dynamic> json) {
    try {
      final response = json['response'] as Map<String, dynamic>?;
      final typeStr = response?['type'] as String? ?? 'normal';
      return AIResponseType.fromString(typeStr);
    } catch (e) {
      return AIResponseType.normal;
    }
  }
}

/// Voice Conversation Controller
///
/// This GetX controller manages the voice conversation dialog state and
/// coordinates between the OpenAI Real-Time API service and the Audio service.
///
/// Features continuous listening mode:
/// - Auto-starts listening when ready
/// - Streams transcription in real-time
/// - Streams AI response
/// - Auto-restarts listening after AI finishes
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import 'audio_stream_service.dart';
import 'openai_realtime_service.dart';
import 'realtime_events.dart';
import 'speech_recognition_service.dart';

// =============================================================================
// DIALOG STATE ENUM
// =============================================================================

/// Represents the current state of the voice dialog.
enum VoiceDialogState {
  /// Initial state - services are being set up
  initializing,

  /// Ready and listening for user speech
  listening,

  /// Processing user input (brief transition state)
  processing,

  /// AI is responding (streaming response)
  aiSpeaking,

  /// An error occurred
  error,
}

// =============================================================================
// VOICE CONVERSATION CONTROLLER
// =============================================================================

/// Controller for managing continuous voice conversation.
///
/// This controller implements a hands-free voice conversation experience:
/// 1. Auto-starts listening when initialized
/// 2. Detects speech and transcribes in real-time
/// 3. Sends to AI when user pauses
/// 4. Streams AI response
/// 5. Auto-restarts listening when AI finishes
class VoiceConversationController extends GetxController {
  // ===========================================================================
  // DEPENDENCIES
  // ===========================================================================

  late final OpenAIRealtimeService _realtimeService;
  late final AudioStreamService _audioService;
  late final SpeechRecognitionService _speechRecognitionService;

  // ===========================================================================
  // REACTIVE STATE PROPERTIES
  // ===========================================================================

  /// Current state of the voice dialog
  final Rx<VoiceDialogState> dialogState = VoiceDialogState.initializing.obs;

  /// Status message to display to the user
  final RxString statusMessage = 'Initializing...'.obs;

  /// Transcribed text from user's speech
  final RxString transcribedText = ''.obs;

  /// Live transcription text (streaming while user speaks)
  final RxString liveTranscription = ''.obs;

  /// AI's response text (streaming)
  final RxString aiResponseText = ''.obs;

  /// Current audio input level (0.0 to 1.0) for waveform visualization
  final RxDouble audioLevel = 0.0.obs;

  /// Whether the user is currently speaking
  final RxBool isUserSpeaking = false.obs;

  /// Whether the AI is currently speaking
  final RxBool isAISpeaking = false.obs;

  /// Whether there's an active error
  final RxBool hasError = false.obs;

  /// Error message to display
  final RxString errorMessage = ''.obs;

  /// Conversation history for display
  final RxList<ConversationTurn> conversationHistory = <ConversationTurn>[].obs;

  /// Whether continuous listening is paused (user can pause/resume)
  final RxBool isPaused = false.obs;

  // ===========================================================================
  // PRIVATE PROPERTIES
  // ===========================================================================

  StreamSubscription? _eventSubscription;
  StreamSubscription? _audioOutputSubscription;
  StreamSubscription? _recordingLevelSubscription;
  StreamSubscription? _speechTranscriptionSubscription;
  StreamSubscription? _speechFinalSubscription;
  StreamSubscription? _speechStatusSubscription;

  String? _currentResponseItemId;
  int _currentAudioPosition = 0;
  bool _isInitialized = false;

  /// Timer to detect silence and trigger AI response
  Timer? _silenceTimer;
  static const Duration _silenceThreshold = Duration(milliseconds: 1500);

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      dialogState.value = VoiceDialogState.initializing;
      statusMessage.value = 'Setting up voice assistant...';

      _registerServices();

      statusMessage.value = 'Initializing audio...';
      final audioReady = await _audioService.initialize();
      if (!audioReady) {
        _setError('Failed to initialize audio. Please check microphone permissions.');
        return;
      }

      statusMessage.value = 'Connecting to AI...';
      final connected = await _realtimeService.connect(
        config: VoiceSessionConfig.maritimeSafety(),
      );

      if (!connected) {
        _setError('Failed to connect to AI service. Please check your internet connection.');
        return;
      }

      _setupEventListeners();

      // Wait for session to be configured (VAD enabled)
      statusMessage.value = 'Configuring voice assistant...';
      // ignore: avoid_print
      print('⏳ Waiting for session configuration...');

      // Wait up to 5 seconds for session.updated event
      int waitCount = 0;
      while (!_realtimeService.isSessionConfigured.value && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }

      if (!_realtimeService.isSessionConfigured.value) {
        // ignore: avoid_print
        print('⚠️ Session configuration not confirmed after 5 seconds, proceeding anyway');
      } else {
        // ignore: avoid_print
        print('✅ Session configured, ready to start listening');
      }

      _isInitialized = true;

      // Auto-start listening in continuous mode
      await _startContinuousListening();
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
    }
  }

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

  void _setupEventListeners() {
    _eventSubscription = _realtimeService.eventStream.listen(
      _handleRealtimeEvent,
      onError: (error) => _setError('Connection error: $error'),
    );

    _audioOutputSubscription = _realtimeService.audioOutputStream.listen(
      _handleAudioOutput,
    );

    _recordingLevelSubscription = _audioService.recordingLevel.listen((level) {
      audioLevel.value = level;
    });

    _setupSpeechRecognitionListeners();
  }

  Future<void> _setupSpeechRecognitionListeners() async {
    final available = await _speechRecognitionService.initialize();
    if (!available) {
      // ignore: avoid_print
      print('Speech recognition not available on this device');
      return;
    }

    // Listen to live transcription updates
    _speechTranscriptionSubscription =
        _speechRecognitionService.transcriptionStream?.listen((transcript) {
      liveTranscription.value = transcript;
      _resetSilenceTimer();
    });

    // Also listen to reactive property
    ever(_speechRecognitionService.currentTranscription, (String transcript) {
      final fullText = _speechRecognitionService.fullTranscription.value;
      final displayText = fullText.isEmpty ? transcript : '$fullText $transcript';
      liveTranscription.value = displayText;
      _resetSilenceTimer();
    });

    // Listen to final transcription
    _speechFinalSubscription =
        _speechRecognitionService.finalTranscriptionStream?.listen((transcript) {
      if (transcript.isNotEmpty) {
        transcribedText.value = transcript;
      }
    });

    // Listen to speech status
    _speechStatusSubscription =
        _speechRecognitionService.statusStream?.listen((status) {
      if (status == SpeechStatus.done && dialogState.value == VoiceDialogState.listening) {
        _onUserFinishedSpeaking();
      }
    });
  }

  // ===========================================================================
  // CONTINUOUS LISTENING
  // ===========================================================================

  /// Starts continuous listening mode
  Future<void> _startContinuousListening() async {
    // ignore: avoid_print
    print('🎧 _startContinuousListening called (initialized: $_isInitialized, paused: ${isPaused.value})');

    if (!_isInitialized || isPaused.value) {
      // ignore: avoid_print
      print('⚠️ Cannot start listening - not initialized or paused');
      return;
    }

    // Clear previous conversation round
    liveTranscription.value = '';
    transcribedText.value = '';

    dialogState.value = VoiceDialogState.listening;
    statusMessage.value = 'Listening...';
    isUserSpeaking.value = false;

    // ignore: avoid_print
    print('🎧 State set to listening, useMockMode: ${OpenAIRealtimeService.useMockMode}');

    if (OpenAIRealtimeService.useMockMode) {
      _audioService.startMockAmplitudeStream();

      if (_speechRecognitionService.isAvailable.value) {
        await _speechRecognitionService.startListening();
      }
    } else {
      // ignore: avoid_print
      print('🎤 Starting real audio recording...');
      final started = await _audioService.startRecording(
        onAudioChunk: (chunk) {
          _realtimeService.sendAudioChunk(chunk);
        },
      );

      if (!started) {
        // ignore: avoid_print
        print('❌ Failed to start recording');
        _setError('Failed to start recording.');
      } else {
        // ignore: avoid_print
        print('✅ Recording started successfully');
      }
    }
  }

  /// Called when silence is detected after user speech
  void _onUserFinishedSpeaking() {
    // ignore: avoid_print
    print('🔇 _onUserFinishedSpeaking called (state: ${dialogState.value})');

    _silenceTimer?.cancel();
    _silenceTimer = null;

    if (dialogState.value != VoiceDialogState.listening) {
      // ignore: avoid_print
      print('⚠️ Not in listening state, ignoring');
      return;
    }

    // In real mode with server VAD, the API automatically creates response
    // We just need to update state and stop recording
    if (!OpenAIRealtimeService.useMockMode) {
      // ignore: avoid_print
      print('🚀 Real mode: Transitioning to processing, API will auto-respond');
      dialogState.value = VoiceDialogState.processing;
      statusMessage.value = 'Processing...';
      isUserSpeaking.value = false;

      // Stop recording - the API will handle the response automatically
      // due to server_vad with create_response: true
      _stopCurrentListening();
      return;
    }

    // Mock mode - need to get transcription and send manually
    String userText = _speechRecognitionService.fullTranscription.value;
    if (userText.isEmpty) {
      userText = _speechRecognitionService.currentTranscription.value;
    }
    if (userText.isEmpty) {
      userText = liveTranscription.value;
    }

    if (userText.isEmpty) {
      // No speech detected, keep listening
      return;
    }

    // Update state
    dialogState.value = VoiceDialogState.processing;
    statusMessage.value = 'Processing...';
    transcribedText.value = userText;

    // Add to conversation history
    conversationHistory.add(ConversationTurn.user(userText));

    // Stop current listening session
    _stopCurrentListening();

    // Send to AI (mock mode only)
    _realtimeService.sendMockUserMessage(userText);
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();

    if (dialogState.value == VoiceDialogState.listening &&
        liveTranscription.value.isNotEmpty) {
      isUserSpeaking.value = true;
      _silenceTimer = Timer(_silenceThreshold, () {
        isUserSpeaking.value = false;
        _onUserFinishedSpeaking();
      });
    }
  }

  Future<void> _stopCurrentListening() async {
    _silenceTimer?.cancel();
    _silenceTimer = null;

    if (OpenAIRealtimeService.useMockMode) {
      _audioService.stopMockAmplitudeStream();
      await _speechRecognitionService.stopListening();
    } else {
      await _audioService.stopRecording();
    }
  }

  // ===========================================================================
  // EVENT HANDLING
  // ===========================================================================

  void _handleRealtimeEvent(RealtimeEvent event) {
    // Debug: Log all events with current state
    // ignore: avoid_print
    print('🔔 Controller received event: ${event.type} (state: ${dialogState.value})');

    switch (event.type) {
      case 'session.created':
        statusMessage.value = 'Connected';
        // ignore: avoid_print
        print('✅ Session created, ready to receive audio');
        break;

      case 'session.updated':
        // ignore: avoid_print
        print('✅ Session updated with config');
        break;

      case 'input_audio_buffer.speech_started':
        // ignore: avoid_print
        print('🎤 Speech started detected by API');
        if (dialogState.value == VoiceDialogState.listening) {
          isUserSpeaking.value = true;
          statusMessage.value = 'Listening...';

          if (isAISpeaking.value) {
            _handleInterruption();
          }
        } else {
          // ignore: avoid_print
          print('⚠️ Ignoring speech_started - not in listening state');
        }
        break;

      case 'input_audio_buffer.speech_stopped':
        // ignore: avoid_print
        print('🎤 Speech stopped detected by API');
        if (dialogState.value == VoiceDialogState.listening) {
          isUserSpeaking.value = false;
          _onUserFinishedSpeaking();
        } else {
          // ignore: avoid_print
          print('⚠️ Ignoring speech_stopped - not in listening state');
        }
        break;

      case 'input_audio_buffer.transcription.partial':
        final transcript = event.data['transcript'] as String? ?? '';
        liveTranscription.value = transcript;
        break;

      case 'conversation.item.input_audio_transcription.completed':
        final transcript = event.data['transcript'] as String? ?? '';
        if (transcript.isNotEmpty) {
          transcribedText.value = transcript;
        }
        break;

      case 'response.created':
        // ignore: avoid_print
        print('🤖 Response created by API');
        if (dialogState.value == VoiceDialogState.listening ||
            dialogState.value == VoiceDialogState.processing) {
          dialogState.value = VoiceDialogState.processing;
          statusMessage.value = 'Thinking...';
          aiResponseText.value = '';
        }
        break;

      case 'response.audio_transcript.delta':
        if (dialogState.value == VoiceDialogState.processing ||
            dialogState.value == VoiceDialogState.aiSpeaking) {
          final delta = event.data['delta'] as String? ?? '';
          aiResponseText.value += delta;
          // ignore: avoid_print
          print('📝 AI response delta: $delta');
        }
        break;

      case 'response.audio.delta':
        if (dialogState.value == VoiceDialogState.processing ||
            dialogState.value == VoiceDialogState.aiSpeaking) {
          _currentResponseItemId = event.data['item_id'] as String?;
          isAISpeaking.value = true;
          dialogState.value = VoiceDialogState.aiSpeaking;
          statusMessage.value = 'Speaking...';
          _currentAudioPosition += 100;
        }
        break;

      case 'response.audio.done':
        // ignore: avoid_print
        print('🔊 AI audio done');
        isAISpeaking.value = false;
        break;

      case 'response.done':
        // ignore: avoid_print
        print('✅ Response complete');
        _handleResponseDone();
        break;

      case 'error':
        final errorMsg = event.errorMessage ?? 'Unknown error occurred';
        final errorCode = event.errorCode;
        // ignore: avoid_print
        print('❌ API Error: $errorCode - $errorMsg');

        // Don't break dialog for minor/recoverable errors
        if (errorCode == 'response_cancel_not_active' ||
            errorCode == 'conversation_already_exists') {
          // These are harmless errors, just log them
          // ignore: avoid_print
          print('ℹ️ Ignoring recoverable error: $errorCode');
          return;
        }

        _setError(errorMsg);
        break;
    }
  }

  void _handleResponseDone() {
    // Add AI response to conversation history
    if (aiResponseText.value.isNotEmpty) {
      conversationHistory.add(ConversationTurn.assistant(aiResponseText.value));
    }

    _currentResponseItemId = null;
    _currentAudioPosition = 0;

    // Wait for audio playback to complete before restarting listening
    _waitForPlaybackAndRestartListening();
  }

  /// Waits for audio playback to finish, then restarts listening
  Future<void> _waitForPlaybackAndRestartListening() async {
    // ignore: avoid_print
    print('⏳ Waiting for audio playback to complete...');
    statusMessage.value = 'Speaking...';

    // Wait for audio playback to finish (check every 100ms, max 30 seconds)
    int waitCount = 0;
    const maxWaitCount = 300; // 30 seconds max

    while (_audioService.isPlaying.value && waitCount < maxWaitCount) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitCount++;
    }

    // ignore: avoid_print
    print('✅ Audio playback completed (waited ${waitCount * 100}ms)');

    isAISpeaking.value = false;

    // Auto-restart listening after AI finishes (continuous mode)
    if (!isPaused.value) {
      // Small delay after audio finishes for a natural pause
      await Future.delayed(const Duration(milliseconds: 300));
      _startContinuousListening();
    } else {
      dialogState.value = VoiceDialogState.listening;
      statusMessage.value = 'Paused - Tap to resume';
    }
  }

  void _handleAudioOutput(dynamic audioData) {
    if (audioData is List<int>) {
      _audioService.addToPlaybackBuffer(
        audioData is Uint8List ? audioData : Uint8List.fromList(audioData),
      );
    }
  }

  void _handleInterruption() {
    _audioService.stopPlayback();
    _realtimeService.cancelResponse();

    if (_currentResponseItemId != null) {
      _realtimeService.truncateResponse(
        _currentResponseItemId!,
        0,
        _currentAudioPosition,
      );
    }

    isAISpeaking.value = false;
    _currentResponseItemId = null;
    _currentAudioPosition = 0;

    // Add partial response to history
    if (aiResponseText.value.isNotEmpty) {
      conversationHistory.add(ConversationTurn.assistant('${aiResponseText.value}...'));
      aiResponseText.value = '';
    }
  }

  // ===========================================================================
  // PUBLIC ACTIONS
  // ===========================================================================

  /// Toggles pause/resume of continuous listening
  Future<void> togglePause() async {
    isPaused.value = !isPaused.value;

    if (isPaused.value) {
      statusMessage.value = 'Paused - Tap to resume';
      await _stopCurrentListening();
      _realtimeService.cancelResponse();
      _audioService.stopPlayback();
    } else {
      await _startContinuousListening();
    }
  }

  /// Cancels and returns to ready state
  Future<void> cancelConversation() async {
    await _stopCurrentListening();
    await _audioService.stopPlayback();
    _realtimeService.cancelResponse();
    _realtimeService.clearAudioBuffer();

    isUserSpeaking.value = false;
    isAISpeaking.value = false;
    liveTranscription.value = '';
    aiResponseText.value = '';
    audioLevel.value = 0.0;

    if (!isPaused.value) {
      await _startContinuousListening();
    }
  }

  /// Closes the voice dialog
  void closeDialog() {
    Get.back();
  }

  /// Retries after an error
  Future<void> retry() async {
    hasError.value = false;
    errorMessage.value = '';
    await _initialize();
  }

  /// Gets the amplitude stream for waveform
  Stream<dynamic>? get amplitudeStream => _audioService.amplitudeStream;

  // ===========================================================================
  // ERROR HANDLING
  // ===========================================================================

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    dialogState.value = VoiceDialogState.error;
    statusMessage.value = message;
    // ignore: avoid_print
    print('Voice dialog error: $message');
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';

    if (_isInitialized && !isPaused.value) {
      _startContinuousListening();
    }
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  @override
  void onClose() {
    _silenceTimer?.cancel();
    _eventSubscription?.cancel();
    _audioOutputSubscription?.cancel();
    _recordingLevelSubscription?.cancel();
    _speechTranscriptionSubscription?.cancel();
    _speechFinalSubscription?.cancel();
    _speechStatusSubscription?.cancel();

    _realtimeService.disconnect();
    _audioService.dispose();
    _speechRecognitionService.dispose();

    super.onClose();
  }
}

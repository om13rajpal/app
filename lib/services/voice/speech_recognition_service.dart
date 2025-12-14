/// Speech Recognition Service for Live Transcription
///
/// This service uses the device's native speech recognition to transcribe
/// the user's speech in real-time. It provides live partial transcripts
/// as the user speaks, giving immediate feedback.
///
/// Features:
/// - Real-time speech-to-text transcription
/// - Partial results for live feedback
/// - Final results when speech ends
/// - Error handling and status callbacks
library;

import 'dart:async';

import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Service for real-time speech recognition using device's native capabilities.
class SpeechRecognitionService extends GetxService {
  // ===========================================================================
  // PRIVATE PROPERTIES
  // ===========================================================================

  /// Speech to text instance
  final SpeechToText _speechToText = SpeechToText();

  /// Stream controller for transcription updates
  StreamController<String>? _transcriptionController;

  /// Stream controller for final transcription
  StreamController<String>? _finalTranscriptionController;

  /// Stream controller for status updates
  StreamController<SpeechStatus>? _statusController;

  // ===========================================================================
  // REACTIVE PROPERTIES
  // ===========================================================================

  /// Whether speech recognition is available on this device
  final RxBool isAvailable = false.obs;

  /// Whether speech recognition is currently listening
  final RxBool isListening = false.obs;

  /// Current partial transcription
  final RxString currentTranscription = ''.obs;

  /// Full accumulated transcription (all sentences)
  final RxString fullTranscription = ''.obs;

  /// Last error message
  final RxString lastError = ''.obs;

  /// Locale to use for recognition
  String? _currentLocale;

  // ===========================================================================
  // STREAMS
  // ===========================================================================

  /// Stream of partial transcription updates (live as user speaks)
  Stream<String>? get transcriptionStream => _transcriptionController?.stream;

  /// Stream of final transcription (when user stops speaking)
  Stream<String>? get finalTranscriptionStream =>
      _finalTranscriptionController?.stream;

  /// Stream of status updates
  Stream<SpeechStatus>? get statusStream => _statusController?.stream;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initializes the speech recognition service.
  ///
  /// Returns true if speech recognition is available on this device.
  Future<bool> initialize() async {
    try {
      // ignore: avoid_print
      print('Initializing speech recognition...');

      isAvailable.value = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: true,
        // Longer timeout for final results - improves accuracy
        finalTimeout: const Duration(seconds: 3),
      );

      // ignore: avoid_print
      print('Speech recognition available: ${isAvailable.value}');

      if (isAvailable.value) {
        // Create stream controllers
        _transcriptionController = StreamController<String>.broadcast();
        _finalTranscriptionController = StreamController<String>.broadcast();
        _statusController = StreamController<SpeechStatus>.broadcast();

        // Check available locales
        final locales = await _speechToText.locales();
        // ignore: avoid_print
        print('Available locales: ${locales.map((l) => l.localeId).toList()}');
      } else {
        // ignore: avoid_print
        print('Speech recognition NOT available on this device');
      }

      return isAvailable.value;
    } catch (e) {
      // ignore: avoid_print
      print('Speech recognition initialization error: $e');
      lastError.value = e.toString();
      return false;
    }
  }

  // ===========================================================================
  // LISTENING
  // ===========================================================================

  /// Starts listening to the user's speech.
  ///
  /// Uses a single long listening session without restarts to avoid
  /// annoying system sounds. User must tap to stop.
  ///
  /// [localeId] - Optional locale for speech recognition (e.g., 'en_US')
  ///
  /// Returns true if listening started successfully.
  Future<bool> startListening({
    String? localeId,
  }) async {
    if (!isAvailable.value) {
      lastError.value = 'Speech recognition not available';
      return false;
    }

    if (isListening.value) {
      return true; // Already listening
    }

    _currentLocale = localeId;

    // Clear previous transcriptions
    currentTranscription.value = '';
    fullTranscription.value = '';

    try {
      await _speechToText.listen(
        onResult: _handleResult,
        // Very long duration - user controls when to stop
        listenFor: const Duration(minutes: 5),
        // Very long pause tolerance - don't stop on pauses
        pauseFor: const Duration(minutes: 2),
        localeId: _currentLocale,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
          // Disable haptic feedback to reduce interruptions
          enableHapticFeedback: false,
        ),
      );

      // ignore: avoid_print
      print('Speech recognition started');

      isListening.value = true;
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error starting speech recognition: $e');
      lastError.value = e.toString();
      return false;
    }
  }

  /// Stops listening to the user's speech.
  Future<void> stopListening() async {
    if (!isListening.value && !_speechToText.isListening) {
      return; // Already stopped
    }

    try {
      // Cancel first to immediately release resources, then stop
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
      await _speechToText.stop();
      isListening.value = false;

      // Emit final transcription if we have any
      final finalText = fullTranscription.value.isNotEmpty
          ? fullTranscription.value
          : currentTranscription.value;
      if (finalText.isNotEmpty) {
        _finalTranscriptionController?.add(finalText);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error stopping speech recognition: $e');
    } finally {
      isListening.value = false;
    }
  }

  /// Cancels listening without emitting final transcription.
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      isListening.value = false;
      currentTranscription.value = '';
      fullTranscription.value = '';
    } catch (e) {
      // ignore: avoid_print
      print('Error canceling speech recognition: $e');
    }
  }

  // ===========================================================================
  // HANDLERS
  // ===========================================================================

  /// Handles speech recognition results.
  void _handleResult(SpeechRecognitionResult result) {
    currentTranscription.value = result.recognizedWords;

    // Build full transcription display (accumulated + current)
    final displayText = fullTranscription.value.isEmpty
        ? result.recognizedWords
        : '${fullTranscription.value} ${result.recognizedWords}';

    _transcriptionController?.add(displayText);

    // When we get a final result, accumulate it
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      if (fullTranscription.value.isEmpty) {
        fullTranscription.value = result.recognizedWords;
      } else {
        fullTranscription.value = '${fullTranscription.value} ${result.recognizedWords}';
      }
      // ignore: avoid_print
      print('Accumulated transcription: ${fullTranscription.value}');
    }
  }

  /// Handles speech recognition errors.
  void _handleError(dynamic error) {
    // ignore: avoid_print
    print('Speech recognition error: $error');
    lastError.value = error.toString();
    _statusController?.add(SpeechStatus.error);

    // Don't restart - user controls when to stop/restart
    isListening.value = false;
  }

  /// Handles speech recognition status changes.
  void _handleStatus(String status) {
    // ignore: avoid_print
    print('Speech recognition status: $status');

    switch (status) {
      case 'listening':
        isListening.value = true;
        _statusController?.add(SpeechStatus.listening);
        break;
      case 'notListening':
      case 'done':
        // Don't auto-restart - user controls the session
        // Only update state if not already stopped by user
        isListening.value = false;
        _statusController?.add(
          status == 'done' ? SpeechStatus.done : SpeechStatus.notListening,
        );
        break;
      default:
        _statusController?.add(SpeechStatus.unknown);
    }
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Gets available locales for speech recognition.
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!isAvailable.value) {
      return [];
    }
    return await _speechToText.locales();
  }

  /// Checks if speech recognition is currently available.
  bool get isReady => isAvailable.value && !isListening.value;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  /// Disposes of all resources.
  Future<void> dispose() async {
    // Cancel any ongoing recognition first
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
      // Stop the speech recognizer to release native resources
      await _speechToText.stop();
    } catch (e) {
      // ignore: avoid_print
      print('Error stopping speech recognizer: $e');
    }

    isListening.value = false;
    isAvailable.value = false;

    await _transcriptionController?.close();
    _transcriptionController = null;

    await _finalTranscriptionController?.close();
    _finalTranscriptionController = null;

    await _statusController?.close();
    _statusController = null;
  }

  @override
  Future<void> onClose() async {
    await dispose();
    super.onClose();
  }
}

/// Status of speech recognition.
enum SpeechStatus {
  listening,
  notListening,
  done,
  error,
  unknown,
}

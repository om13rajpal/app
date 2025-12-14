/// Audio Stream Service for Voice Conversations
///
/// This service manages real-time audio recording and playback using
/// the flutter_sound package. It's optimized for low-latency voice
/// conversations with OpenAI's Real-Time API.
///
/// Audio Format Requirements (OpenAI Real-Time API):
/// - Sample Rate: 24,000 Hz
/// - Bit Depth: 16-bit (PCM)
/// - Channels: Mono (1 channel)
///
/// Features:
/// - Real-time microphone streaming
/// - Buffered audio playback
/// - Audio level monitoring (for waveform visualization)
/// - Audio session management (handles interruptions)
/// - Permission handling
///
/// Usage:
/// ```dart
/// final audioService = AudioStreamService();
/// await audioService.initialize();
///
/// // Start recording
/// await audioService.startRecording(
///   onAudioChunk: (chunk) => sendToApi(chunk),
/// );
///
/// // Play AI response
/// audioService.addToPlaybackBuffer(audioData);
/// ```
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

/// Service for managing audio recording and playback.
///
/// This is a GetX service that handles all audio I/O for voice conversations.
/// It uses flutter_sound for native audio access and audio_session for
/// proper audio focus management.
class AudioStreamService extends GetxService {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  /// Sample rate required by OpenAI Real-Time API (24 kHz)
  static const int sampleRate = 24000;

  /// Number of audio channels (mono)
  static const int numChannels = 1;

  /// Bit depth for PCM audio (16-bit)
  static const int bitDepth = 16;

  /// Duration of each audio chunk in milliseconds
  /// Smaller = lower latency, but more overhead
  /// Larger = higher latency, but more efficient
  static const int chunkDurationMs = 100;

  /// Minimum buffer size before starting playback (milliseconds)
  /// Helps prevent audio stuttering
  static const int playbackBufferMs = 50;

  // ===========================================================================
  // PRIVATE PROPERTIES
  // ===========================================================================

  /// Flutter Sound recorder instance
  FlutterSoundRecorder? _recorder;

  /// Flutter Sound player instance
  FlutterSoundPlayer? _player;

  /// Stream controller for recording output
  StreamController<Uint8List>? _recordingController;

  /// Subscription to recording stream
  StreamSubscription? _recordingSubscription;

  /// Subscription to recorder progress (for audio levels)
  StreamSubscription? _progressSubscription;

  /// Buffer for audio playback
  final List<Uint8List> _playbackBuffer = [];

  /// Whether playback is currently active
  bool _isPlaybackActive = false;

  /// Total bytes of audio fed to player (for estimating playback duration)
  int _totalBytesFed = 0;

  /// Timestamp when feeding started
  DateTime? _feedStartTime;

  /// Audio session instance
  AudioSession? _audioSession;

  /// Stream controller for amplitude values (for waveform visualization)
  StreamController<Amplitude>? _amplitudeController;

  /// Random generator for mock amplitude simulation
  final Random _random = Random();

  // ===========================================================================
  // REACTIVE PROPERTIES
  // ===========================================================================

  /// Whether the recorder is currently recording
  final RxBool isRecording = false.obs;

  /// Whether the player is currently playing
  final RxBool isPlaying = false.obs;

  /// Current recording level (0.0 to 1.0) for waveform visualization
  final RxDouble recordingLevel = 0.0.obs;

  /// Whether the audio service is initialized
  final RxBool isInitialized = false.obs;

  /// Stream of recorded audio chunks
  Stream<Uint8List>? get recordingStream => _recordingController?.stream;

  /// Stream of amplitude values for waveform visualization
  Stream<Amplitude>? get amplitudeStream => _amplitudeController?.stream;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initializes the audio service.
  ///
  /// This method:
  /// 1. Configures the audio session for voice chat
  /// 2. Initializes the recorder and player
  /// 3. Sets up audio focus handling
  ///
  /// Must be called before any recording or playback operations.
  ///
  /// Returns true if initialization was successful.
  ///
  /// Example:
  /// ```dart
  /// final audioService = AudioStreamService();
  /// final success = await audioService.initialize();
  /// if (!success) {
  ///   // Handle initialization failure
  /// }
  /// ```
  Future<bool> initialize() async {
    if (isInitialized.value) {
      return true;
    }

    try {
      // Configure audio session for voice communication
      await _configureAudioSession();

      // Initialize recorder
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();

      // Set subscription duration for progress updates (audio level monitoring)
      await _recorder!.setSubscriptionDuration(
        const Duration(milliseconds: 50),
      );

      // Initialize player
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();

      isInitialized.value = true;
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Audio service initialization error: $e');
      return false;
    }
  }

  /// Configures the audio session for optimal voice chat performance.
  ///
  /// This ensures:
  /// - Audio plays through the speaker (not earpiece on phones)
  /// - Bluetooth devices work correctly
  /// - Other apps' audio is handled properly
  /// - Audio continues when screen locks (if needed)
  Future<void> _configureAudioSession() async {
    _audioSession = await AudioSession.instance;

    await _audioSession!.configure(
      AudioSessionConfiguration.speech(),
    );

    // Handle audio interruptions (phone calls, other apps)
    _audioSession!.interruptionEventStream.listen((event) {
      if (event.begin) {
        // Audio interrupted - pause if necessary
        if (isRecording.value) {
          stopRecording();
        }
        if (isPlaying.value) {
          stopPlayback();
        }
      }
    });
  }

  // ===========================================================================
  // RECORDING
  // ===========================================================================

  /// Starts recording audio from the microphone.
  ///
  /// Audio is streamed in chunks through the [onAudioChunk] callback.
  /// Each chunk contains PCM 16-bit audio at 24kHz.
  ///
  /// [onAudioChunk] - Callback called with each audio chunk
  ///
  /// Returns true if recording started successfully.
  ///
  /// Example:
  /// ```dart
  /// await audioService.startRecording(
  ///   onAudioChunk: (chunk) {
  ///     // Send chunk to WebSocket
  ///     realtimeService.sendAudioChunk(chunk);
  ///   },
  /// );
  /// ```
  Future<bool> startRecording({
    required Function(Uint8List) onAudioChunk,
  }) async {
    if (isRecording.value) {
      return false;
    }

    // Check microphone permission
    final permissionGranted = await _requestMicrophonePermission();
    if (!permissionGranted) {
      // ignore: avoid_print
      print('Microphone permission denied');
      return false;
    }

    try {
      // ignore: avoid_print
      print('🎤 AudioService: Creating stream controller...');

      // Create stream controller for audio chunks
      _recordingController = StreamController<Uint8List>.broadcast();

      // Track chunk count for debugging
      int chunkCount = 0;

      // Set up listener for audio chunks
      _recordingSubscription = _recordingController!.stream.listen((chunk) {
        chunkCount++;
        if (chunkCount % 10 == 0) {
          // ignore: avoid_print
          print('🎤 AudioService: Chunk #$chunkCount (${chunk.length} bytes)');
        }
        onAudioChunk(chunk);
      });

      // ignore: avoid_print
      print('🎤 AudioService: Starting recorder with sampleRate=$sampleRate, codec=pcm16...');

      // Start recording to stream
      await _recorder!.startRecorder(
        toStream: _recordingController!.sink,
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: numChannels,
      );

      // ignore: avoid_print
      print('🎤 AudioService: Recorder started successfully');

      // Monitor recording progress for audio levels
      _setupAudioLevelMonitoring();

      isRecording.value = true;
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ AudioService: Error starting recording: $e');
      await _cleanupRecording();
      return false;
    }
  }

  /// Sets up audio level monitoring for waveform visualization.
  ///
  /// Updates [recordingLevel] with normalized values (0.0 to 1.0)
  /// and emits [Amplitude] values to the amplitude stream.
  void _setupAudioLevelMonitoring() {
    // Create amplitude stream controller
    _amplitudeController = StreamController<Amplitude>.broadcast();

    _progressSubscription = _recorder!.onProgress!.listen((event) {
      if (event.decibels != null) {
        // Convert decibels to a 0-1 range
        // Typical speech is around -20 to -40 dB, silence is around -60 dB
        // Normalize: (dB + 60) / 60, clamped to 0-1
        final normalized = ((event.decibels! + 60) / 60).clamp(0.0, 1.0);
        recordingLevel.value = normalized;

        // Emit amplitude to stream for waveform visualization
        _amplitudeController?.add(Amplitude(
          current: normalized,
          max: 1.0,
        ));
      }
    });
  }

  /// Starts emitting mock amplitude values for testing.
  ///
  /// Used when testing the UI without actual audio recording.
  Timer? _mockAmplitudeTimer;

  void startMockAmplitudeStream() {
    _amplitudeController = StreamController<Amplitude>.broadcast();

    _mockAmplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        // Generate random amplitude for testing
        final amplitude = 0.3 + _random.nextDouble() * 0.7;
        _amplitudeController?.add(Amplitude(
          current: amplitude,
          max: 1.0,
        ));
        recordingLevel.value = amplitude;
      },
    );
  }

  void stopMockAmplitudeStream() {
    _mockAmplitudeTimer?.cancel();
    _mockAmplitudeTimer = null;
    _amplitudeController?.close();
    _amplitudeController = null;
    recordingLevel.value = 0.0;
  }

  /// Stops the current recording.
  ///
  /// Cleans up all recording resources and resets state.
  Future<void> stopRecording() async {
    if (!isRecording.value) {
      return;
    }

    try {
      await _recorder?.stopRecorder();
    } catch (e) {
      // ignore: avoid_print
      print('Error stopping recorder: $e');
    }

    await _cleanupRecording();
  }

  /// Cleans up recording resources.
  Future<void> _cleanupRecording() async {
    await _progressSubscription?.cancel();
    _progressSubscription = null;

    await _recordingSubscription?.cancel();
    _recordingSubscription = null;

    await _recordingController?.close();
    _recordingController = null;

    // Clean up amplitude stream
    _mockAmplitudeTimer?.cancel();
    _mockAmplitudeTimer = null;
    await _amplitudeController?.close();
    _amplitudeController = null;

    isRecording.value = false;
    recordingLevel.value = 0.0;
  }

  /// Requests microphone permission from the user.
  ///
  /// Returns true if permission is granted.
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // ===========================================================================
  // PLAYBACK
  // ===========================================================================

  /// Adds an audio chunk to the playback buffer.
  ///
  /// Audio chunks are buffered and played sequentially to ensure
  /// smooth playback even with network jitter.
  ///
  /// [audioData] - PCM 16-bit audio data at 24kHz
  ///
  /// Example:
  /// ```dart
  /// realtimeService.audioOutputStream.listen((chunk) {
  ///   audioService.addToPlaybackBuffer(chunk);
  /// });
  /// ```
  void addToPlaybackBuffer(Uint8List audioData) {
    _playbackBuffer.add(audioData);

    // Start playback if not already playing and buffer has enough data
    if (!_isPlaybackActive && _hasEnoughBuffer()) {
      _startBufferedPlayback();
    }
  }

  /// Checks if the buffer has enough audio to start playback.
  bool _hasEnoughBuffer() {
    // Calculate total buffer duration
    int totalBytes = 0;
    for (final chunk in _playbackBuffer) {
      totalBytes += chunk.length;
    }

    // 48 bytes per millisecond (24000 samples/sec * 2 bytes/sample / 1000)
    final bufferDurationMs = totalBytes / 48;
    return bufferDurationMs >= playbackBufferMs;
  }

  /// Starts playing buffered audio.
  ///
  /// This method manages the playback loop, feeding audio chunks
  /// to the player as they become available.
  Future<void> _startBufferedPlayback() async {
    if (_isPlaybackActive || _playbackBuffer.isEmpty) {
      return;
    }

    _isPlaybackActive = true;
    isPlaying.value = true;
    _totalBytesFed = 0;
    _feedStartTime = DateTime.now();

    try {
      // Start player in streaming mode
      // Buffer size: 4096 bytes is a good balance between latency and smoothness
      await _player!.startPlayerFromStream(
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: numChannels,
        interleaved: true,
        bufferSize: 4096,
      );

      // Feed audio chunks to the player
      while (_playbackBuffer.isNotEmpty && _isPlaybackActive) {
        final chunk = _playbackBuffer.removeAt(0);
        _totalBytesFed += chunk.length;

        try {
          // Use the non-deprecated method for feeding audio
          await _player!.feedUint8FromStream(chunk);
        } catch (e) {
          // Player might be closed, stop playback
          break;
        }

        // Small delay to prevent overwhelming the audio system
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Wait for remaining audio in player's internal buffer to finish
      // Calculate expected playback duration from bytes fed
      // 48 bytes per ms (24000 samples/sec * 2 bytes/sample / 1000)
      if (_totalBytesFed > 0 && _feedStartTime != null) {
        final expectedDurationMs = _totalBytesFed / 48;
        final elapsedMs = DateTime.now().difference(_feedStartTime!).inMilliseconds;
        final remainingMs = (expectedDurationMs - elapsedMs).toInt();

        if (remainingMs > 0) {
          // ignore: avoid_print
          print('🔊 Waiting ${remainingMs}ms for audio playback to complete...');
          await Future.delayed(Duration(milliseconds: remainingMs + 100)); // +100ms buffer
        }
      }

      // Stop player when done
      if (_player!.isPlaying) {
        await _player!.stopPlayer();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Playback error: $e');
    }

    _isPlaybackActive = false;
    isPlaying.value = false;
    _totalBytesFed = 0;
    _feedStartTime = null;
    // ignore: avoid_print
    print('🔊 Audio playback finished, isPlaying = false');
  }

  /// Clears the playback buffer.
  ///
  /// Use this when the user interrupts the AI (barge-in) to immediately
  /// stop audio playback and discard remaining audio.
  void clearPlaybackBuffer() {
    _playbackBuffer.clear();
  }

  /// Stops audio playback immediately.
  ///
  /// This clears the buffer and stops the player.
  /// Use for interruption handling.
  Future<void> stopPlayback() async {
    _isPlaybackActive = false;
    _playbackBuffer.clear();
    _totalBytesFed = 0;
    _feedStartTime = null;

    try {
      if (_player?.isPlaying ?? false) {
        await _player?.stopPlayer();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error stopping playback: $e');
    }

    isPlaying.value = false;
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Gets the current playback buffer duration in milliseconds.
  ///
  /// Useful for monitoring buffer status and debugging.
  int get playbackBufferDurationMs {
    int totalBytes = 0;
    for (final chunk in _playbackBuffer) {
      totalBytes += chunk.length;
    }
    return (totalBytes / 48).round();
  }

  /// Checks if the audio service is ready for use.
  bool get isReady => isInitialized.value;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  /// Disposes of all audio resources.
  ///
  /// Call this when the voice dialog is closed.
  Future<void> dispose() async {
    await stopRecording();
    await stopPlayback();

    try {
      await _recorder?.closeRecorder();
    } catch (e) {
      // ignore: avoid_print
      print('Error closing recorder: $e');
    }

    try {
      await _player?.closePlayer();
    } catch (e) {
      // ignore: avoid_print
      print('Error closing player: $e');
    }

    _recorder = null;
    _player = null;
    isInitialized.value = false;
  }

  /// Called when the service is closed (GetX lifecycle).
  @override
  void onClose() {
    dispose();
    super.onClose();
  }
}

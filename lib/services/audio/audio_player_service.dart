/// Audio Player Service for AiSeaSafe
///
/// This service handles playback of TTS audio from base64-encoded data
/// received from the maritime-chat API responses.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

// =============================================================================
// AUDIO PLAYER SERVICE
// =============================================================================

/// Service for playing TTS audio from base64-encoded data
class AudioPlayerService extends GetxService {
  // ===========================================================================
  // PROPERTIES
  // ===========================================================================

  FlutterSoundPlayer? _player;

  /// Whether the player is currently playing
  final RxBool isPlaying = false.obs;

  /// Whether the player is initialized
  final RxBool isInitialized = false.obs;

  /// Current playback progress (0.0 to 1.0)
  final RxDouble progress = 0.0.obs;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      isInitialized.value = true;
      print('AudioPlayerService initialized');
    } catch (e) {
      print('Failed to initialize AudioPlayerService: $e');
      isInitialized.value = false;
    }
  }

  @override
  void onClose() {
    _player?.closePlayer();
    super.onClose();
  }

  // ===========================================================================
  // PLAYBACK METHODS
  // ===========================================================================

  /// Play audio from base64-encoded data
  ///
  /// [audioBase64] - Base64-encoded audio data
  /// [format] - Audio format (mp3, opus, aac, flac, wav, pcm)
  Future<void> playFromBase64(String audioBase64, {String format = 'mp3'}) async {
    if (!isInitialized.value || _player == null) {
      print('AudioPlayerService not initialized');
      return;
    }

    try {
      // Stop any current playback
      await stop();

      // Decode base64 to bytes
      final Uint8List audioBytes = base64Decode(audioBase64);

      // Get codec from format
      final codec = _getCodecFromFormat(format);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/tts_audio.$format');
      await tempFile.writeAsBytes(audioBytes);

      // Play from file
      isPlaying.value = true;

      await _player!.startPlayer(
        fromURI: tempFile.path,
        codec: codec,
        whenFinished: () {
          isPlaying.value = false;
          progress.value = 0.0;
          // Clean up temp file
          tempFile.deleteSync();
        },
      );

      print('Playing TTS audio: ${audioBytes.length} bytes, format: $format');
    } catch (e) {
      print('Error playing audio: $e');
      isPlaying.value = false;
    }
  }

  /// Play audio from bytes
  Future<void> playFromBytes(Uint8List audioBytes, {String format = 'mp3'}) async {
    if (!isInitialized.value || _player == null) {
      print('AudioPlayerService not initialized');
      return;
    }

    try {
      await stop();

      final codec = _getCodecFromFormat(format);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/tts_audio.$format');
      await tempFile.writeAsBytes(audioBytes);

      isPlaying.value = true;

      await _player!.startPlayer(
        fromURI: tempFile.path,
        codec: codec,
        whenFinished: () {
          isPlaying.value = false;
          progress.value = 0.0;
          tempFile.deleteSync();
        },
      );
    } catch (e) {
      print('Error playing audio: $e');
      isPlaying.value = false;
    }
  }

  /// Stop playback
  Future<void> stop() async {
    if (_player != null && isPlaying.value) {
      await _player!.stopPlayer();
      isPlaying.value = false;
      progress.value = 0.0;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (_player != null && isPlaying.value) {
      await _player!.pausePlayer();
      isPlaying.value = false;
    }
  }

  /// Resume playback
  Future<void> resume() async {
    if (_player != null && !isPlaying.value) {
      await _player!.resumePlayer();
      isPlaying.value = true;
    }
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  Codec _getCodecFromFormat(String format) {
    switch (format.toLowerCase()) {
      case 'mp3':
        return Codec.mp3;
      case 'opus':
        return Codec.opusOGG;
      case 'aac':
        return Codec.aacADTS;
      case 'flac':
        return Codec.flac;
      case 'wav':
        return Codec.pcm16WAV;
      case 'pcm':
        return Codec.pcm16;
      default:
        return Codec.mp3;
    }
  }
}

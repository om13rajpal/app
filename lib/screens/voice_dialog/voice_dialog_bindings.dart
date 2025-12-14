/// Voice Dialog Bindings
///
/// This file contains the GetX bindings for the voice dialog screen.
/// Bindings are responsible for lazy-loading and registering dependencies
/// when the route is accessed.
///
/// The bindings pattern ensures:
/// - Services are only instantiated when needed
/// - Proper dependency injection for testing
/// - Clean separation of concerns
///
/// Usage:
/// ```dart
/// // In app_pages.dart
/// GetPage(
///   name: Routes.voiceDialog,
///   page: () => const VoiceDialogView(),
///   binding: VoiceDialogBindings(),
/// ),
/// ```
library;

import 'package:get/get.dart';

import '../../services/voice/audio_stream_service.dart';
import '../../services/voice/openai_realtime_service.dart';
import '../../services/voice/voice_conversation_controller.dart';

/// Bindings for the voice dialog screen.
///
/// Registers all necessary services and controllers for the voice
/// conversation feature.
class VoiceDialogBindings extends Bindings {
  /// Registers dependencies for the voice dialog.
  ///
  /// This method is called automatically when navigating to the
  /// voice dialog route. It ensures all required services are
  /// available for injection.
  @override
  void dependencies() {
    // Register OpenAI Real-Time Service
    // Using Get.lazyPut to defer instantiation until first use
    if (!Get.isRegistered<OpenAIRealtimeService>()) {
      Get.lazyPut<OpenAIRealtimeService>(
        () => OpenAIRealtimeService(),
        fenix: true, // Recreate if disposed
      );
    }

    // Register Audio Stream Service
    if (!Get.isRegistered<AudioStreamService>()) {
      Get.lazyPut<AudioStreamService>(
        () => AudioStreamService(),
        fenix: true,
      );
    }

    // Register Voice Conversation Controller
    // This is the main controller for the voice dialog
    Get.lazyPut<VoiceConversationController>(
      () => VoiceConversationController(),
    );
  }
}

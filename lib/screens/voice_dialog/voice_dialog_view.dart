/// Voice Dialog View - Continuous Listening Mode
///
/// A hands-free voice assistant UI with real-time transcription,
/// streaming AI responses, and conversation history.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../services/voice/realtime_events.dart';
import '../../services/voice/voice_conversation_controller.dart';
import '../../utils/constants/color_constant.dart';
import '../../widgets/theme_text.dart';

/// Main voice dialog widget with continuous listening.
class VoiceDialogView extends StatelessWidget {
  final bool showSkipButton;

  const VoiceDialogView({
    super.key,
    this.showSkipButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceConversationController>(
      init: VoiceConversationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConst.color07141F,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(controller),
                Expanded(
                  child: Obx(() => _buildConversationArea(controller)),
                ),
                Obx(() => _buildBottomBar(controller)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(VoiceConversationController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        border: Border(
          bottom: BorderSide(
            color: ColorConst.color28333D,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.sp,
            height: 40.sp,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorConst.color5AD1D3, ColorConst.color00FBFF],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sailing_outlined,
              color: ColorConst.color07141F,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeText(
                  text: 'Maritime Assistant',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 2.h),
                Obx(() => Row(
                  children: [
                    _buildStatusDot(controller),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: ThemeText(
                        text: controller.statusMessage.value,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        textColor: ColorConst.colorDCDCDC80,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          if (showSkipButton)
            GestureDetector(
              onTap: controller.closeDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorConst.color28333D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ThemeText(
                  text: 'Skip',
                  fontSize: 12,
                  textColor: ColorConst.colorDCDCDC80,
                ),
              ),
            ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.closeDialog,
            child: Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: ColorConst.color07141F,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                color: ColorConst.colorDCDCDC80,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(VoiceConversationController controller) {
    Color dotColor;
    bool shouldPulse = false;

    switch (controller.dialogState.value) {
      case VoiceDialogState.initializing:
        dotColor = ColorConst.colorDCDCDC60;
        break;
      case VoiceDialogState.listening:
        dotColor = controller.isUserSpeaking.value
            ? ColorConst.color45FF01
            : ColorConst.color5AD1D3;
        shouldPulse = true;
        break;
      case VoiceDialogState.processing:
        dotColor = ColorConst.colorA56DFF;
        shouldPulse = true;
        break;
      case VoiceDialogState.aiSpeaking:
        dotColor = ColorConst.color00FBFF;
        shouldPulse = true;
        break;
      case VoiceDialogState.error:
        dotColor = ColorConst.colorE8271B;
        break;
    }

    if (controller.isPaused.value) {
      dotColor = ColorConst.colorDCDCDC60;
      shouldPulse = false;
    }

    return _PulsingDot(color: dotColor, shouldPulse: shouldPulse);
  }

  Widget _buildConversationArea(VoiceConversationController controller) {
    final state = controller.dialogState.value;

    if (state == VoiceDialogState.initializing) {
      return _buildInitializingState();
    }

    if (state == VoiceDialogState.error) {
      return _buildErrorState(controller);
    }

    return Column(
      children: [
        Expanded(
          child: _buildConversationList(controller),
        ),
        _buildCurrentInteraction(controller),
      ],
    );
  }

  Widget _buildInitializingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48.sp,
            height: 48.sp,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: ColorConst.color5AD1D3,
            ),
          ),
          SizedBox(height: 16.h),
          ThemeText(
            text: 'Setting up voice assistant...',
            fontSize: 14,
            textColor: ColorConst.colorDCDCDC80,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VoiceConversationController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: ColorConst.colorE8271B,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            ThemeText(
              text: controller.errorMessage.value,
              fontSize: 14,
              textColor: ColorConst.colorE8271B,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: controller.retry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: ColorConst.colorE8271B,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ThemeText(
                  text: 'Retry',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textColor: ColorConst.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList(VoiceConversationController controller) {
    if (controller.conversationHistory.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      reverse: true,
      itemCount: controller.conversationHistory.length,
      itemBuilder: (context, index) {
        final reversedIndex = controller.conversationHistory.length - 1 - index;
        final turn = controller.conversationHistory[reversedIndex];
        return _buildChatBubble(turn);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100.sp,
              height: 100.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorConst.color5AD1D3.withOpacity(0.15),
                    ColorConst.color00FBFF.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorConst.color5AD1D3.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.sailing_outlined,
                color: ColorConst.color5AD1D3,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 32.h),
            ThemeText(
              text: 'Your Maritime Assistant',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ThemeText(
              text: 'Start speaking to get help with weather forecasts, route planning, and safety information.',
              fontSize: 15,
              textColor: ColorConst.colorDCDCDC80,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _buildHintChip('Weather'),
                _buildHintChip('Routes'),
                _buildHintChip('Safety'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorConst.color5AD1D3.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorConst.color5AD1D3.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: ThemeText(
        text: text,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        textColor: ColorConst.color5AD1D3,
      ),
    );
  }

  Widget _buildChatBubble(ConversationTurn turn) {
    final isUser = turn.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28.sp,
              height: 28.sp,
              decoration: BoxDecoration(
                color: ColorConst.color5AD1D3.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sailing_outlined,
                color: ColorConst.color5AD1D3,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isUser ? ColorConst.color5AD1D3.withOpacity(0.15) : ColorConst.color091B2C,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser ? ColorConst.color5AD1D3.withOpacity(0.3) : ColorConst.color28333D,
                  width: 1,
                ),
              ),
              child: ThemeText(
                text: turn.content,
                fontSize: 14,
                textColor: ColorConst.colorDCDCDC,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          if (isUser) SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildCurrentInteraction(VoiceConversationController controller) {
    final state = controller.dialogState.value;
    final hasLiveText = controller.liveTranscription.value.isNotEmpty;
    final hasAiResponse = controller.aiResponseText.value.isNotEmpty;

    if (controller.isPaused.value) {
      return const SizedBox.shrink();
    }

    if (state == VoiceDialogState.listening && hasLiveText) {
      return _buildLiveTranscriptionCard(controller);
    }

    if ((state == VoiceDialogState.processing || state == VoiceDialogState.aiSpeaking) &&
        (hasAiResponse || state == VoiceDialogState.processing)) {
      return _buildAiResponseCard(controller);
    }

    if (state == VoiceDialogState.listening) {
      return _buildListeningIndicator(controller);
    }

    return const SizedBox.shrink();
  }

  Widget _buildListeningIndicator(VoiceConversationController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 28.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConst.color091B2C,
            ColorConst.color091B2C.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorConst.color5AD1D3.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConst.color5AD1D3.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80.h,
            child: _AudioWaveform(audioLevel: controller.audioLevel),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingDot(color: ColorConst.color5AD1D3, shouldPulse: true),
              SizedBox(width: 10.w),
              ThemeText(
                text: 'Listening...',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: ColorConst.colorDCDCDC80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTranscriptionCard(VoiceConversationController controller) {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: ColorConst.color5AD1D3.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConst.color5AD1D3.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _PulsingDot(color: ColorConst.color45FF01, shouldPulse: true),
              SizedBox(width: 8.w),
              ThemeText(
                text: 'You\'re saying...',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: ColorConst.color5AD1D3,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ThemeText(
            text: controller.liveTranscription.value,
            fontSize: 15,
            textColor: ColorConst.colorDCDCDC,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 30.h,
            child: _AudioWaveform(audioLevel: controller.audioLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResponseCard(VoiceConversationController controller) {
    final isThinking = controller.aiResponseText.value.isEmpty;

    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConst.color00FBFF.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConst.color00FBFF.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24.sp,
                height: 24.sp,
                decoration: BoxDecoration(
                  color: ColorConst.color00FBFF.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sailing_outlined,
                  color: ColorConst.color00FBFF,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 8.w),
              ThemeText(
                text: isThinking ? 'Thinking...' : 'Assistant',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: ColorConst.color00FBFF,
              ),
              if (controller.isAISpeaking.value) ...[
                SizedBox(width: 8.w),
                _SpeakingIndicator(),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          if (isThinking)
            _TypingIndicator()
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.h),
              child: SingleChildScrollView(
                child: ThemeText(
                  text: controller.aiResponseText.value,
                  fontSize: 14,
                  textColor: ColorConst.colorDCDCDC,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(VoiceConversationController controller) {
    final state = controller.dialogState.value;
    final isPaused = controller.isPaused.value;
    final isListening = state == VoiceDialogState.listening && !isPaused;

    if (state == VoiceDialogState.initializing || state == VoiceDialogState.error) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ThemeText(
                text: isPaused
                    ? 'Tap to resume listening'
                    : isListening
                        ? 'Listening actively'
                        : 'Processing...',
                fontSize: 12,
                textColor: ColorConst.colorDCDCDC60,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                if (isListening)
                  Container(
                    width: 88.sp,
                    height: 88.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorConst.color5AD1D3.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: controller.togglePause,
                  child: Container(
                    width: 72.sp,
                    height: 72.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isPaused
                            ? [ColorConst.color5AD1D3, ColorConst.color00FBFF]
                            : isListening
                                ? [ColorConst.color5AD1D3, ColorConst.color00FBFF]
                                : [ColorConst.colorA56DFF, ColorConst.colorA56DFF.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isPaused
                              ? ColorConst.color5AD1D3.withOpacity(0.5)
                              : isListening
                                  ? ColorConst.color5AD1D3.withOpacity(0.4)
                                  : ColorConst.colorA56DFF.withOpacity(0.3),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isPaused ? Icons.mic : Icons.pause_rounded,
                      color: ColorConst.white,
                      size: 32.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final Color color;
  final bool shouldPulse;

  const _PulsingDot({
    required this.color,
    this.shouldPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0.4),
        _dot(0.7),
        _dot(1.0),
      ],
    );
  }

  Widget _dot(double opacity) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: ColorConst.color00FBFF.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SpeakingIndicator extends StatelessWidget {
  const _SpeakingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _bar(8.h),
        _bar(12.h),
        _bar(8.h),
      ],
    );
  }

  Widget _bar(double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Container(
        width: 3.w,
        height: height,
        decoration: BoxDecoration(
          color: ColorConst.color00FBFF,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _AudioWaveform extends StatelessWidget {
  final RxDouble audioLevel;

  const _AudioWaveform({required this.audioLevel});

  static const String _lottieUrl =
      'https://lottie.host/85e40b76-0c0e-45ae-a330-c436b197b24e/lDbtQSrqFQ.json';

  @override
  Widget build(BuildContext context) {
    return Lottie.network(
      _lottieUrl,
      fit: BoxFit.contain,
      animate: true,
      repeat: true,
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return Center(
            child: SizedBox(
              width: 24.sp,
              height: 24.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorConst.color5AD1D3.withOpacity(0.5),
              ),
            ),
          );
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        return _SimpleFallbackWaveform();
      },
    );
  }
}

class _SimpleFallbackWaveform extends StatelessWidget {
  const _SimpleFallbackWaveform();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final height = (i == 2) ? 40.h : (i == 1 || i == 3) ? 30.h : 20.h;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Container(
            width: 4.w,
            height: height,
            decoration: BoxDecoration(
              color: ColorConst.color5AD1D3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

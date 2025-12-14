import 'dart:async';

import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:aiSeaSafe/services/loading_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class VerificationController extends LoadingController {
  //======= DECLARATIONS =======//
  GlobalKey<FormState> verifyOtpKey = GlobalKey<FormState>();
  TextEditingController otpCtr = TextEditingController();

  FocusNode otpFocusNode = FocusNode();
  RxBool isOtpHasFocus = false.obs;
  String? email;

  // Timer
  final RxInt remainingSeconds = 120.obs;
  Timer? timer;

  //======= SCREEN METHODS =======//
  @override
  void onInit() {
    if (Get.arguments != null) {
      email = Get.arguments['email'];
    }
    otpFocusNode.addListener(() {
      isOtpHasFocus.value = otpFocusNode.hasFocus;
    });
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  //======= EVENTS METHODS =======//
  Future<void> backOnTap() async {
    Get.back();
  }

  Future<void> resendOtpOnTap() async {
    startTimer();
  }

  Future<void> verifyButtonOnTap() async {
    if (verifyOtpKey.currentState?.validate() ?? false) {
      Get.toNamed(Routes.resetPassword)?.then((value) {
        Get.back();
      });
    }
  }

  //======= OTHER METHODS =======//
  void startTimer() {
    remainingSeconds.value = 120;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
      update();
    });
  }

  String get formattedTime {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  //======= APIs CALL =======//
}

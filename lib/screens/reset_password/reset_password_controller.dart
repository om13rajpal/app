import 'package:aiSeaSafe/services/loading_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ResetPasswordController extends LoadingController {
  //======= DECLARATIONS =======//
  GlobalKey<FormState> resetPasswordKey = GlobalKey<FormState>();
  TextEditingController passwordCtr = TextEditingController();
  TextEditingController confirmPasswordCtr = TextEditingController();

  FocusNode passwordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  RxBool isPasswordHasFocus = false.obs;
  RxBool isConfirmPasswordHasFocus = false.obs;

  //======= SCREEN METHODS =======//
  @override
  void onInit() {
    passwordNode.addListener(() {
      isPasswordHasFocus.value = passwordNode.hasFocus;
    });
    confirmPasswordNode.addListener(() {
      isConfirmPasswordHasFocus.value = confirmPasswordNode.hasFocus;
    });
    super.onInit();
  }

  //======= EVENTS METHODS =======//
  Future<void> backOnTap() async {
    Get.back();
  }

  Future<void> confirmOnTap() async {
    if (resetPasswordKey.currentState?.validate() ?? false) {
      Get.back();
      Get.back();
    }
  }

  //======= OTHER METHODS =======//
  //======= APIs CALL =======//
}

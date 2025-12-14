import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:aiSeaSafe/services/loading_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends LoadingController {
  //======= DECLARATIONS =======//
  GlobalKey<FormState> forgetPasswordKey = GlobalKey<FormState>();
  TextEditingController emailCtr = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  RxBool isEmailHasFocus = false.obs;

  //======= SCREEN METHODS =======//
  @override
  void onInit() {
    emailFocusNode.addListener(() {
      isEmailHasFocus.value = emailFocusNode.hasFocus;
    });
    super.onInit();
  }

  //======= EVENTS METHODS =======//
  Future<void> backOnTap() async {
    Get.back();
  }

  Future<void> sendButtonOnTap() async {
    if (forgetPasswordKey.currentState?.validate() ?? false) {
      Get.toNamed(Routes.verification, arguments: {"email": emailCtr.text.trim()});
    }
  }

  //======= OTHER METHODS =======//
  //======= APIs CALL =======//
}

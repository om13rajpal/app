import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:aiSeaSafe/services/loading_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends LoadingController {
  //======= DECLARATIONS =======//

  TextEditingController emailCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  RxBool isEmailHasFocus = false.obs;
  RxBool isPasswordHasFocus = false.obs;

  //======= SCREEN METHODS =======//
  @override
  void onInit() {
    emailFocusNode.addListener(() {
      isEmailHasFocus.value = emailFocusNode.hasFocus;
    });
    passwordFocusNode.addListener(() {
      isPasswordHasFocus.value = passwordFocusNode.hasFocus;
    });
    super.onInit();
  }

  //======= EVENTS METHODS =======//
  Future<void> signUpButtonOnTap() async {
    Get.toNamed(Routes.signUp);
  }

  //======= OTHER METHODS =======//
  //======= APIs CALL =======//
}

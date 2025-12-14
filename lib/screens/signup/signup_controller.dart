import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:aiSeaSafe/screens/voice_dialog/voice_dialog_view.dart';
import 'package:aiSeaSafe/services/loading_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignupController extends LoadingController {
  //======= DECLARATIONS =======//
  GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  TextEditingController fullNameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();

  FocusNode fullNameCtrNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  RxBool isFullNameNodeHasFocus = false.obs;
  RxBool isEmailHasFocus = false.obs;
  RxBool isPasswordHasFocus = false.obs;
  RxBool isAgree = false.obs;
  var showValidationError = false;
  String? selectedCountry;

  //======= SCREEN METHODS =======//
  @override
  void onInit() {
    fullNameCtrNode.addListener(() {
      isFullNameNodeHasFocus.value = fullNameCtrNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      isEmailHasFocus.value = emailFocusNode.hasFocus;
    });
    passwordFocusNode.addListener(() {
      isPasswordHasFocus.value = passwordFocusNode.hasFocus;
    });
    super.onInit();
  }

  //======= EVENTS METHODS =======//
  Future<void> backOnTap() async {
    Get.back();
  }

  Future<void> agreeOnTap() async {
    isAgree.toggle();
    isAgree.value;

    showValidationError = !isAgree.value;
    update();
  }

  Future<void> countryOnTap(country) async {
    selectedCountry = country.name;
    update();
  }

  /// Handles the sign up button tap.
  ///
  /// Validates the form and shows the voice assistant dialog after
  /// successful signup, then navigates to home.
  Future<void> signUpOnTap() async {
    final isValid = signUpKey.currentState?.validate() ?? false;
    bool isImageSelected = isAgree.value;

    showValidationError = !isImageSelected;
    update();

    if (!isValid || !isImageSelected) {
      return;
    }

    // Show voice assistant dialog after signup (skippable by user)
    await _showPostSignupVoiceDialog();

    // Navigate to home after dialog closes
    Get.offAllNamed(Routes.home);
  }

  /// Shows the voice assistant dialog after successful signup.
  ///
  /// This introduces the user to the voice assistant feature.
  /// The dialog is skippable - users can dismiss it if they don't
  /// want to use the voice feature.
  Future<void> _showPostSignupVoiceDialog() async {
    await Get.dialog<void>(
      const VoiceDialogView(showSkipButton: true),
      barrierDismissible: true,
      useSafeArea: false,
    );
  }

  //======= OTHER METHODS =======//
  //======= APIs CALL =======//
}

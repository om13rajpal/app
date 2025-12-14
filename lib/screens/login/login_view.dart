import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../export_controllers.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(ImageConst.logInBg), fit: BoxFit.cover),
        ),
        child: Obx(
          () => FlexibleColumnScrollView.withSafeArea(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(ImageConst.appLogoPng, scale: 3.5),
              Spacer(),
              ThemeText(text: StringConst.logInSecurely, fontSize: 21, fontWeight: FontWeight.w700),
              SizedBoxH10(),
              ThemeText(text: StringConst.accessYourAccount, textColor: ColorConst.colorDCDCDC80),
              SizedBoxH20(),
              LabelTextField(
                labelText: StringConst.registeredEmailAddress,
                validator: ValueValidators.emailValidator,
                textInputType: TextInputType.emailAddress,
                hintText: StringConst.emailHint,
                focusNode: controller.emailFocusNode,
                textController: controller.emailCtr,
                onChanged: (value) {
                  final cursorPosition = controller.emailCtr.selection;
                  controller.emailCtr.value = TextEditingValue(text: value.toLowerCase(), selection: cursorPosition);
                },
                prefixIcon: Icon(Hicons.message35LightOutline, color: controller.isEmailHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
              ),
              LabelTextField(
                labelText: StringConst.password,
                validator: ValueValidators.passwordValidator,
                textInputType: TextInputType.visiblePassword,
                hintText: StringConst.passwordHint,
                focusNode: controller.passwordFocusNode,
                textController: controller.passwordCtr,
                prefixIcon: Icon(Hicons.lock3LightOutline, color: controller.isPasswordHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
              ),
              SizedBoxH5(),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.forgetPassword);
                },
                child: ThemeText(text: StringConst.forgotPassword, fontSize: 12, fontWeight: FontWeight.w600, textColor: ColorConst.color00FBFF),
              ),
              SizedBoxH40(),
              PrimaryButton(
                label: StringConst.logIn,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                onPressed: () {
                  Get.offAllNamed(Routes.home);
                },
              ),
              SizedBoxH30(),

              Row(
                spacing: 10.sp,
                children: [
                  Container(
                    height: 1, // thickness of divider
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF07141F), Colors.white]),
                    ),
                  ).applyExpanded(),
                  ThemeText(text: StringConst.or, fontWeight: FontWeight.w600, fontSize: 12),
                  Container(
                    height: 1, // thickness of divider
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.white, Color(0xFF07141F)]),
                    ),
                  ).applyExpanded(),
                ],
              ),
              SizedBoxH30(),

              Row(
                spacing: 12.sp,
                children: [
                  PrimaryButton(
                    borderRadius: 10.sp,
                    icon: SvgPicture.asset(ImageConst.googleSvg),
                    label: StringConst.google,
                    color: ColorConst.color07141F,

                    outlined: true,
                    borderColor: ColorConst.colorD1D1D1,
                    onPressed: () {},
                    textColor: ColorConst.white,
                  ).applyExpanded(),
                  PrimaryButton(
                    borderRadius: 10.sp,
                    icon: SvgPicture.asset(ImageConst.appleSvg),
                    label: StringConst.apple,
                    color: ColorConst.color07141F,

                    outlined: true,
                    borderColor: ColorConst.colorD1D1D1,
                    onPressed: () {},
                    textColor: ColorConst.white,
                  ).applyExpanded(),
                ],
              ),
              SizedBoxH20(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeText(text: StringConst.doNotHaveAnAccount, fontWeight: FontWeight.w600, fontSize: 14),
                  InkWell(
                    onTap: controller.signUpButtonOnTap,
                    child: ThemeText(text: StringConst.signUp, fontWeight: FontWeight.w600, fontSize: 14, textColor: ColorConst.color00FBFF),
                  ),
                ],
              ),
              SizedBoxH30(),
            ],
          ).applyPaddingAll(kDefaultHPadding),
        ),
      ),
    );
  }
}

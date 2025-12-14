import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../export_controllers.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

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
          () => Form(
            key: controller.resetPasswordKey,
            child: FlexibleColumnScrollView.withSafeArea(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.rotate(
                  angle: 3.1416,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset(ImageConst.arrowRight),
                  ),
                ),
                SizedBox(height: 60),
                ThemeText(text: StringConst.resetPassword, fontSize: 21, fontWeight: FontWeight.w700),
                SizedBoxH25(),
                LabelTextField(
                  labelText: StringConst.password,
                  validator: ValueValidators.passwordValidator,
                  textInputType: TextInputType.visiblePassword,
                  hintText: StringConst.passwordHint,
                  focusNode: controller.passwordNode,
                  textController: controller.passwordCtr,
                  prefixIcon: Icon(Hicons.lock3LightOutline, color: controller.isPasswordHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
                ),
                SizedBoxH20(),
                LabelTextField(
                  labelText: StringConst.confirmPassword,
                  validator: (val) => ValueValidators.conformPasswordValidator(controller.passwordCtr.text, val),
                  textInputType: TextInputType.visiblePassword,
                  hintText: StringConst.passwordHint,
                  focusNode: controller.confirmPasswordNode,
                  textController: controller.confirmPasswordCtr,
                  prefixIcon: Icon(Hicons.lock3LightOutline, color: controller.isConfirmPasswordHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
                ),
                SizedBoxH20(),
                Spacer(),
                PrimaryButton(label: StringConst.continueText, fontWeight: FontWeight.w700, fontSize: 16, onPressed: controller.confirmOnTap),
                SizedBoxH30(),
              ],
            ).applyPaddingAll(kDefaultHPadding),
          ),
        ),
      ),
    );
  }
}

import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../export_controllers.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});

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
            key: controller.forgetPasswordKey,
            child: FlexibleColumnScrollView.withSafeArea(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.rotate(
                  angle: 3.1416,
                  child: InkWell(onTap: controller.backOnTap, child: SvgPicture.asset(ImageConst.arrowRight)),
                ),
                SizedBox(height: 60),
                ThemeText(text: StringConst.forgotPassword1, fontSize: 21, fontWeight: FontWeight.w700),
                SizedBoxH25(),
                LabelTextField(
                  labelText: StringConst.email,
                  validator: ValueValidators.emailValidator,
                  textInputType: TextInputType.emailAddress,
                  hintText: StringConst.enterEmail,
                  focusNode: controller.emailFocusNode,
                  textController: controller.emailCtr,
                  onChanged: (value) {
                    final cursorPosition = controller.emailCtr.selection;
                    controller.emailCtr.value = TextEditingValue(text: value.toLowerCase(), selection: cursorPosition);
                  },
                  prefixIcon: Icon(Hicons.message35LightOutline, color: controller.isEmailHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
                ),
                SizedBoxH20(),
                ThemeText(text: StringConst.byProceedingYouConsentToGetAlls, textColor: ColorConst.colorDCDCDC80),
                Spacer(),
                PrimaryButton(label: StringConst.sendCode, fontWeight: FontWeight.w700, fontSize: 16, onPressed: controller.sendButtonOnTap),
                SizedBoxH30(),
              ],
            ).applyPaddingAll(kDefaultHPadding),
          ),
        ),
      ),
    );
  }
}

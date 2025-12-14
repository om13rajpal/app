import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../export_controllers.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerificationController>(
      init: VerificationController(),
      builder: (logic) {
        return Scaffold(
          body: Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(ImageConst.logInBg), fit: BoxFit.cover),
            ),
            child: Form(
              key: controller.verifyOtpKey,
              child: FlexibleColumnScrollView.withSafeArea(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.rotate(
                    angle: 3.1416,
                    child: InkWell(onTap: controller.backOnTap, child: SvgPicture.asset(ImageConst.arrowRight)),
                  ),
                  SizedBox(height: 60),
                  ThemeText(text: StringConst.verifyYourIdentity, fontSize: 21, fontWeight: FontWeight.w700),
                  SizedBoxH25(),
                  ThemeText(text: StringConst.enterTheDigitCode, fontSize: 16, fontWeight: FontWeight.w600),
                  SizedBoxH5(),
                  if (controller.email!.isNotEmpty) ThemeText(text: controller.email ?? "", fontSize: 14, textColor: ColorConst.colorDCDCDC, fontWeight: FontWeight.w400),
                  SizedBoxH10(),
                  ThemeText(text: StringConst.enterOTP, fontWeight: FontWeight.w500, textColor: ColorConst.colorDCDCDC87),
                  SizedBoxH5(),
                  Pinput(
                    controller: controller.otpCtr,
                    length: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => ValueValidators.otpValidator(value),
                    keyboardType: TextInputType.number,
                    onCompleted: (value) => controller.update(),
                    onChanged: (value) => controller.update(),
                    defaultPinTheme: _buildPinTheme(context, ColorConst.colorDCDCDC40),
                    focusedPinTheme: _buildPinTheme(context, ColorConst.colorDCDCDC),
                    separatorBuilder: (index) => SizedBoxW20(),
                  ),

                  SizedBoxH25(),
                  controller.remainingSeconds.value != 0
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: ColorConst.color000000.withValues(alpha: 0.1)),
                          ),
                          child: ThemeText(text: " ${controller.formattedTime}", fontSize: 16, fontWeight: FontWeight.w600),
                        ).toCenter()
                      : GestureDetector(
                          onTap: controller.resendOtpOnTap,
                          child: ThemeText(text: StringConst.resendOTP, fontSize: 16, fontWeight: FontWeight.w600).toCenter(),
                        ),
                  SizedBoxH25(),
                  PrimaryButton(label: StringConst.verify, fontWeight: FontWeight.w700, fontSize: 16, onPressed: controller.verifyButtonOnTap),
                  SizedBoxH30(),
                ],
              ).applyPaddingAll(kDefaultHPadding),
            ),
          ),
        );
      },
    );
  }

  PinTheme _buildPinTheme(BuildContext context, Color borderColor) {
    return PinTheme(
      height: context.width / 6 - 10,
      width: context.width / 6,
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ColorConst.colorDCDCDC60),
    );
  }
}

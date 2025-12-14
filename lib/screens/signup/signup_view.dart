import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/gradient_borders.dart';

import '../export_controllers.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(
      init: SignupController(),
      builder: (logic) {
        return Scaffold(
          body: Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(ImageConst.logInBg), fit: BoxFit.cover),
            ),
            child: Obx(
              () => Form(
                key: controller.signUpKey,
                child: FlexibleColumnScrollView.withSafeArea(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.rotate(
                      angle: 3.1416,
                      child: InkWell(onTap: controller.backOnTap, child: SvgPicture.asset(ImageConst.arrowRight)),
                    ),
                    SizedBox(height: 60),
                    ThemeText(text: StringConst.signUp, fontSize: 21, fontWeight: FontWeight.w700),
                    SizedBoxH25(),
                    LabelTextField(
                      labelText: StringConst.fullName,
                      validator: (val) => ValueValidators.nameValidation(name: StringConst.fullName, val: val.toString()),
                      textInputType: TextInputType.emailAddress,
                      hintText: StringConst.enterFullName,
                      focusNode: controller.fullNameCtrNode,
                      textController: controller.fullNameCtr,
                      maxLength: 35,
                      inputFormatters: [SingleSpaceInputFormatter()],
                      prefixIcon: Icon(Hicons.profile1LightOutline, color: controller.isFullNameNodeHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
                    ),
                    SizedBoxH20(),
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
                    LabelTextField(
                      labelText: StringConst.createPassword,
                      validator: ValueValidators.passwordValidator,
                      textInputType: TextInputType.visiblePassword,
                      hintText: StringConst.enterCreatePassword,
                      focusNode: controller.passwordFocusNode,
                      textController: controller.passwordCtr,
                      prefixIcon: Icon(Hicons.lock3LightOutline, color: controller.isPasswordHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60),
                    ),
                    SizedBoxH20(),
                    ThemeText(text: StringConst.country, fontSize: 14, textColor: ColorConst.colorDCDCDC87, fontWeight: FontWeight.w500),
                    SizedBoxH10(),
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          countryListTheme: CountryListThemeData(
                            flagSize: 25,
                            backgroundColor: ColorConst.color07141F,
                            textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                            bottomSheetHeight: 500,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                            inputDecoration: InputDecoration(
                              filled: true,
                              isDense: false,
                              fillColor: ColorConst.color091B2C,
                              errorMaxLines: 3,
                              contentPadding: EdgeInsets.all(12.sp),
                              counterText: '',
                              border: GradientOutlineInputBorder(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [ColorConst.white, ColorConst.colorFFFFFF13],
                                  stops: [0.2, 0.4],
                                  transform: GradientRotation(99 * 3.1416 / 80),
                                ),
                                width: 1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: GradientOutlineInputBorder(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [ColorConst.white, ColorConst.colorFFFFFF13],
                                  stops: [0.2, 0.4],
                                  transform: GradientRotation(99 * 3.1416 / 80),
                                ),
                                width: 1,
                                borderRadius: BorderRadius.circular(8),
                              ),

                              focusedBorder: GradientOutlineInputBorder(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [ColorConst.color5AD1D3, ColorConst.colorFFFFFF13],
                                  stops: [0.2, 0.4],
                                  transform: GradientRotation(99 * 3.1416 / 80),
                                ),
                                width: 1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hoverColor: ColorConst.black,
                              hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: ColorConst.colorDCDCDC38, height: 1.0, letterSpacing: 0),
                              hintText: "Search",
                            ),
                          ),
                          onSelect: (Country country) => controller.countryOnTap(country),
                        );
                      },
                      child: Container(
                        height: 48,
                        width: Get.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [ColorConst.white, ColorConst.colorFFFFFF13],
                            stops: [0.2, 0.4],
                            transform: GradientRotation(99 * 3.1416 / 80),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Container(
                            height: 46,
                            width: Get.width - 30,
                            padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            decoration: BoxDecoration(color: ColorConst.color091B2C, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                SvgPicture.asset(ImageConst.country),
                                SizedBoxW8(),
                                ThemeText(text: controller.selectedCountry!.isEmpty ? StringConst.country : controller.selectedCountry ?? "", fontSize: 14, fontWeight: FontWeight.w400),
                                SizedBoxH25(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBoxH15(),
                    InkWell(
                      onTap: controller.agreeOnTap,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(controller.isAgree.value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: ColorConst.colorDCDCDC80),
                          SizedBoxW8(),
                          Expanded(
                            child: ThemeText(text: StringConst.iAgree, fontSize: 14, fontWeight: FontWeight.w600, textColor: ColorConst.colorDCDCDC80),
                          ),
                        ],
                      ),
                    ),
                    SizedBoxH5(),
                    Visibility(
                      visible: controller.showValidationError,
                      child: ThemeText(text: StringConst.pleaseAccept, fontSize: 12, textColor: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    PrimaryButton(label: StringConst.signUp, fontWeight: FontWeight.w700, fontSize: 16, onPressed: controller.signUpOnTap),
                    SizedBoxH30(),
                  ],
                ).applyPaddingAll(kDefaultHPadding),
              ),
            ),
          ),
        );
      },
    );
  }
}

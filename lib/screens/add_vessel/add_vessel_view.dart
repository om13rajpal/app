import 'dart:io';

import 'package:aiSeaSafe/screens/export_controllers.dart';
import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/common_fancy_shimmer.dart';
import 'package:aiSeaSafe/widgets/country_code/country_code_picker.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AddVesselView extends GetView<AddVesselController> {
  const AddVesselView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddVesselController>(
      init: AddVesselController(),
      builder: (logic) {
        return Scaffold(
          appBar: CustomAppBar(
            isBack: true,
            titleCenter: true,
            title: ThemeText(text: StringConst.addNewVessel, fontWeight: FontWeight.w600, fontSize: 18),
          ),
          body: Form(
            key: controller.formKey,
            child: FlexibleColumnScrollView.withSafeArea(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBoxH5(),
                LabelTextField(
                  textInputType: TextInputType.name,
                  labelText: StringConst.vesselName,
                  hintText: StringConst.vesselNameHint,
                  focusNode: controller.vesselNameFocus,
                  textController: controller.vesselNameCtr,
                  validator: ValueValidators.nameValidator,
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.ship, size: 20, color: controller.isVesselNameHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
                ),
                const SizedBox(height: 16),

                LabelTextField(
                  textInputType: TextInputType.text,
                  isSpaceAllowed: false,
                  labelText: StringConst.vesselId,
                  hintText: StringConst.vesselIdHint,
                  focusNode: controller.vesselIdFocus,
                  textController: controller.vesselIdCtr,
                  validator: ValueValidators.vesselIdValidator,
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.document_text, size: 20, color: controller.isVesselIdHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
                ),
                const SizedBox(height: 16),

                LabelTextField(
                  textInputType: TextInputType.text,
                  labelText: StringConst.selectVesselType,
                  readOnly: true,
                  onTap: () => controller.selectVesselType(),
                  hintText: StringConst.vesselTypeHint,
                  focusNode: controller.vesselTypeFocus,
                  textController: controller.vesselTypeCtr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vessel type';
                    }
                    return null;
                  },
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.size, size: 20, color: controller.isVesselTypeHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
                ),
                const SizedBox(height: 16),

                LabelTextField(
                  textInputType: TextInputType.name,
                  validator: ValueValidators.captainNameValidator,
                  labelText: StringConst.assignCaptain,
                  hintText: StringConst.assignCaptainHit,
                  focusNode: controller.captainFocus,
                  textController: controller.captainCtr,
                  prefixIcon: Obx(
                    () => SvgPicture.asset(
                      fit: BoxFit.cover,
                      ImageConst.captainHatSvg,
                      color: controller.isCaptainHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60,
                    ).applyPaddingOnly(right: 4, top: 4),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => LabelTextField(
                    labelText: StringConst.emergencyContact,
                    hintText: "8756367665",
                    focusNode: controller.emergencyFocus,
                    textController: controller.emergencyCtr,
                    textInputType: TextInputType.phone,
                    maxLength: controller.phoneNumberLength.value,
                    validator: (val) => ValueValidators.emergencyPhoneValidator(val, controller.emergencyCtr.text, controller.phoneNumberLength.value, controller.phoneNumberCountryName.value),
                    prefixIconConstraints: BoxConstraints(),
                    prefixIcon: CountryCodePicker(
                      textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: ColorConst.white),
                      searchStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: ColorConst.white),
                      dialogTextStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: ColorConst.white),
                      backgroundColor: ColorConst.color091B2C,
                      dialogBackgroundColor: ColorConst.color091B2C,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      showDropDownButton: false,
                      showDivider: true,
                      barrierColor: Colors.transparent,
                      boxDecoration: BoxDecoration(
                        color: ColorConst.color091B2C,
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hideSearch: false,
                      hideCloseIcon: true,
                      hideHeaderText: true,
                      showCountryOnly: false,
                      showFlagMain: false,
                      hideMainText: false,
                      showCountryCodeOnly: false,
                      showCountryCode: false,
                      headerTextStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, decoration: TextDecoration.none, color: ColorConst.primary),
                      onInit: (code) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.onInitCountryName(code?.dialCode ?? '', code?.name?.replaceAll('[', '').replaceAll(']', '') ?? '', code?.code ?? '');
                        });
                      },
                      onChanged: (element) {
                        controller.onTapCountryName(element.dialCode ?? '', element.name ?? '', element.code ?? '');
                        controller.update();
                      },
                      initialSelection: controller.phoneNumberCountryIsoCode.value,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ThemeText(text: "Add Featured Image", textColor: ColorConst.colorDCDCDC87),
                const SizedBox(height: 16),
                Obx(
                  () => InkWell(
                    onTap: () => controller.btnCameraTap(context),
                    child: Container(
                      width: Get.width,
                      // margin: EdgeInsets.only(top: kDefaultVPadding, bottom: 5),
                      padding: controller.selectedImage.value.isNotEmpty ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: kDefaultHPadding, vertical: 30.h),
                      decoration: BoxDecoration(
                        color: ColorConst.color091B2C,
                        borderRadius: BorderRadius.circular(10.sp),
                        border: Border.all(color: ColorConst.color11242F),
                      ),
                      child: controller.selectedImage.value.contains("http")
                          ? CommonShimmerImage(imageUrl: controller.selectedImage.value)
                          : controller.selectedImage.value != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.sp),
                              child: Image.file(File(controller.selectedImage.value), fit: BoxFit.cover),
                            )
                          : SvgPicture.asset(ImageConst.vesselSvg),
                    ).toCenter(),
                  ),
                ),
                SizedBoxH5(),
                Visibility(
                  visible: controller.showValidationError,
                  child: ThemeText(text: StringConst.pleaseUploadOrTake, fontSize: 12, textColor: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                ),
                SizedBoxH30(),
                PrimaryButton(icon: Icon(Hicons.addBold), label: StringConst.addVessel, onPressed: controller.addVesselOrTrip),
              ],
            ).applyPaddingAll(kDefaultHPadding),
          ),
        );
      },
    );
  }
}

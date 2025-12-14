import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:aiSeaSafe/utils/helper/validators.dart';
import 'package:aiSeaSafe/widgets/country_code/country_code_picker.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../export_controllers.dart';

class AddNewTripView extends GetView<AddNewTripController> {
  const AddNewTripView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddNewTripController>(
      init: AddNewTripController(),
      builder: (logic) {
        return Scaffold(
          appBar: CustomAppBar(
            isBack: true,
            titleCenter: true,
            title: ThemeText(text: StringConst.addNewTrip1, fontWeight: FontWeight.w600, fontSize: 18),
          ),
          body: Form(
            key: controller.formKey,
            child: FlexibleColumnScrollView.withSafeArea(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBoxH5(),
                LabelTextField(
                  textInputType: TextInputType.name,

                  labelText: StringConst.startFrom,
                  hintText: StringConst.exPanamaPoint,
                  focusNode: controller.startFromFocus,
                  textController: controller.startFromCtr,
                  validator: (val) => ValueValidators.simpleValidator(name: StringConst.startFrom, val: val ?? ''),
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.location_add, size: 20, color: controller.isStartFromHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
                ),
                const SizedBox(height: 16),
                LabelTextField(
                  textInputType: TextInputType.name,

                  labelText: StringConst.destination,
                  hintText: StringConst.exLondonBay,
                  focusNode: controller.destinationFocus,
                  textController: controller.destinationCtr,
                  validator: (val) => ValueValidators.simpleValidator(name: StringConst.destination, val: val ?? ''),
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.location_tick, size: 20, color: controller.isDestinationHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
                ),
                const SizedBox(height: 16),
                LabelTextField(
                  textInputType: TextInputType.name,

                  labelText: StringConst.startDate,
                  hintText: StringConst.date,
                  focusNode: controller.startFromFocus,
                  textController: controller.startDateCtr,
                  validator: (val) => ValueValidators.simpleSelectValidator(name: StringConst.startDate, val: val ?? ''),
                  readOnly: true,
                  onTap: controller.onStartDateTap,
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.calendar_2, size: 20, color: controller.isStartDateHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
                ),
                const SizedBox(height: 16),
                LabelTextField(
                  textInputType: TextInputType.name,
                  readOnly: true,
                  labelText: StringConst.estimatedArrivalDate,
                  hintText: StringConst.date,
                  focusNode: controller.startFromFocus,
                  textController: controller.estimatedDateCtr,
                  validator: (val) => ValueValidators.simpleSelectValidator(name: StringConst.estimatedArrivalDate, val: val ?? ''),
                  onTap: controller.onEndDateTap,
                  prefixIcon: Obx(() => Icon(IconsaxPlusLinear.calendar_tick, size: 20, color: controller.isEstimatedDateHasFocus.value ? ColorConst.color5AD1D3 : ColorConst.colorDCDCDC60)),
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
                Spacer(),
                SizedBoxH10(),
                PrimaryButton(icon: SvgPicture.asset(ImageConst.trip), label: StringConst.startTrip, onPressed: controller.addTrip),
              ],
            ).applyPaddingAll(kDefaultHPadding),
          ),
        );
      },
    );
  }
}

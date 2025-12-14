import 'package:aiSeaSafe/data/models/export_model.dart';
import 'package:aiSeaSafe/screens/add_vessel/vessel_type_sheet.dart';
import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/helper/export_helper.dart';
import 'package:aiSeaSafe/widgets/common_camera_dialog.dart';
import 'package:aiSeaSafe/widgets/country_code/country_code_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AddVesselController extends GetxController {
  //======= DECLARATIONS =======//
  // Focus nodes
  final vesselNameFocus = FocusNode();
  final vesselIdFocus = FocusNode();
  final vesselTypeFocus = FocusNode();
  final captainFocus = FocusNode();
  final emergencyFocus = FocusNode();

  // Text controllers
  final vesselNameCtr = TextEditingController();
  final vesselIdCtr = TextEditingController();
  final vesselTypeCtr = TextEditingController();
  final captainCtr = TextEditingController();
  final emergencyCtr = TextEditingController();

  // Reactive booleans for focus state
  final isVesselNameHasFocus = false.obs;
  final isVesselIdHasFocus = false.obs;
  final isVesselTypeHasFocus = false.obs;
  final isCaptainHasFocus = false.obs;
  final isEmergencyHasFocus = false.obs;

  // Phone number related observables
  var phoneNumberLength = 10.obs;
  var phoneNumberCountryName = 'India'.obs;
  var phoneNumberCountryIsoCode = 'IN'.obs;
  var phoneNumberCountryCode = '+91'.obs;
  RxString selectedImage = "".obs;
  var showValidationError = false;

  // Form validation
  final formKey = GlobalKey<FormState>();

  List<ItemModel> vesselTypeList = [
    ItemModel(
      title: StringConst.carrier,
      icon: Icon(IconsaxPlusLinear.box, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.passenger,
      icon: Icon(IconsaxPlusLinear.profile_2user, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.roroVessel,
      icon: Icon(IconsaxPlusLinear.car, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.tanker,
      icon: Icon(IconsaxPlusLinear.drop, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.fishing,
      icon: SvgPicture.asset(ImageConst.fishSvg, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.reeferShips,
      icon: SvgPicture.asset(ImageConst.tempSvg, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.liveStock,
      icon: SvgPicture.asset(ImageConst.goatSvg, color: ColorConst.colorDCDCDC),
    ),
    ItemModel(
      title: StringConst.tugboat,
      icon: SvgPicture.asset(ImageConst.boattugSvg, color: ColorConst.colorDCDCDC),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    vesselNameFocus.addListener(() {
      isVesselNameHasFocus.value = vesselNameFocus.hasFocus;
    });
    vesselIdFocus.addListener(() {
      isVesselIdHasFocus.value = vesselIdFocus.hasFocus;
    });
    vesselTypeFocus.addListener(() {
      isVesselTypeHasFocus.value = vesselTypeFocus.hasFocus;
    });
    captainFocus.addListener(() {
      isCaptainHasFocus.value = captainFocus.hasFocus;
    });
    emergencyFocus.addListener(() {
      isEmergencyHasFocus.value = emergencyFocus.hasFocus;
    });
  }

  @override
  void onClose() {
    // Dispose controllers and focus nodes
    vesselNameCtr.dispose();
    vesselIdCtr.dispose();
    vesselTypeCtr.dispose();
    captainCtr.dispose();
    emergencyCtr.dispose();

    vesselNameFocus.dispose();
    vesselIdFocus.dispose();
    vesselTypeFocus.dispose();
    captainFocus.dispose();
    emergencyFocus.dispose();

    super.onClose();
  }

  //======= SCREEN METHODS =======//
  //======= EVENTS METHODS =======//

  void selectVesselType() async {
    final result = await BottomSheetAlert().displayBottomSheetAlert(child: VesselTypeSheet(vesselList: vesselTypeList));
    if (result != null) {
      vesselTypeCtr.text = result;
    }
  }

  //======= OTHER METHODS =======//
  // Phone number methods
  void onTapCountryName(String element, String countryNameValue, String isoCode) {
    String countryCode = element.replaceFirst('+', '');
    phoneNumberCountryName.value = countryNameValue;
    phoneNumberCountryCode.value = countryCode;
    phoneNumberCountryIsoCode.value = isoCode;
    phoneNumberLength.value = getPhoneLength(element);
    update();
  }

  void onInitCountryName(String element, String countryNameValue, String isoCode) {
    String countryCode = element.replaceFirst('+', '');
    phoneNumberCountryName.value = countryNameValue;
    phoneNumberCountryCode.value = countryCode;
    phoneNumberCountryIsoCode.value = isoCode;
    phoneNumberLength.value = getPhoneLength(element);
    update();
  }

  int getPhoneLength(String? countryCode) {
    var countryData = AllCountries.allCountries.firstWhere((country) => country['phone'] == countryCode, orElse: () => <String, dynamic>{});

    return countryData['phoneLength'];
  }

  void btnCameraTap(BuildContext context) async {
    String? imagePath = await MediaPickerUtils.pickImage(context: context);

    if (imagePath != null) {
      selectedImage.value = imagePath;
      update();
    }
  }

  // Method to add vessel or trip
  void addVesselOrTrip() {
    print("Button pressed!");
    final isValid = formKey.currentState?.validate() ?? false;
    bool isImageSelected = selectedImage.value.isNotEmpty;

    showValidationError = !isImageSelected;
    update();

    if (!isValid || !isImageSelected) {
      return;
    }

    final vessel = VesselModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: vesselNameCtr.text.trim(),
      vesselId: vesselIdCtr.text.trim(),
      type: vesselTypeCtr.text.trim(),
      captain: captainCtr.text.trim(),
      emergencyContact: '${phoneNumberCountryCode.value}${emergencyCtr.text.trim()}',
      imageUrl: selectedImage.value.isNotEmpty ? selectedImage.value : null,
    );

    Get.back(result: vessel);
  }

  //======= APIs CALL =======//
}

import 'package:aiSeaSafe/widgets/country_code/country_code_number.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helper/export_helper.dart';

class AddNewTripController extends GetxController with DateHelper {
  //======= DECLARATIONS =======//
  // Focus nodes
  final startFromFocus = FocusNode();
  final destinationFocus = FocusNode();
  final startDateFocus = FocusNode();
  final estimatedDateFocus = FocusNode();
  final emergencyFocus = FocusNode();

  // Text controllers
  final startFromCtr = TextEditingController();
  final destinationCtr = TextEditingController();
  final startDateCtr = TextEditingController();
  final estimatedDateCtr = TextEditingController();
  final emergencyCtr = TextEditingController();

  // Reactive booleans for focus state
  final isStartFromHasFocus = false.obs;
  final isDestinationHasFocus = false.obs;
  final isStartDateHasFocus = false.obs;
  final isEstimatedDateHasFocus = false.obs;
  final isEmergencyHasFocus = false.obs;

  // Phone number related observables
  var phoneNumberLength = 10.obs;
  var phoneNumberCountryName = 'India'.obs;
  var phoneNumberCountryIsoCode = 'IN'.obs;
  var phoneNumberCountryCode = '+91'.obs;
  RxString selectedImage = "".obs;

  // Form validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    startFromFocus.addListener(() {
      isStartFromHasFocus.value = startFromFocus.hasFocus;
    });
    destinationFocus.addListener(() {
      isDestinationHasFocus.value = destinationFocus.hasFocus;
    });
    startDateFocus.addListener(() {
      isStartDateHasFocus.value = startDateFocus.hasFocus;
    });
    estimatedDateFocus.addListener(() {
      isEstimatedDateHasFocus.value = estimatedDateFocus.hasFocus;
    });
    emergencyFocus.addListener(() {
      isEmergencyHasFocus.value = emergencyFocus.hasFocus;
    });
  }

  @override
  void onClose() {
    startFromFocus.dispose();
    destinationFocus.dispose();
    startDateFocus.dispose();
    estimatedDateFocus.dispose();
    emergencyFocus.dispose();

    super.onClose();
  }

  //======= SCREEN METHODS =======//
  //======= EVENTS METHODS =======//
  void onStartDateTap() {
    pickDate(controllerToUpdate: startDateCtr, initialDate: parseDate(startDateCtr.text) ?? DateTime.now(), lastDate: parseDate(estimatedDateCtr.text));
  }

  void onEndDateTap() {
    pickDate(
      controllerToUpdate: estimatedDateCtr,
      initialDate: parseDate(estimatedDateCtr.text) ?? parseDate(startDateCtr.text) ?? DateTime.now(),
      firstDate: parseDate(startDateCtr.text) ?? DateTime.now(),
    );
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

  // Method to add vessel or trip
  void addTrip() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (isValid) {
      final trip = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'startFrom': startFromCtr.text.trim(),
        'destination': destinationCtr.text.trim(),
        'startDate': startDateCtr.text.trim(),
        'estimatedDate': estimatedDateCtr.text.trim(),
        'estimatedArrival': emergencyCtr.text.trim(),
        // Add other trip-specific fields
      };
      Get.back(result: trip);
    }
  }

  //======= APIs CALL =======//
}

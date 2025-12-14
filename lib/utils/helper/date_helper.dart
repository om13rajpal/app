import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/export_const.dart';

mixin DateHelper {
  String formatDate(DateTime? date) => date == null ? '' : DateFormat('dd-MM-yyyy').format(date);

  DateTime? parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // Show Date Picker
  Future<void> pickDate({required TextEditingController controllerToUpdate, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, VoidCallback? onPicked}) async {
    // Ensure we have valid dates for the picker
    final DateTime pickerFirstDate = firstDate ?? DateTime.now();
    final DateTime pickerLastDate = lastDate ?? DateTime(2100);
    final DateTime pickerInitialDate = initialDate ?? DateTime.now();

    // Validate that lastDate is not before firstDate
    final DateTime validLastDate = pickerLastDate.isBefore(pickerFirstDate) ? DateTime(2100) : pickerLastDate;

    // Ensure initialDate is within the valid range
    DateTime validInitialDate = pickerInitialDate;
    if (validInitialDate.isBefore(pickerFirstDate)) {
      validInitialDate = pickerFirstDate;
    } else if (validInitialDate.isAfter(validLastDate)) {
      validInitialDate = validLastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: validInitialDate,
      firstDate: pickerFirstDate,
      lastDate: validLastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white, // selected date text color
              onPrimary: ColorConst.color091B2C, // text on primary color
              surface: ColorConst.color091B2C, // background of the picker
              onSurface: Colors.white, // text color
            ),
            dialogBackgroundColor: ColorConst.color091B2C, // dialog background
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controllerToUpdate.text = formatDate(picked);
      onPicked?.call();
    }
  }
}

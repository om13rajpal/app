import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Project imports:

class BottomSheetAlert<T> {
  Future<T?> displayBottomSheetAlert({
    required Widget child,
    double borderRadius = 16.0,
    Color? barrierColor,
    Color? backgroundColor,
    Color? borderColor,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) async {
    final result = await showModalBottomSheet<T?>(
      backgroundColor: backgroundColor ?? ColorConst.color07141F,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor ?? ColorConst.color28333D),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      context: Get.context!,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Wrap(children: [child, const SizedBox(height: 12.0)]).applyPaddingHorizontal(18.sp).applyPaddingVertical(20.sp),
        );
      },
    );
    return result;
  }
}

import 'package:aiSeaSafe/data/models/export_model.dart';
import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VesselTypeSheet extends StatelessWidget {
  const VesselTypeSheet({super.key, required this.vesselList});
  final List<ItemModel> vesselList;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: vesselList.map((e) {
        return GestureDetector(
          onTap: () => Get.back(result: e.title),
          child: Row(
            spacing: 20.sp,
            children: [
              e.icon!,
              ThemeText(
                text: e.title!,
                fontSize: 16,
                textColor: ColorConst.colorDCDCDC,
              ),
            ],
          ).applyPaddingHorizontal(8.sp).applyPaddingVertical(10.sp),
        );
      }).toList(),
    );
  }
}

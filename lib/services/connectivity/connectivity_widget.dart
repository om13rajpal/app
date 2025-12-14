import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:aiSeaSafe/utils/helper/sized_box.dart';

import '../../utils/constants/string_constant.dart';
import '../../widgets/theme_text.dart';

class ConnectivityScreen extends StatelessWidget {
  const ConnectivityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              Icons.warning_rounded,
              color: ColorConst.primary,
              size: 30.sp,
            ),
          ),
          SizedBoxH1(),
          const ThemeText(
            text: StringConst.noInternet,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          SizedBoxH1(),
          const ThemeText(
            text: StringConst.pleaseEnableYourInterNet,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textColor: ColorConst.black,
          ),
        ],
      ),
    );
  }
}

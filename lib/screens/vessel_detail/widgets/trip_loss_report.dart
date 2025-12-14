import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/theme_text.dart';

class ReportRowWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String detail;
  final Color detailColor;

  const ReportRowWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.detail,
    this.detailColor = Colors.white, // default
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(iconPath),
        SizedBoxW10(),
        ThemeText(text: title, fontSize: 14, fontWeight: FontWeight.w400),
        const Spacer(),
        ThemeText(text: detail, fontSize: 14, fontWeight: FontWeight.w600, textColor: detailColor),
      ],
    ).applyPaddingVertical(8);
  }
}

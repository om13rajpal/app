import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/theme_text.dart';

class InfoItemWidget extends StatelessWidget {
  final String value; // Top big text
  final String label; // Small text
  final String iconPath; // Icon path
  final CrossAxisAlignment crossAxisAlignment;

  const InfoItemWidget({super.key, required this.value, required this.label, required this.iconPath, this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        ThemeText(text: value, fontSize: 16, fontWeight: FontWeight.w500),
        SizedBoxH2(),
        Row(
          children: [
            SvgPicture.asset(iconPath),
            SizedBoxW5(),
            ThemeText(text: label, fontSize: 12, fontWeight: FontWeight.w500),
          ],
        ),
      ],
    );
  }
}

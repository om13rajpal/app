import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constants/color_constant.dart';

class ThemeText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final Color? textColor;
  final double fontSize;

  final TextOverflow? textOverflow;
  final FontWeight fontWeight;
  final TextDecoration textDecoration;
  final int? numberOfLines;
  final TextStyle? style;
  final TextOverflow? overflow;
  const ThemeText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    this.textColor = ColorConst.white,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.textDecoration = TextDecoration.none,
    this.numberOfLines,
    this.textOverflow,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: textOverflow,
      textScaler: const TextScaler.linear(1.0),
      style:
          style ??
          TextStyle(
            fontSize: fontSize.sp,
            fontWeight: fontWeight,
            decoration: textDecoration,
            color: textColor,
            overflow: overflow,
          ),
      maxLines: numberOfLines,
    );
  }
}

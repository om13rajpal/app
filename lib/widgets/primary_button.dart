import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final double? fontSize;
  final double? height;
  final double? width;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool outlined;
  final double? borderWidth;
  final FontWeight? fontWeight;
  final TextDirection? direction;
  final double? borderRadius;
  final MainAxisAlignment? mainAxisAlignment;
  final double? elevation;
  final bool enabled;
  final bool isOnlyIcon;
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.fontSize,
    this.height,
    this.width,
    this.color = ColorConst.white,
    this.textColor = ColorConst.black,
    this.borderColor,
    this.onPressed,
    this.horizontalPadding,
    this.verticalPadding,
    this.outlined = false,
    this.borderWidth,
    this.fontWeight,
    this.direction,
    this.borderRadius,
    this.mainAxisAlignment,
    this.elevation,
    this.enabled = true,
    this.isOnlyIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;
    final buttonColor = isEnabled ? color : const Color(0xFFD6D6D6);
    final textOpacity = isEnabled ? 1.0 : 0.5;

    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: isEnabled && !outlined ? color : Color(0xffD6D6D6),
        borderRadius: BorderRadius.circular(
          borderRadius ?? kDefaultRadiusValue,
        ),
      ),
      child: MaterialButton(
        color: buttonColor,

        textColor: textColor.withValues(alpha: textOpacity),
        disabledColor: ColorConst.grey,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? kDefaultPaddingValue,
          vertical: verticalPadding ?? kDefaultVPadding,
        ),
        height: height ?? 45.sp,
        elevation: isEnabled ? elevation ?? 0 : 0,
        disabledElevation: 0,
        highlightElevation: 0,
        // splashColor: textColor.withValues(alpha: 0.1),
        // highlightColor: textColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? kDefaultRadiusValue,
          ),
          side: outlined
              ? BorderSide(
                  color: borderColor ?? ColorConst.white,
                  width: borderWidth ?? 1.0,
                )
              : BorderSide.none,
        ),
        onPressed: isEnabled ? () => onPressed?.call() : null,
        child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          textDirection: direction,
          children: [
            if (!isOnlyIcon)
              Flexible(
                child: ThemeText(
                  text: label,
                  textColor: textColor,
                  fontSize: fontSize ?? 16.0,
                  fontWeight: fontWeight ?? FontWeight.w600,
                ),
              ),
            if (icon != null) ...[ SizedBox(width: 10.w),icon!,],
          ],
        ),
      ),
    );
  }
}

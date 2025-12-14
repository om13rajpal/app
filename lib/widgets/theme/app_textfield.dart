// Flutter imports:
import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/gradient_borders.dart';

// Project imports:

class LabelTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextInputType textInputType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final String? toolTipMsg;
  final TextEditingController? textController;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final String? Function(String?)? onSaved;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? padding;
  final FocusNode? focusNode;
  final double borderRadius;
  final bool labelTextVisible;
  final bool toolTipVisible;
  final bool labelTextVisibleSize;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final int? maxLength;
  final double? height;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;
  final Widget? prefix;
  final EdgeInsetsGeometry? contentPadding;
  final double? labelTextSize;
  final bool? obscureText;
  final bool isRequired;
  final int? maxLines;
  final bool? filled;
  final bool? isDense;
  final Color? filledColor;
  final bool isSpaceAllowed;
  final Color labelTextColor;
  final FontWeight labelFontWeight;
  final double? labelFontSize;
  final double? hintFontSize;
  final Color? hintFontColor;
  final Color? errorFontColor;
  final Key? customKey;
  final List<TextInputFormatter>? inputFormatters;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;

  const LabelTextField({
    super.key,
    this.labelText,
    required this.textInputType,
    this.textInputAction = TextInputAction.done,
    this.labelStyle,
    this.onFieldSubmitted,
    this.hintText,
    this.errorText,
    this.validator,
    this.textController,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.focusNode,

    this.borderRadius = 8,

    this.labelTextVisible = true,
    this.labelTextVisibleSize = true,
    this.hintStyle,
    this.style,
    this.toolTipMsg,
    this.height,
    this.maxLength,
    this.readOnly = false,
    this.isDense = false,
    this.isRequired = false,
    this.toolTipVisible = false,
    this.autovalidateMode,
    this.prefix,
    this.contentPadding,
    this.labelTextSize,
    this.obscureText = false,
    this.maxLines = 1,
    this.filled = true,
    this.filledColor = ColorConst.color091B2C,
    this.isSpaceAllowed = true,
    this.labelTextColor = ColorConst.colorDCDCDC87,
    this.labelFontWeight = FontWeight.w500,

    this.labelFontSize = 14,
    this.hintFontSize,
    this.hintFontColor,
    this.errorFontColor,
    this.customKey,
    this.inputFormatters,
    this.suffixIconConstraints,
    this.prefixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelTextVisible
              ? Visibility(
                  visible: labelTextVisible,
                  maintainSize: labelTextVisibleSize,
                  maintainAnimation: labelTextVisibleSize,
                  maintainState: labelTextVisibleSize,
                  child: Row(
                    children: [
                      ThemeText(
                        text: labelText ?? '',
                        style: labelStyle,
                        fontSize: labelFontSize ?? 14,
                        textColor: labelTextColor,
                        fontWeight: labelFontWeight,
                      ),
                      if (isRequired)
                        ThemeText(
                          text: '*',
                          style: labelStyle,
                          fontSize: labelFontSize ?? 14,
                          textColor: labelTextColor,
                          fontWeight: labelFontWeight,
                        ),
                    ],
                  ),
                )
              : SizedBox(),
          labelTextVisible ? addSpacing(height ?? 10) : SizedBox(),
          TextFormField(
            key: customKey,

            obscureText: obscureText ?? false,
            onTapOutside: (PointerDownEvent event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            obscuringCharacter: '•',
            cursorColor: ColorConst.color5AD1D3,
            cursorHeight: 18.sp,
            inputFormatters:
                inputFormatters ??
                (isSpaceAllowed
                    ? null
                    : [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
            autocorrect: false,
            enableSuggestions: false,
            readOnly: readOnly,
            maxLength: maxLength,
            maxLines: maxLines,
            autovalidateMode:
                autovalidateMode ?? AutovalidateMode.onUserInteraction,
            onFieldSubmitted: onFieldSubmitted,
            focusNode: focusNode,
            controller: textController,
            keyboardType: textInputType,
            textInputAction: textInputAction,
            style:
                style ??
                TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                  color: ColorConst.white,
                ),
            decoration: InputDecoration(
              filled: filled,
              isDense: isDense,
              fillColor: filledColor ?? ColorConst.black,
              // filledColor ?? ColorsConst.colorFAFAFA.withOpacity(0.1),
              errorMaxLines: 3,
              contentPadding:
                  contentPadding ?? EdgeInsets.symmetric(vertical: 12.sp),
              counterText: '',
              prefix: prefix,
              prefixIconConstraints:
                  prefixIconConstraints ??
                  BoxConstraints(
                    minHeight: 25.h,
                    maxWidth: 35.w,
                    maxHeight: 25.h,
                    minWidth: 30.w,
                  ),
              prefixIcon: prefixIcon?.applyPaddingOnly(left: 10.sp),
              suffixIcon: suffixIcon?.applyPaddingOnly(right: 14.sp),
              suffixIconConstraints:
                  suffixIconConstraints ??
                  BoxConstraints(
                    minHeight: 25.h,
                    maxWidth: 30.w,
                    maxHeight: 25.h,
                    minWidth: 30.w,
                  ),
              border: GradientOutlineInputBorder(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorConst.white, // #FFFFFF
                    ColorConst.colorFFFFFF13, // rgba(255,255,255,0.13)
                  ],
                  stops: [0.2, 0.4], // 73.4% , 95.25%
                  transform: GradientRotation(99 * 3.1416 / 80), // rotate 99deg
                ),
                width: 1,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              enabledBorder: GradientOutlineInputBorder(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorConst.white, // #FFFFFF
                    ColorConst.colorFFFFFF13, // rgba(255,255,255,0.13)
                  ],
                  stops: [0.2, 0.4], // 73.4% , 95.25%
                  transform: GradientRotation(99 * 3.1416 / 80), // rotate 99deg
                ),
                width: 1,
                borderRadius: BorderRadius.circular(borderRadius),
              ),

              focusedBorder: GradientOutlineInputBorder(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorConst.color5AD1D3, // rgba(255,255,255,0.13)
                    ColorConst.colorFFFFFF13, // rgba(255,255,255,0.13)
                  ],
                  stops: [0.2, 0.4], // 73.4% , 95.25%
                  transform: GradientRotation(99 * 3.1416 / 80), // rotate 99deg
                ),
                width: 1,
                borderRadius: BorderRadius.circular(borderRadius),
              ),

              hoverColor: ColorConst.black,
              hintStyle: TextStyle(
                fontSize: hintFontSize ?? 14.sp,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
                color: hintFontColor ?? ColorConst.colorDCDCDC38,
                height: 1.0,
                // line-height: 100%
                letterSpacing: 0, // letter-spacing: 0%
              ),
              hintText: hintText,
              errorText: errorText,
              errorStyle: TextStyle(
                color: errorFontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            validator: validator,
            onChanged: onChanged,
            onSaved: onSaved,
            onTap: onTap,
          ),
          labelTextVisible ? addSpacing(height ?? 4) : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget addSpacing(double? height) {
    return labelText?.isNotEmpty ?? false
        ? SizedBox(height: height ?? 10.h)
        : const SizedBox.shrink();
  }
}

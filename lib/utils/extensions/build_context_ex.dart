import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/export.dart';

extension BuildContextEx on BuildContext {
  ColorScheme get colorScheme => theme.colorScheme;

  ScaffoldMessengerState get _scaffoldMessengerState {
    return ScaffoldMessenger.of(this);
  }

  double bottomPadding([double padding = 0]) {
    return mediaQuery.padding.bottom + padding;
  }

  void showSnackBar({
    required SnackBarType type,
    required String message,
    VoidCallback? onInit,
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    SnackBar snackBar = SnackBar(
      content: Row(
        children: [
          Icon(type.icon, color: type.color),
          const SizedBox(width: 10),
          ThemeText(text: message, fontSize: 13, textColor: textColor ?? ColorConst.white).applyExpanded(),
          // Text(
          //   message,
          //   style: textTheme.titleSmall?.copyWith(
          //     fontSize: 13,
          //     color: colorScheme.onSecondary,
          //   ),
          // ).applyExpanded(),
        ],
      ),
      elevation: 0,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      backgroundColor: backgroundColor ?? ColorConst.color000000,
    );

    _scaffoldMessengerState.clearSnackBars();
    _scaffoldMessengerState.showSnackBar(snackBar);
    if (onInit != null) onInit();
  }
}

enum SnackBarType { success, info, fail }

extension SnackBarTypeEx on SnackBarType {
  IconData get icon {
    return switch (this) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.fail => Icons.cancel,
      SnackBarType.info => Icons.warning_rounded,
    };
  }

  Color get color {
    return switch (this) {
      SnackBarType.success => Colors.green,
      SnackBarType.fail => Colors.red,
      SnackBarType.info => Colors.amber,
    };
  }
}

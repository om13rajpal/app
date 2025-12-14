import 'package:flutter/material.dart';

import '../constants/global_variable.dart';

extension WidgetEx on Widget {
  Widget applyAlign(
    Alignment alignment, {
    bool animated = false,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (animated) {
      return AnimatedAlign(
        alignment: alignment,
        duration: duration,
        child: this,
      );
    } else {
      return Align(alignment: alignment, child: this);
    }
  }

  PreferredSize applyPreferredSize({required Size preferredSize}) {
    return PreferredSize(preferredSize: preferredSize, child: this);
  }

  Widget toCenter() => Center(child: this);

  Widget applySafeArea({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
  }) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: this,
    );
  }

  Widget applyExpanded({bool expanded = true, int flex = 1}) {
    return expanded ? Expanded(flex: flex, child: this) : this;
  }

  Widget applyPaddingAll([double? value]) {
    return Padding(
      padding: EdgeInsets.all(value ?? kDefaultPaddingValue),
      child: this,
    );
  }

  Widget applyPaddingOnly({
    double? top,
    double? bottom,
    double? right,
    double? left,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top ?? 0,
        bottom: bottom ?? 0,
        left: left ?? 0,
        right: right ?? 0,
      ),
      child: this,
    );
  }

  Widget applyPaddingHorizontal([double? horizontal]) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ?? kDefaultPaddingValue,
      ),
      child: this,
    );
  }

  Widget applyPaddingVertical([double? vertical]) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: vertical ?? kDefaultPaddingValue,
      ),
      child: this,
    );
  }

  Widget onRefresh(RefreshCallback onRefresh) {
    return RefreshIndicator(onRefresh: onRefresh, child: this);
  }
}

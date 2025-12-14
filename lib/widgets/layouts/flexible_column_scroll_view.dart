import 'package:flutter/material.dart';
import 'package:aiSeaSafe/widgets/layouts/layouts.dart';

class FlexibleColumnScrollView extends SafeAreaStatelessWidget {
  final EdgeInsets? padding;
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const FlexibleColumnScrollView({
    super.key,
    this.padding,
    required this.children,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0.0,
  }) : super(top: false, bottom: false, left: false, right: false);

  const FlexibleColumnScrollView.withSafeArea({
    super.key,
    this.padding,
    required this.children,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0.0,
    super.top = true,
    super.bottom = true,
    super.left = true,
    super.right = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = CustomScrollView(
      reverse: false,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Column(
              mainAxisSize: mainAxisSize,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              spacing: spacing,
              children: children,
            ),
          ),
        ),
      ],
    );
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}

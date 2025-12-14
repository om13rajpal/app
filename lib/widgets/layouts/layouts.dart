import 'package:flutter/material.dart';

abstract class SafeAreaStatelessWidget extends StatelessWidget {
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const SafeAreaStatelessWidget({
    super.key,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });
}

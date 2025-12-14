import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants/export_const.dart';

class CommonShimmerImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final String? placeholder;
  final double? borderRadius;
  final Widget? errorWidget;
  final BoxFit? boxFit;

  const CommonShimmerImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.placeholder,
    this.borderRadius,
    this.errorWidget,
    this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 100),
      child: FancyShimmerImage(
        height: height ?? Get.height,
        width: width ?? Get.width,
        boxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 100),
        ),
        boxFit: boxFit ?? BoxFit.cover,
        imageUrl: imageUrl!,
        errorWidget: errorWidget ??
            Image.asset(
              placeholder ?? ImageConst.userPlaceHolder,
              fit: BoxFit.cover,
              height: height,
              width: width,
            ),
      ),
    );
  }
}

// Flutter imports:
import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool titleCenter;
  final Color backGroundColor;
  final Color? iconColor;
  final bool isBack;
  final bool isArrowBackIos;
  final bool? custom;
  final Function()? onBackCall;
  final double appBarHeight;
  final List<Widget>? actions;
  final double? elevation;
  final double? titleSpacing;
  final double? leadingWidth;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleSpacing,
    this.titleCenter = false,
    this.backGroundColor = ColorConst.color07141F,
    this.iconColor,
    this.isBack = false,
    this.isArrowBackIos = true,
    this.onBackCall,
    this.appBarHeight = 35,
    this.actions,
    this.elevation = 0,
    this.leadingWidth,
    this.custom = false,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: ColorConst.white, // Navigation bar
          statusBarColor: ColorConst.white, // Status bar
        ),
        scrolledUnderElevation: 0,
        leadingWidth: leadingWidth,
        automaticallyImplyLeading: false,
        titleSpacing: titleSpacing,
        elevation: elevation,
        title: title ?? ThemeText(text: 'AiSeaSafe', fontSize: 16),
        centerTitle: titleCenter,
        backgroundColor: backGroundColor,
        leading: isBack
            ? IconButton(
                splashRadius: 21,
                padding: const EdgeInsets.all(0.0),
                onPressed: () {
                  if (onBackCall != null) {
                    onBackCall!.call();
                  } else {
                    Get.back();
                  }
                },
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    IconsaxPlusLinear.arrow_left,
                    size: 22,
                    color: iconColor ?? ColorConst.white,
                  ),
                ),
              )
            : null,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

import 'dart:io';

import 'package:aiSeaSafe/data/models/media_info_model.dart';
import 'package:aiSeaSafe/services/permission_handler.dart';
import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:aiSeaSafe/utils/constants/enums/app_enums.dart';
import 'package:aiSeaSafe/utils/constants/global_variable.dart';
import 'package:aiSeaSafe/utils/extensions/build_context_ex.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:aiSeaSafe/utils/helper/file_provider.dart';
import 'package:aiSeaSafe/widgets/theme_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/helper/sized_box.dart' hide SizedBoxH25;

class FilePickerOptionSheet extends StatefulWidget {
  const FilePickerOptionSheet({super.key, this.types = FilePickType.values, required this.isVertical, this.deleteOnTap});

  final List<FilePickType> types;
  final bool isVertical;
  final void Function()? deleteOnTap;

  @override
  State<FilePickerOptionSheet> createState() => _FilePickerOptionSheetState();
}

class _FilePickerOptionSheetState extends State<FilePickerOptionSheet> {
  static final PermissionService permissionService = PermissionHandlerService();

  Future<void> _onTap(FilePickType type) async {
    File? file;
    MediaType? mediaType;

    switch (type) {
      case FilePickType.photos:
        final result = await permissionService.checkPermissionStatus(Platform.isIOS ? Permission.photos : Permission.storage, context);
        if (result) {
          file = await FileProvider.pickImage(ImageSource.gallery);

          mediaType = MediaType.image;
        }

        break;
      case FilePickType.videos:
        file = await FileProvider.pickVideo(ImageSource.gallery);
        mediaType = MediaType.video;

        break;
      case FilePickType.camera:
        final result = await permissionService.checkPermissionStatus(Permission.camera, context);
        if (result) {
          file = await FileProvider.pickImage(ImageSource.camera);
          mediaType = MediaType.image;
        }

        break;
    }

    if (file != null) {
      Uint8List? bytes;
      if (mediaType == MediaType.video) {}
      Navigator.pop(context, MediaInfo(type: mediaType, url: file.path, bytes: bytes));
    } else {}
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...widget.types.map((e) {
                return sheetOption(
                  context: context,
                  title: e.displayName,
                  onTap: () => _onTap(e),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(e.name == 'photos' ? kDefaultVPadding : 0),
                    bottomRight: Radius.circular(e.name == 'photos' ? kDefaultVPadding : 0),
                    topLeft: Radius.circular(e.name != 'photos' ? kDefaultVPadding : 0),
                    topRight: Radius.circular(e.name != 'photos' ? kDefaultVPadding : 0),
                  ),
                );
              }),
              SizedBoxH10(),
              sheetOption(context: context, title: "Cancel", onTap: () {}, borderRadius: BorderRadius.circular(kDefaultVPadding), isCancel: true),
            ],
          ).applyPaddingOnly(bottom: context.bottomPadding())
        : Container(
            decoration: BoxDecoration(color: ColorConst.color091B2C, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.close, color: ColorConst.white).applyAlign(Alignment.topRight),
                ),
                // ThemeText(
                //   text: StringConst.changeProfilePicture,
                //   fontSize: 18,
                //   fontWeight: FontWeight.w500,textColor: ColorConst.black,
                // ).applyAlign(Alignment.centerLeft),
                SizedBoxH10(),
                Column(
                  spacing: 20.sp,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.types.map((e) {
                      return GestureDetector(
                        onTap: () => _onTap(e),
                        child: Row(
                          spacing: 16.sp,
                          children: [
                            e.icon,
                            ThemeText(text: e.displayName, fontWeight: FontWeight.w600, fontSize: 14, textColor: ColorConst.white),
                          ],
                        ),
                      );
                    }).toList(),
                    // Visibility(
                    //   visible: widget.selectedImage.value.isNotEmpty,
                    //   child: GestureDetector(
                    //     onTap: widget.deleteOnTap,
                    //     child: Row(
                    //       spacing: 16.sp,
                    //       children: [
                    //         SvgPicture.asset(ImageConst.delete),
                    //         ThemeText(
                    //           text: StringConst.delete,
                    //           fontWeight: FontWeight.w600,
                    //           fontSize: 14,
                    //           textColor: ColorConst.t1,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ).applyPaddingAll(),
          ).applyAlign(Alignment.center);
  }
}

Widget sheetOption({required BuildContext context, required String title, required VoidCallback onTap, required BorderRadiusGeometry borderRadius, bool isCancel = false}) {
  return CupertinoButton(
    padding: EdgeInsets.zero,
    pressedOpacity: 0.95,
    onPressed: () {
      // Get.back();
      onTap();
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        border: isCancel ? null : Border(bottom: BorderSide(color: ColorConst.colorCDCDCC, width: 0.5)),
      ),
      alignment: Alignment.center,
      child: ThemeText(text: title, fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}

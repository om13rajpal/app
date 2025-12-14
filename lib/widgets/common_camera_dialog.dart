import 'dart:io';

import 'package:aiSeaSafe/data/models/media_info_model.dart';
import 'package:aiSeaSafe/utils/constants/enums/app_enums.dart';
import 'package:aiSeaSafe/utils/extensions/build_context_ex.dart';
import 'package:aiSeaSafe/utils/helper/bottom_sheet.dart';
import 'package:aiSeaSafe/widgets/theme/file_picker_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants/export_const.dart';

class MediaPickerUtils {
  static Future<String?> pickImage({required BuildContext context, double maxSizeInMB = 10, bool showSnackBarOnFail = true}) async {
    MediaInfo? info = await BottomSheetAlert<MediaInfo>().displayBottomSheetAlert(
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      child: FilePickerOptionSheet(types: [FilePickType.photos, FilePickType.camera], isVertical: false),
    );

    if (info?.url == null) return null;

    File image = File(info!.url!);
    int fileSizeInBytes = await image.length();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB > maxSizeInMB) {
      if (showSnackBarOnFail) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.context?.showSnackBar(type: SnackBarType.info, message: StringConst.imagesOver10MB);
        });
      }
      return null;
    }

    return image.path;
  }
}

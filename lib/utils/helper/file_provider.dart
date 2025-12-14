import 'dart:io';

import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:aiSeaSafe/utils/extensions/build_context_ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

export 'package:image_picker/image_picker.dart' show ImageSource, CameraDevice;

class FileProvider {
  const FileProvider._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(ImageSource source, {CameraDevice preferredCameraDevice = CameraDevice.rear}) async {
    XFile? xFile = await _picker.pickImage(source: source, preferredCameraDevice: preferredCameraDevice);
    if (xFile != null) {
      final croppedImage = await cropImage(File(xFile.path));
      if (croppedImage != null) return croppedImage;
      return File(xFile.path);
    }

    return null;
  }

  static Future<File?> pickVideo(ImageSource source, {CameraDevice preferredCameraDevice = CameraDevice.rear}) async {
    XFile? xFile = await _picker.pickVideo(source: source, preferredCameraDevice: preferredCameraDevice);

    if (xFile != null) return File(xFile.path);

    return null;
  }

  static void handleException(BuildContext context, PlatformException e) {
    if (e.code == 'camera_access_denied') {
      context.showSnackBar(
        type: SnackBarType.info,
        message: 'Camera access permission denied. Go to Setting and enabled it.',
        action: SnackBarAction(label: 'Settings', onPressed: () {}),
      );
    } else {
      context.showSnackBar(type: SnackBarType.fail, message: e.code);
    }
  }

  static Future<File?> cropImage(File image) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      // aspectRatioPresets: [
      //   CropAspectRatioPreset.square,
      //   CropAspectRatioPreset.ratio3x2,
      //   CropAspectRatioPreset.original,
      //   CropAspectRatioPreset.ratio4x3,
      //   CropAspectRatioPreset.ratio16x9
      // ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.white,
          showCropGrid: true,
          toolbarWidgetColor: ColorConst.primary,
          backgroundColor: Colors.transparent,
          initAspectRatio: CropAspectRatioPreset.original,
          statusBarColor: Colors.white,
          lockAspectRatio: false,activeControlsWidgetColor: ColorConst.primary,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
    if (cropped == null) {
      return null;
    }
    return File(cropped.path);
  }
}

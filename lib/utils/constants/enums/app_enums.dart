import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/export.dart';

enum Environment { dev, qa, staging, production, local }

enum Version { v1, v2, v3, v4, v5 }

enum PasswordType { password, oldPassword, newPassword, confirmPassword }

enum FilePickType {
  photos,
  videos,
  camera;

  Widget get icon {
    switch (this) {
      case FilePickType.photos:
        return SvgPicture.asset(ImageConst.gallerySvg, colorFilter: ColorFilter.mode(ColorConst.white, BlendMode.srcIn));
      case FilePickType.videos:
        return SvgPicture.asset(ImageConst.gallerySvg, colorFilter: ColorFilter.mode(ColorConst.white, BlendMode.srcIn));
      case FilePickType.camera:
        return SvgPicture.asset(ImageConst.camera, colorFilter: ColorFilter.mode(ColorConst.white, BlendMode.srcIn));
    }
  }

  String get displayName {
    switch (this) {
      case FilePickType.photos:
        return StringConst.chooseFromGallery;
      case FilePickType.videos:
        return StringConst.chooseFromGallery;
      case FilePickType.camera:
        return StringConst.takePhoto;
    }
  }
}

enum CameraCaptureType {
  photos,
  videos,
  camera;

  Widget get icon {
    switch (this) {
      case CameraCaptureType.photos:
        return SvgPicture.asset(ImageConst.gallerySvg);
      case CameraCaptureType.videos:
        return SvgPicture.asset(ImageConst.gallerySvg);
      case CameraCaptureType.camera:
        return SvgPicture.asset(ImageConst.camera);
    }
  }

  String get displayName {
    switch (this) {
      case CameraCaptureType.photos:
        return StringConst.chooseFromGallery;
      case CameraCaptureType.videos:
        return StringConst.chooseFromGallery;
      case CameraCaptureType.camera:
        return StringConst.takePhoto;
    }
  }
}

enum MediaType {
  image('image/jpeg'),
  video('video/mp4');

  final String contentType;

  const MediaType(this.contentType);

  static MediaType? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

enum FontFamily { poppins, montserrat }

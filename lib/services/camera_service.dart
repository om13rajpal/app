import 'dart:io';

import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class CameraPermissionService {
  Future<PermissionStatus> requestPhotosPermission();
  Future<bool> handlePhotosPermission(BuildContext context);
  Future<PermissionStatus> requestCameraPermission();
  Future<bool> handleCameraPermission(BuildContext context);
}

class PermissionHandlerService implements CameraPermissionService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Requests camera permission
  @override
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Requests photos/storage permission
  @override
  Future<PermissionStatus> requestPhotosPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ uses scoped media permissions
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        // If any permission granted, return granted
        return statuses.values.any((s) => s == PermissionStatus.granted)
            ? PermissionStatus.granted
            : PermissionStatus.denied;
      } else {
        // Android <= 12 uses storage permission
        return await Permission.storage.request();
      }
    } else {
      // iOS
      return await Permission.photos.request();
    }
  }

  /// Handles camera permission with dialog if denied
  @override
  Future<bool> handleCameraPermission(BuildContext context) async {
    final status = await requestCameraPermission();

    if (status != PermissionStatus.granted) {
      await _showPermissionDialog(
        context,
        StringConst.cameraPermission,
        StringConst.cameraDescription,
      );
      return false;
    }

    return true;
  }

  /// Handles photos permission with dialog if denied or permanently denied
  @override
  Future<bool> handlePhotosPermission(BuildContext context) async {
    final status = await requestPhotosPermission();

    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      await _showPermissionDialog(
        context,
        StringConst.photoPermission,
        StringConst.photoDescription,
      );
      return false;
    }

    return true;
  }

  /// Show a reusable Cupertino alert
  Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String subtitle,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          CupertinoDialogAction(
            textStyle: const TextStyle(color: Colors.red, fontSize: 16),
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            textStyle: const TextStyle(color: Colors.blue, fontSize: 16),
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }
}

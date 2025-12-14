// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

abstract class PermissionService {
  Future<bool> requestPermission(Permission permission, BuildContext context);
  Future<bool> checkPermissionStatus(
      Permission permission, BuildContext context);
}

class PermissionHandlerService implements PermissionService {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  // A generic method to request any permission
  @override
  Future<bool> requestPermission(
      Permission permission, BuildContext context) async {
    // Determine SDK version for conditional permissions
    bool isSdkAbove33 = await _isSdkAbove33();

    // If the permission is related to storage/photos, handle accordingly
    if (permission == Permission.storage ||
        permission == Permission.photosAddOnly) {
      if (isSdkAbove33) {
        return await _requestStoragePermissionAndroid(context);
      }
    }

    PermissionStatus status = await permission.request();
    return await _handlePermissionStatus(status, context, permission);
  }

  // Check if permission is granted or denied
  @override
  Future<bool> checkPermissionStatus(
      Permission permission, BuildContext context) async {
    PermissionStatus status = await permission.status;
    return await _handlePermissionStatus(status, context, permission);
  }

  // Centralized handler for all permission statuses
  Future<bool> _handlePermissionStatus(PermissionStatus status,
      BuildContext context, Permission permission) async {
    if (status == PermissionStatus.denied) {
      // Request permission if denied
      return await requestPermission(permission, context);
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Show settings dialog if permanently denied
      await _showPermissionDialog(
        context,
        "Permission Needed",
        "We need this permission to proceed.",
        () => openAppSettings(),
      );
      return false;
    } else if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  // Show a generic dialog for any permission request
  Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String description,
    Function onConfirm,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AppAlertDialog(
        onConfirm: () {
          Get.back();
          onConfirm();
        },
        title: title,
        subtitle: description,
      ),
    );
  }

  // Check if the device's SDK version is above 33 (Android-specific)
  Future<bool> _isSdkAbove33() async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return androidInfo.version.sdkInt > 33;
    }
    return false;
  }

  // Request storage permission conditionally based on SDK version
  Future<bool> _requestStoragePermissionAndroid(BuildContext context) async {
    PermissionStatus status;
    final isSdkAbove33 = await _isSdkAbove33();
    if (isSdkAbove33) {
      // For SDK > 33, storage permission is handled differently
      status = await Permission.storage.request();
    } else {
      // For lower SDK, photos permission might be needed
      status = await Permission.photosAddOnly.request();
    }

    return await _handlePermissionStatus(status, context, Permission.storage);
  }
}

class AppAlertDialog extends StatelessWidget {
  final Function onConfirm;
  final String title;
  final String subtitle;
  final bool isCancel;

  const AppAlertDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.subtitle,
    this.isCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        if (isCancel)
          CupertinoDialogAction(
            textStyle: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        CupertinoDialogAction(
          onPressed: () => onConfirm(),
          textStyle: TextStyle(
            color: Colors.blue,
            fontSize: 16,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class PermissionHelper {
  final PermissionService permissionService;

  PermissionHelper(this.permissionService);

  // A helper method that wraps the process of requesting and checking a permission
  Future<bool> requestAndHandlePermission(
      Permission permission, BuildContext context) async {
    bool hasPermission =
        await permissionService.checkPermissionStatus(permission, context);
    if (!hasPermission) {
      await permissionService.requestPermission(permission, context);
      return false;
    }
    return true;
  }
}

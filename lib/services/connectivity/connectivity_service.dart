import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'connectivity_widget.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isDeviceConnected = false;
  bool _isDialogOpen = false;

  /// This method is used to initialize connectivity checks and listen for network changes.
  Future<void> initialize() async {
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen(
      (event) {
        _onConnectivityChanged();
      },
    );
  }

  /// This method checks the initial network connection state and acts accordingly.
  Future<void> _checkInitialConnection() async {
    _isDeviceConnected = await InternetConnection().hasInternetAccess;
    if (!_isDeviceConnected) {
      _showNetworkErrorDialog();
    } else {
      _navigateToNextScreen();
    }
  }

  /// This method is called whenever there is a change in the network connectivity.
  void _onConnectivityChanged() async {
    bool previousConnectionStatus = _isDeviceConnected;
    _isDeviceConnected = await InternetConnection().hasInternetAccess;

    if (!_isDeviceConnected && previousConnectionStatus) {
      _showNetworkErrorDialog();
    } else if (_isDeviceConnected && !previousConnectionStatus) {
      _closeNetworkErrorDialog();
      _navigateToNextScreen();
    }
  }

  /// This method shows the network error dialog if no internet is found.
  void _showNetworkErrorDialog() {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    Get.generalDialog(
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ConnectivityScreen();
      },
    );
  }

  /// This method closes the network error dialog if there is internet access.
  void _closeNetworkErrorDialog() {
    if (!_isDialogOpen) return;
    _isDialogOpen = false;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// This method navigates the user to the appropriate screen based on connectivity status.
  void _navigateToNextScreen() {
    if (!_isDeviceConnected) return;

    Future.delayed(const Duration(milliseconds: 2500), () {
      // if (preferences.isLogged == true) {
      //   Get.offNamed(A.appDashboardScreen);
      // } else {
      //   Get.offNamed(AppRoutes.onboardingScreen);
      // }
      //Set according app logic
    });
  }

  /// This method disposes of the subscription to prevent memory leaks.
  void dispose() {
    _subscription.cancel();
  }
}

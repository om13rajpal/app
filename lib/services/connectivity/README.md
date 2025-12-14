# Connectivity Service

This folder contains functionality to manage connectivity-related features in a Flutter application. It ensures that the app can detect and respond to changes in network connectivity across different platforms.

## Permissions Required

### Android

- **Access Network State**:  
   Add the following permission to the `AndroidManifest.xml` file:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  ```

### iOS

- No specific permissions are required for basic connectivity checks. However, ensure the app's `Info.plist` includes the following keys if you are making network requests:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
          <key>NSAllowsArbitraryLoads</key>
          <true/>
  </dict>
  ```

## How It Works

1. **Detecting Connectivity**:  
    The service uses the `connectivity_plus` package to monitor network status changes. It can detect whether the device is connected to Wi-Fi, mobile data, or is offline.

2. **Platform-Specific Implementation**:  
    The `connectivity_plus` package abstracts platform-specific implementations, ensuring a unified API for all platforms.

3. **Usage**:  
    Import the service and listen for connectivity changes:

   ```dart
   import 'package:connectivity_plus/connectivity_plus.dart';

   final Connectivity _connectivity = Connectivity();

   void checkConnectivity() async {
       var result = await _connectivity.checkConnectivity();
       if (result == ConnectivityResult.mobile) {
           print('Connected to Mobile Network');
       } else if (result == ConnectivityResult.wifi) {
           print('Connected to Wi-Fi');
       } else {
           print('No Network Connection');
       }
   }
   ```

4. **Error Handling**:  
    Always handle scenarios where the connectivity status might be unavailable or inconsistent.

5. **Permission Management Across Platforms**:  
    Each platform has its own requirements for managing connectivity permissions:
   - On **Android**, ensure the `ACCESS_NETWORK_STATE` permission is declared in the `AndroidManifest.xml`.
   - On **iOS** and **macOS**, verify that the `NSAppTransportSecurity` key is configured in the `Info.plist` file for network requests.
   - For **Web** and **Windows**, no additional permissions are required, but ensure the app has proper internet access.

For more details, refer to the [connectivity_plus documentation](https://pub.dev/packages/connectivity_plus).

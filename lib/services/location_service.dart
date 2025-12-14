import 'package:aiSeaSafe/services/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:aiSeaSafe/utils/helper/log_helper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/location_result.dart' hide Location;

class LocationService {
  LocationService._();

  static Future<LocationResult> getCurrentLocation({
    required BuildContext context,
  }) async {
    LocationResult result = const LocationResult(
      status: false,
      latitude: 0.0,
      longitude: 0.0,
    );
    bool permissionGranted = await PermissionHandlerService()
        .checkPermissionStatus(Permission.location, context);
    bool isLocationEnabled = await checkLocationEnabled();
    if (permissionGranted && isLocationEnabled) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
        );
        result = result.copyWith(
          status: true,
          message: 'Location service is enabled and permission is granted.',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        result = result.copyWith(status: false, message: e.toString());
      }
    }

    return result;
  }

  static Future<Placemark?> getPlacemark(LatLng latLng) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placeMarks.isNotEmpty) {
        return placeMarks.first;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Address getAddress(Placemark? placemark) {
    return Address(
      city: placemark?.locality,
      stateCode: placemark?.administrativeArea,
      subLocality: placemark?.subLocality,
      country: placemark?.country,
      isoCountryCode: placemark?.isoCountryCode,
    );
  }

  static Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Address?> getAddressFromLatLong(LatLng latLng) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placeMarks.isNotEmpty) {
        Address address = getAddress(placeMarks.first);

        return address;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position?> getCurrentPosition({
    required BuildContext context,
  }) async {
    Position? position;
    bool permissionGranted = await PermissionHandlerService()
        .checkPermissionStatus(Permission.location, context);

    if (permissionGranted) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
        );
      } catch (e) {
        LoggerHelper.logError('Cannot Get Current Position', e.toString());
        return null;
      }
    }

    return position;
  }
}

/*
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
add in AndroidManifest.xml

<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is needed for getting your current location.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Your location is needed for getting your current location at all times.</string>
<key>NSLocationUsageDescription</key>
<string>Your location is needed for getting your current location.</string>
add in Info.plist`
 */

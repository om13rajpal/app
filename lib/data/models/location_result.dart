import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/location_service.dart';

class LocationResult {
  final bool status;
  final String? message;
  final double latitude;
  final double longitude;

  const LocationResult({
    required this.status,
    this.message,
    required this.latitude,
    required this.longitude,
  });

  LocationResult copyWith({
    bool? status,
    String? message,
    double? latitude,
    double? longitude,
  }) {
    return LocationResult(
      status: status ?? this.status,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
  Future<Address?> getAddress() async {
    Placemark? placemark = await LocationService.getPlacemark(latLng);
    return LocationService.getAddress(placemark);
  }

  @override
  String toString() {
    return 'LocationResult(status: $status, message: $message, latitude: $latitude, longitude: $longitude)';
  }
}

class Location {
  final Address? address;
  final double? latitude;
  final double? longitude;

  const Location({
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      address: map['address'] != null
          ? Address.fromMap(map['address'])
          : map['address'],
      latitude: JsonUtils.parseToNum(map['latitude'])?.toDouble(),
      longitude: JsonUtils.parseToNum(map['longitude'])?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address?.toMap(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Address {
  final String? city;
  final String? stateCode;
  final String? country;
  final String? isoCountryCode;
  final String? subLocality;

  const Address({
    this.city,
    this.stateCode,
    this.country,
    this.isoCountryCode,
    this.subLocality,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      city: map['city'],
      stateCode: map['state_code'],
      country: map['country'],
      isoCountryCode: map['iso_country_code'],
      subLocality: map['sub_locality'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'state_code': stateCode,
      'country': country,
      'iso_country_code': isoCountryCode,
      'sub_locality': subLocality,
    };
  }

  @override
  String toString() {
    List<String> addressStr = [];
    // if (subLocality != null && subLocality != '') addressStr.add(subLocality!);
    // if (city != null && city != '') addressStr.add(city!);

    if (stateCode != null && stateCode != '') addressStr.add(stateCode!);
    if (country != null && country != '') addressStr.add(country!);

    return addressStr.join(', ');
  }
}

class JsonUtils {
  const JsonUtils._();

  static num? parseToNum(dynamic value) {
    if (value == null) return 0;
    if (value is String) return num.tryParse(value);
    if (value is num) return value;
    return null;
  }
}

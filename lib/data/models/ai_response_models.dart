/// AI Response Models for AiSeaSafe
///
/// This file contains all the response models for different types
/// of AI assistant responses: weather, local assistance, trip/route, and normal.
///
/// These models match the JSON structure defined in the API specification.
library;

import 'dart:convert';

// =============================================================================
// ENUMS
// =============================================================================

/// Types of AI responses
enum AIResponseType {
  weather('weather'),
  assistance('assistance'),
  route('route'),
  normal('normal');

  final String value;
  const AIResponseType(this.value);

  static AIResponseType fromString(String value) {
    return AIResponseType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AIResponseType.normal,
    );
  }
}

/// Risk levels for weather and route assessments
enum RiskLevel {
  low('low'),
  moderate('moderate'),
  high('high'),
  extreme('extreme');

  final String value;
  const RiskLevel(this.value);

  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => RiskLevel.moderate,
    );
  }
}

/// Trip safety status
enum TripStatus {
  safe('SAFE'),
  caution('CAUTION'),
  unsafe('UNSAFE');

  final String value;
  const TripStatus(this.value);

  static TripStatus fromString(String value) {
    return TripStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => TripStatus.caution,
    );
  }
}

// =============================================================================
// WEATHER MODELS
// =============================================================================

/// Weather report data from AI response
class WeatherReport {
  final String message;
  final String weather;
  final String temperature;
  final String waveHeight;
  final String waveDirection;
  final String windSpeed;
  final String windDirection;
  final String windGusts;
  final String humidity;
  final String pressureSurfaceLevel;
  final String rainIntensity;
  final String cloudCover;
  final String visibility;
  final RiskLevel riskLevel;

  const WeatherReport({
    required this.message,
    required this.weather,
    required this.temperature,
    required this.waveHeight,
    required this.waveDirection,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.humidity,
    required this.pressureSurfaceLevel,
    required this.rainIntensity,
    required this.cloudCover,
    required this.visibility,
    required this.riskLevel,
  });

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    return WeatherReport(
      message: json['message'] as String? ?? '',
      weather: json['weather'] as String? ?? 'Unknown',
      temperature: json['temperature']?.toString() ?? '0',
      waveHeight: json['wave_height']?.toString() ?? '0',
      waveDirection: json['wave_direction']?.toString() ?? '0',
      windSpeed: json['wind_speed']?.toString() ?? '0',
      windDirection: json['wind_direction']?.toString() ?? '0',
      windGusts: json['wind_gusts']?.toString() ?? '0',
      humidity: json['humidity']?.toString() ?? '0',
      pressureSurfaceLevel: json['pressure_surface_level']?.toString() ?? '0',
      rainIntensity: json['rain_intensity']?.toString() ?? '0',
      cloudCover: json['cloud_cover']?.toString() ?? '0',
      visibility: json['visibility']?.toString() ?? '0',
      riskLevel: RiskLevel.fromString(json['risk_level'] as String? ?? 'moderate'),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'weather': weather,
    'temperature': temperature,
    'wave_height': waveHeight,
    'wave_direction': waveDirection,
    'wind_speed': windSpeed,
    'wind_direction': windDirection,
    'wind_gusts': windGusts,
    'humidity': humidity,
    'pressure_surface_level': pressureSurfaceLevel,
    'rain_intensity': rainIntensity,
    'cloud_cover': cloudCover,
    'visibility': visibility,
    'risk_level': riskLevel.value,
  };
}

// =============================================================================
// LOCAL ASSISTANCE MODELS
// =============================================================================

/// Local assistance contact information
class LocalAssistanceContact {
  final String name;
  final String type;
  final String phone;
  final String email;
  final String address;
  final String notes;

  const LocalAssistanceContact({
    required this.name,
    this.type = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
  });

  factory LocalAssistanceContact.fromJson(Map<String, dynamic> json) {
    return LocalAssistanceContact(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'phone': phone,
    'email': email,
    'address': address,
    'notes': notes,
  };
}

// =============================================================================
// TRIP/ROUTE MODELS
// =============================================================================

/// Location with coordinates
class RouteLocation {
  final String name;
  final List<double> coordinates;

  const RouteLocation({
    required this.name,
    required this.coordinates,
  });

  factory RouteLocation.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'];
    List<double> coordList = [];
    if (coords is List) {
      coordList = coords.map((e) => (e as num).toDouble()).toList();
    }
    return RouteLocation(
      name: json['name'] as String? ?? '',
      coordinates: coordList,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'coordinates': coordinates,
  };

  double? get longitude => coordinates.isNotEmpty ? coordinates[0] : null;
  double? get latitude => coordinates.length > 1 ? coordinates[1] : null;
}

/// Route path information
class RoutePath {
  final RouteLocation source;
  final RouteLocation destination;
  final List<List<double>> routePath;
  final double distanceNauticalMiles;
  final double distanceKilometers;
  final int totalWaypoints;

  const RoutePath({
    required this.source,
    required this.destination,
    required this.routePath,
    required this.distanceNauticalMiles,
    required this.distanceKilometers,
    required this.totalWaypoints,
  });

  factory RoutePath.fromJson(Map<String, dynamic> json) {
    final path = json['route_path'] as List<dynamic>?;
    List<List<double>> routePath = [];
    if (path != null) {
      routePath = path.map((e) {
        if (e is List) {
          return e.map((c) => (c as num).toDouble()).toList();
        }
        return <double>[];
      }).toList();
    }

    return RoutePath(
      source: RouteLocation.fromJson(json['source'] as Map<String, dynamic>? ?? {}),
      destination: RouteLocation.fromJson(json['destination'] as Map<String, dynamic>? ?? {}),
      routePath: routePath,
      distanceNauticalMiles: (json['distance_nautical_miles'] as num?)?.toDouble() ?? 0.0,
      distanceKilometers: (json['distance_kilometers'] as num?)?.toDouble() ?? 0.0,
      totalWaypoints: json['total_waypoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'source': source.toJson(),
    'destination': destination.toJson(),
    'route_path': routePath,
    'distance_nautical_miles': distanceNauticalMiles,
    'distance_kilometers': distanceKilometers,
    'total_waypoints': totalWaypoints,
  };
}

/// Weather data for a waypoint
class WaypointWeather {
  final double temperature;
  final double waveHeight;
  final String waveDirection;
  final double windSpeed;
  final String windDirection;
  final double windGusts;
  final int humidity;
  final double pressureSurfaceLevel;
  final double rainIntensity;
  final int cloudCover;
  final double visibility;
  final RiskLevel riskLevel;

  const WaypointWeather({
    this.temperature = 0.0,
    this.waveHeight = 0.0,
    this.waveDirection = '0',
    this.windSpeed = 0.0,
    this.windDirection = '0',
    this.windGusts = 0.0,
    this.humidity = 0,
    this.pressureSurfaceLevel = 0.0,
    this.rainIntensity = 0.0,
    this.cloudCover = 0,
    this.visibility = 0.0,
    this.riskLevel = RiskLevel.low,
  });

  factory WaypointWeather.fromJson(Map<String, dynamic> json) {
    return WaypointWeather(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      waveHeight: (json['wave_height'] as num?)?.toDouble() ?? 0.0,
      waveDirection: json['wave_direction']?.toString() ?? '0',
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: json['wind_direction']?.toString() ?? '0',
      windGusts: (json['wind_gusts'] as num?)?.toDouble() ?? 0.0,
      humidity: json['humidity'] as int? ?? 0,
      pressureSurfaceLevel: (json['pressure_surface_level'] as num?)?.toDouble() ?? 0.0,
      rainIntensity: (json['rain_intensity'] as num?)?.toDouble() ?? 0.0,
      cloudCover: json['cloud_cover'] as int? ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      riskLevel: RiskLevel.fromString(json['risk_level'] as String? ?? 'low'),
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'wave_height': waveHeight,
    'wave_direction': waveDirection,
    'wind_speed': windSpeed,
    'wind_direction': windDirection,
    'wind_gusts': windGusts,
    'humidity': humidity,
    'pressure_surface_level': pressureSurfaceLevel,
    'rain_intensity': rainIntensity,
    'cloud_cover': cloudCover,
    'visibility': visibility,
    'risk_level': riskLevel.value,
  };
}

/// Issue found along the route
class RouteIssue {
  final int waypoint;
  final String problem;
  final String marineCondition;
  final String vesselConcern;
  final double distance;
  final WaypointWeather weather;

  const RouteIssue({
    required this.waypoint,
    required this.problem,
    required this.marineCondition,
    required this.vesselConcern,
    required this.distance,
    required this.weather,
  });

  factory RouteIssue.fromJson(Map<String, dynamic> json) {
    return RouteIssue(
      waypoint: json['waypoint'] as int? ?? 0,
      problem: json['problem'] as String? ?? '',
      marineCondition: json['marine_condition'] as String? ?? '',
      vesselConcern: json['vessel_concern'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      weather: WaypointWeather.fromJson(json['weather'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'waypoint': waypoint,
    'problem': problem,
    'marine_condition': marineCondition,
    'vessel_concern': vesselConcern,
    'distance': distance,
    'weather': weather.toJson(),
  };
}

/// Location weather data (for source/destination)
class LocationWeather {
  final WaypointWeather weather;

  const LocationWeather({required this.weather});

  factory LocationWeather.fromJson(Map<String, dynamic> json) {
    return LocationWeather(
      weather: WaypointWeather.fromJson(json['weather'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'weather': weather.toJson(),
  };
}

/// Trip analysis results
class TripAnalysis {
  final TripStatus status;
  final bool vesselCompatible;
  final String summary;
  final List<RouteIssue> issues;
  final LocationWeather source;
  final LocationWeather destination;
  final String recommendation;

  const TripAnalysis({
    required this.status,
    required this.vesselCompatible,
    required this.summary,
    required this.issues,
    required this.source,
    required this.destination,
    required this.recommendation,
  });

  factory TripAnalysis.fromJson(Map<String, dynamic> json) {
    final issuesList = json['issues'] as List<dynamic>?;
    List<RouteIssue> issues = [];
    if (issuesList != null) {
      issues = issuesList
          .map((e) => RouteIssue.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TripAnalysis(
      status: TripStatus.fromString(json['status'] as String? ?? 'CAUTION'),
      vesselCompatible: json['vessel_compatible'] as bool? ?? true,
      summary: json['summary'] as String? ?? '',
      issues: issues,
      source: LocationWeather.fromJson(json['source'] as Map<String, dynamic>? ?? {}),
      destination: LocationWeather.fromJson(json['destination'] as Map<String, dynamic>? ?? {}),
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.value,
    'vessel_compatible': vesselCompatible,
    'summary': summary,
    'issues': issues.map((e) => e.toJson()).toList(),
    'source': source.toJson(),
    'destination': destination.toJson(),
    'recommendation': recommendation,
  };
}

/// Complete trip plan
class TripPlan {
  final RoutePath route;
  final TripAnalysis tripAnalysis;

  const TripPlan({
    required this.route,
    required this.tripAnalysis,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      route: RoutePath.fromJson(json['route'] as Map<String, dynamic>? ?? {}),
      tripAnalysis: TripAnalysis.fromJson(json['trip_analysis'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'route': route.toJson(),
    'trip_analysis': tripAnalysis.toJson(),
  };
}

// =============================================================================
// MAIN AI RESPONSE MODEL
// =============================================================================

/// Wrapper for the response content
class AIResponseContent {
  final String message;
  final AIResponseType type;

  // Weather-specific fields
  final WeatherReport? report;

  // Local assistance-specific fields
  final List<LocalAssistanceContact>? localAssistance;

  // Trip/route-specific fields
  final TripPlan? tripPlan;
  final String? estimatedTime;
  final bool? startTrip;

  const AIResponseContent({
    required this.message,
    required this.type,
    this.report,
    this.localAssistance,
    this.tripPlan,
    this.estimatedTime,
    this.startTrip,
  });

  factory AIResponseContent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'normal';
    final type = AIResponseType.fromString(typeStr);

    WeatherReport? report;
    List<LocalAssistanceContact>? localAssistance;
    TripPlan? tripPlan;

    switch (type) {
      case AIResponseType.weather:
        if (json['report'] != null) {
          report = WeatherReport.fromJson(json['report'] as Map<String, dynamic>);
        }
        break;
      case AIResponseType.assistance:
        if (json['local_assistance'] != null) {
          final assistanceList = json['local_assistance'] as List<dynamic>;
          localAssistance = assistanceList
              .map((e) => LocalAssistanceContact.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        break;
      case AIResponseType.route:
        if (json['trip_plan'] != null) {
          tripPlan = TripPlan.fromJson(json['trip_plan'] as Map<String, dynamic>);
        }
        break;
      case AIResponseType.normal:
        // No additional parsing needed
        break;
    }

    return AIResponseContent(
      message: json['message'] as String? ?? '',
      type: type,
      report: report,
      localAssistance: localAssistance,
      tripPlan: tripPlan,
      estimatedTime: json['estimated_time'] as String?,
      startTrip: json['start_trip'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'message': message,
      'type': type.value,
    };

    switch (type) {
      case AIResponseType.weather:
        if (report != null) json['report'] = report!.toJson();
        break;
      case AIResponseType.assistance:
        if (localAssistance != null) {
          json['local_assistance'] = localAssistance!.map((e) => e.toJson()).toList();
        }
        break;
      case AIResponseType.route:
        if (tripPlan != null) json['trip_plan'] = tripPlan!.toJson();
        if (estimatedTime != null) json['estimated_time'] = estimatedTime;
        if (startTrip != null) json['start_trip'] = startTrip;
        break;
      case AIResponseType.normal:
        break;
    }

    return json;
  }

  /// Check if this response has structured data
  bool get hasStructuredData {
    switch (type) {
      case AIResponseType.weather:
        return report != null;
      case AIResponseType.assistance:
        return localAssistance != null && localAssistance!.isNotEmpty;
      case AIResponseType.route:
        return tripPlan != null;
      case AIResponseType.normal:
        return false;
    }
  }
}

/// Main AI response wrapper
class AIResponse {
  final AIResponseContent response;
  final AudioData? audio;

  const AIResponse({required this.response, this.audio});

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    AudioData? audioData;
    if (json['audio'] != null) {
      audioData = AudioData.fromJson(json['audio'] as Map<String, dynamic>);
    }

    return AIResponse(
      response: AIResponseContent.fromJson(json['response'] as Map<String, dynamic>? ?? {}),
      audio: audioData,
    );
  }

  factory AIResponse.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return AIResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'response': response.toJson(),
    };
    if (audio != null) {
      map['audio'] = audio!.toJson();
    }
    return map;
  }

  String toJsonString() => jsonEncode(toJson());

  /// Convenience getters
  String get message => response.message;
  AIResponseType get type => response.type;
  WeatherReport? get weatherReport => response.report;
  List<LocalAssistanceContact>? get localAssistance => response.localAssistance;
  TripPlan? get tripPlan => response.tripPlan;
  bool get hasStructuredData => response.hasStructuredData;
  bool get hasAudio => audio?.hasAudio ?? false;
  String? get audioBase64 => audio?.audioBase64;
}

// =============================================================================
// AUDIO DATA MODEL
// =============================================================================

/// Audio data from TTS response
class AudioData {
  final String? audioBase64;
  final String audioFormat;
  final String audioMimeType;
  final String voice;

  const AudioData({
    this.audioBase64,
    this.audioFormat = 'mp3',
    this.audioMimeType = 'audio/mpeg',
    this.voice = 'nova',
  });

  factory AudioData.fromJson(Map<String, dynamic> json) {
    return AudioData(
      audioBase64: json['audio_base64'] as String?,
      audioFormat: json['audio_format'] as String? ?? 'mp3',
      audioMimeType: json['audio_mime_type'] as String? ?? 'audio/mpeg',
      voice: json['voice'] as String? ?? 'nova',
    );
  }

  Map<String, dynamic> toJson() => {
    'audio_base64': audioBase64,
    'audio_format': audioFormat,
    'audio_mime_type': audioMimeType,
    'voice': voice,
  };

  /// Check if audio data is available
  bool get hasAudio => audioBase64 != null && audioBase64!.isNotEmpty;
}

// =============================================================================
// STREAMING RESPONSE MODEL
// =============================================================================

/// Model for handling streaming JSON responses with partial updates
class StreamingAIResponse {
  String _message = '';
  AIResponseType _type = AIResponseType.normal;
  Map<String, dynamic> _partialData = {};

  String get message => _message;
  AIResponseType get type => _type;
  Map<String, dynamic> get partialData => _partialData;

  /// Update from a streaming delta
  void updateFromDelta(Map<String, dynamic> delta) {
    if (delta.containsKey('message')) {
      _message += delta['message'] as String? ?? '';
    }
    if (delta.containsKey('type')) {
      _type = AIResponseType.fromString(delta['type'] as String);
    }

    // Merge partial data
    delta.forEach((key, value) {
      if (key != 'message' && key != 'type') {
        _partialData[key] = value;
      }
    });
  }

  /// Convert to final AIResponse
  AIResponse toAIResponse() {
    final json = {
      'response': {
        'message': _message,
        'type': _type.value,
        ..._partialData,
      }
    };
    return AIResponse.fromJson(json);
  }

  /// Reset for new response
  void reset() {
    _message = '';
    _type = AIResponseType.normal;
    _partialData = {};
  }
}

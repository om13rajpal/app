import 'package:aiSeaSafe/services/loading_controller.dart';
import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:flutter/material.dart';

class VesselDetailController extends LoadingController {
  //======= DECLARATIONS =======//

  final List<Map<String, String>> data = [
    {"time": "12.00 AM", "severity": "Normal", "type": "Weather"},
    {"time": "03.00 AM", "severity": "Average", "type": "Engine"},
    {"time": "06.00 AM", "severity": "Critical", "type": "Weather"},
    {"time": "09.00 AM", "severity": "Average", "type": "Navigation"},
    {"time": "12.00 PM", "severity": "Critical", "type": "Weather"},
  ];

  Color getSeverityBackgroundColor(String severity) {
    switch (severity) {
      case "Normal":
        return ColorConst.color2CA300;
      case "Average":
        return ColorConst.colorF35D00;
      case "Critical":
        return ColorConst.color840F08;
      default:
        return Colors.grey;
    }
  }

  Color getSeverityColor(String severity) {
    switch (severity) {
      case "Normal":
        return ColorConst.color45FF01;
      case "Average":
        return ColorConst.colorFFB78A;
      case "Critical":
        return ColorConst.colorE8271B;
      default:
        return Colors.grey;
    }
  }

  //======= SCREEN METHODS =======//

  //======= EVENTS METHODS =======//
  //======= OTHER METHODS =======//
  //======= APIs CALL =======//
}

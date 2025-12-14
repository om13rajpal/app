import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../utils/constants/export_const.dart';

class RunningSpeedometer extends StatefulWidget {
  final double maxSpeed;

  const RunningSpeedometer({super.key, this.maxSpeed = 30});

  @override
  _RunningSpeedometerState createState() => _RunningSpeedometerState();
}

class _RunningSpeedometerState extends State<RunningSpeedometer> {
  double _speed = 0.0; // in km/h

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1)).listen((Position position) {
      if (!mounted) return;
      setState(() {
        // Convert m/s (GPS default) to km/h
        _speed = (position.speed) * 3.6; // for knots: * 1.94384
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: SfRadialGauge(
          backgroundColor: Colors.transparent,
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: widget.maxSpeed,
              startAngle: 135,
              endAngle: 45,
              showLabels: true,
              showTicks: true,
              showAxisLine: false,
              labelOffset: 30,
              tickOffset: 15,
              minorTicksPerInterval: 4,
              axisLabelStyle: const GaugeTextStyle(color: ColorConst.white, fontSize: 12, fontWeight: FontWeight.w500),
              majorTickStyle: const MajorTickStyle(length: 12, thickness: 2, color: ColorConst.white),
              minorTickStyle: const MinorTickStyle(length: 6, thickness: 1, color: ColorConst.white),
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: widget.maxSpeed, color: ColorConst.white, startWidth: 20, endWidth: 20, sizeUnit: GaugeSizeUnit.logicalPixel),
                GaugeRange(
                  startValue: 0,
                  endValue: _speed,
                  startWidth: 20,
                  endWidth: 20,
                  sizeUnit: GaugeSizeUnit.logicalPixel,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFF00D2FF), // Light blue
                      Color(0xFF3A7BD5), // Medium blue
                      Color(0xFF00D084), // Green
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: _speed,
                  enableAnimation: true,
                  animationDuration: 500,
                  animationType: AnimationType.easeInCirc,
                  needleColor: ColorConst.colorDCDCDC87,
                  needleStartWidth: 1,
                  needleEndWidth: 4,
                  needleLength: 0.7,
                  knobStyle: const KnobStyle(color: ColorConst.colorDCDCDC87, borderColor: Colors.black87, borderWidth: 2, knobRadius: 8, sizeUnit: GaugeSizeUnit.logicalPixel),
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThemeText(text: _speed.toStringAsFixed(1), fontSize: 30),
                      SizedBoxW5(),
                      ThemeText(text: "km/h", fontSize: 30),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.7,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

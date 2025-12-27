/// AI Response UI Widgets for AiSeaSafe
///
/// This file contains widgets for displaying different types of AI responses:
/// - Weather reports with risk indicators
/// - Local assistance contacts
/// - Trip/route planning with analysis
/// - Normal chat responses
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/ai_response_models.dart';
import '../utils/constants/color_constant.dart';
import 'theme_text.dart';

// =============================================================================
// MAIN RESPONSE WIDGET
// =============================================================================

/// Main widget that displays any AI response based on its type
class AIResponseWidget extends StatelessWidget {
  final AIResponse response;
  final VoidCallback? onStartTrip;
  final Function(String location)? onViewOnMap;

  const AIResponseWidget({
    super.key,
    required this.response,
    this.onStartTrip,
    this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message text
        _buildMessageCard(),
        SizedBox(height: 12.h),
        // Structured data based on type
        _buildStructuredContent(),
      ],
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConst.color28333D,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.sp,
                height: 28.sp,
                decoration: BoxDecoration(
                  color: ColorConst.color5AD1D3.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sailing_outlined,
                  color: ColorConst.color5AD1D3,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              ThemeText(
                text: 'Maritime Assistant',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              _buildTypeChip(),
            ],
          ),
          SizedBox(height: 12.h),
          ThemeText(
            text: response.message,
            fontSize: 14,
            textColor: ColorConst.colorDCDCDC,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip() {
    IconData icon;
    Color color;
    String label;

    switch (response.type) {
      case AIResponseType.weather:
        icon = Icons.wb_sunny_outlined;
        color = ColorConst.color5AD1D3;
        label = 'Weather';
        break;
      case AIResponseType.assistance:
        icon = Icons.support_agent;
        color = ColorConst.colorA56DFF;
        label = 'Assistance';
        break;
      case AIResponseType.route:
        icon = Icons.route;
        color = ColorConst.color00FBFF;
        label = 'Route';
        break;
      case AIResponseType.normal:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          ThemeText(
            text: label,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            textColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredContent() {
    switch (response.type) {
      case AIResponseType.weather:
        if (response.weatherReport != null) {
          return WeatherReportWidget(report: response.weatherReport!);
        }
        break;
      case AIResponseType.assistance:
        if (response.localAssistance != null) {
          return LocalAssistanceWidget(contacts: response.localAssistance!);
        }
        break;
      case AIResponseType.route:
        if (response.tripPlan != null) {
          return TripPlanWidget(
            tripPlan: response.tripPlan!,
            onStartTrip: onStartTrip,
            onViewOnMap: onViewOnMap,
          );
        }
        break;
      case AIResponseType.normal:
        break;
    }
    return const SizedBox.shrink();
  }
}

// =============================================================================
// WEATHER REPORT WIDGET
// =============================================================================

class WeatherReportWidget extends StatelessWidget {
  final WeatherReport report;

  const WeatherReportWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRiskColor(report.riskLevel).withOpacity(0.15),
            ColorConst.color091B2C,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getRiskColor(report.riskLevel).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          _buildSafetyMessage(),
          SizedBox(height: 16.h),
          _buildWeatherGrid(),
          SizedBox(height: 16.h),
          _buildDetailedConditions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _getWeatherIcon(report.weather),
          color: ColorConst.color5AD1D3,
          size: 28.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemeText(
                text: report.weather,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 2.h),
              ThemeText(
                text: report.temperature,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                textColor: ColorConst.color5AD1D3,
              ),
            ],
          ),
        ),
        _buildRiskBadge(),
      ],
    );
  }

  Widget _buildRiskBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getRiskColor(report.riskLevel).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getRiskColor(report.riskLevel)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRiskIcon(report.riskLevel),
            size: 16.sp,
            color: _getRiskColor(report.riskLevel),
          ),
          SizedBox(width: 4.w),
          ThemeText(
            text: report.riskLevel.value.toUpperCase(),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            textColor: _getRiskColor(report.riskLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMessage() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: _getRiskColor(report.riskLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20.sp,
            color: _getRiskColor(report.riskLevel),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ThemeText(
              text: report.message,
              fontSize: 13,
              textColor: ColorConst.colorDCDCDC,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherGrid() {
    return Row(
      children: [
        Expanded(child: _buildWeatherTile('Wind', report.windSpeed, Icons.air)),
        SizedBox(width: 8.w),
        Expanded(child: _buildWeatherTile('Waves', report.waveHeight, Icons.waves)),
        SizedBox(width: 8.w),
        Expanded(child: _buildWeatherTile('Visibility', report.visibility, Icons.visibility)),
      ],
    );
  }

  Widget _buildWeatherTile(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ColorConst.color07141F,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.color28333D),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24.sp, color: ColorConst.color5AD1D3),
          SizedBox(height: 8.h),
          ThemeText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 2.h),
          ThemeText(
            text: label,
            fontSize: 11,
            textColor: ColorConst.colorDCDCDC60,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemeText(
          text: 'Detailed Conditions',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildConditionChip('Gusts: ${report.windGusts}'),
            _buildConditionChip('Humidity: ${report.humidity}'),
            _buildConditionChip('Cloud: ${report.cloudCover}'),
            _buildConditionChip('Rain: ${report.rainIntensity}'),
            _buildConditionChip('Pressure: ${report.pressureSurfaceLevel}'),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorConst.color07141F,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConst.color28333D),
      ),
      child: ThemeText(
        text: text,
        fontSize: 12,
        textColor: ColorConst.colorDCDCDC80,
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return ColorConst.color45FF01;
      case RiskLevel.moderate:
        return ColorConst.colorFFB800;
      case RiskLevel.high:
        return ColorConst.colorFF6B00;
      case RiskLevel.extreme:
        return ColorConst.colorE8271B;
    }
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle_outline;
      case RiskLevel.moderate:
        return Icons.warning_amber_outlined;
      case RiskLevel.high:
        return Icons.error_outline;
      case RiskLevel.extreme:
        return Icons.dangerous_outlined;
    }
  }

  IconData _getWeatherIcon(String weather) {
    final w = weather.toLowerCase();
    if (w.contains('clear') || w.contains('sunny')) return Icons.wb_sunny;
    if (w.contains('cloud')) return Icons.cloud;
    if (w.contains('rain')) return Icons.water_drop;
    if (w.contains('storm') || w.contains('thunder')) return Icons.thunderstorm;
    if (w.contains('fog') || w.contains('mist')) return Icons.foggy;
    if (w.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }
}

// =============================================================================
// LOCAL ASSISTANCE WIDGET
// =============================================================================

class LocalAssistanceWidget extends StatelessWidget {
  final List<LocalAssistanceContact> contacts;

  const LocalAssistanceWidget({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConst.color28333D),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: ColorConst.colorA56DFF,
                  size: 24.sp,
                ),
                SizedBox(width: 10.w),
                ThemeText(
                  text: 'Local Assistance Contacts',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Divider(color: ColorConst.color28333D, height: 1),
          ...contacts.map((contact) => _buildContactCard(context, contact)),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, LocalAssistanceContact contact) {
    return InkWell(
      onTap: contact.phone.isNotEmpty ? () => _callNumber(contact.phone) : null,
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorConst.color28333D, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.sp,
              height: 44.sp,
              decoration: BoxDecoration(
                color: _getTypeColor(contact.type).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(contact.type),
                color: _getTypeColor(contact.type),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThemeText(
                    text: contact.name,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  if (contact.phone.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14.sp,
                          color: ColorConst.color5AD1D3,
                        ),
                        SizedBox(width: 6.w),
                        ThemeText(
                          text: contact.phone,
                          fontSize: 13,
                          textColor: ColorConst.color5AD1D3,
                        ),
                      ],
                    ),
                  ],
                  if (contact.notes.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    ThemeText(
                      text: contact.notes,
                      fontSize: 12,
                      textColor: ColorConst.colorDCDCDC60,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ],
              ),
            ),
            if (contact.phone.isNotEmpty)
              Container(
                width: 40.sp,
                height: 40.sp,
                decoration: BoxDecoration(
                  color: ColorConst.color5AD1D3.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.call,
                  color: ColorConst.color5AD1D3,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return ColorConst.colorE8271B;
      case 'marina':
        return ColorConst.color5AD1D3;
      case 'fuel':
        return ColorConst.colorFFB800;
      case 'repair':
        return ColorConst.colorA56DFF;
      case 'port_authority':
        return ColorConst.color00FBFF;
      default:
        return ColorConst.colorDCDCDC;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'marina':
        return Icons.anchor;
      case 'fuel':
        return Icons.local_gas_station;
      case 'repair':
        return Icons.build;
      case 'port_authority':
        return Icons.business;
      default:
        return Icons.location_on;
    }
  }
}

// =============================================================================
// TRIP PLAN WIDGET
// =============================================================================

class TripPlanWidget extends StatelessWidget {
  final TripPlan tripPlan;
  final VoidCallback? onStartTrip;
  final Function(String location)? onViewOnMap;

  const TripPlanWidget({
    super.key,
    required this.tripPlan,
    this.onStartTrip,
    this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(tripPlan.tripAnalysis.status).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Divider(color: ColorConst.color28333D, height: 1),
          _buildRouteInfo(),
          Divider(color: ColorConst.color28333D, height: 1),
          _buildAnalysis(),
          if (tripPlan.tripAnalysis.issues.isNotEmpty) ...[
            Divider(color: ColorConst.color28333D, height: 1),
            _buildIssues(),
          ],
          Divider(color: ColorConst.color28333D, height: 1),
          _buildRecommendation(),
          if (onStartTrip != null && tripPlan.tripAnalysis.status != TripStatus.unsafe) ...[
            Divider(color: ColorConst.color28333D, height: 1),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(tripPlan.tripAnalysis.status).withOpacity(0.15),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            color: ColorConst.color00FBFF,
            size: 24.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ThemeText(
              text: 'Trip Plan',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getStatusColor(tripPlan.tripAnalysis.status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(tripPlan.tripAnalysis.status)),
      ),
      child: ThemeText(
        text: tripPlan.tripAnalysis.status.value,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        textColor: _getStatusColor(tripPlan.tripAnalysis.status),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          _buildLocationRow(
            'From',
            tripPlan.route.source.name,
            Icons.trip_origin,
            ColorConst.color45FF01,
          ),
          Container(
            margin: EdgeInsets.only(left: 12.w),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 30.h,
                  color: ColorConst.color28333D,
                ),
                SizedBox(width: 16.w),
                ThemeText(
                  text: '${tripPlan.route.distanceNauticalMiles} nm • ${tripPlan.route.totalWaypoints} waypoints',
                  fontSize: 12,
                  textColor: ColorConst.colorDCDCDC60,
                ),
              ],
            ),
          ),
          _buildLocationRow(
            'To',
            tripPlan.route.destination.name,
            Icons.place,
            ColorConst.colorE8271B,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String location, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 28.sp,
          height: 28.sp,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemeText(
                text: label,
                fontSize: 11,
                textColor: ColorConst.colorDCDCDC60,
              ),
              ThemeText(
                text: location,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        if (onViewOnMap != null)
          GestureDetector(
            onTap: () => onViewOnMap!(location),
            child: Icon(
              Icons.map_outlined,
              size: 20.sp,
              color: ColorConst.color5AD1D3,
            ),
          ),
      ],
    );
  }

  Widget _buildAnalysis() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeText(
            text: 'Trip Analysis',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildAnalysisTile('Source Weather', tripPlan.tripAnalysis.source.weather)),
              SizedBox(width: 8.w),
              Expanded(child: _buildAnalysisTile('Destination Weather', tripPlan.tripAnalysis.destination.weather)),
            ],
          ),
          if (tripPlan.tripAnalysis.summary.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ThemeText(
              text: tripPlan.tripAnalysis.summary,
              fontSize: 13,
              textColor: ColorConst.colorDCDCDC80,
              textAlign: TextAlign.left,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisTile(String label, WaypointWeather weather) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ColorConst.color07141F,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRiskColor(weather.riskLevel).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeText(
            text: label,
            fontSize: 11,
            textColor: ColorConst.colorDCDCDC60,
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              ThemeText(
                text: '${weather.temperature.toStringAsFixed(0)}°',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              Container(
                width: 10.sp,
                height: 10.sp,
                decoration: BoxDecoration(
                  color: _getRiskColor(weather.riskLevel),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          ThemeText(
            text: 'Wind: ${weather.windSpeed.toStringAsFixed(1)} kt',
            fontSize: 11,
            textColor: ColorConst.colorDCDCDC80,
          ),
          ThemeText(
            text: 'Waves: ${weather.waveHeight.toStringAsFixed(1)} ft',
            fontSize: 11,
            textColor: ColorConst.colorDCDCDC80,
          ),
        ],
      ),
    );
  }

  Widget _buildIssues() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 18.sp,
                color: ColorConst.colorFFB800,
              ),
              SizedBox(width: 8.w),
              ThemeText(
                text: 'Issues Found (${tripPlan.tripAnalysis.issues.length})',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                textColor: ColorConst.colorFFB800,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...tripPlan.tripAnalysis.issues.map(_buildIssueCard),
        ],
      ),
    );
  }

  Widget _buildIssueCard(RouteIssue issue) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ColorConst.colorFFB800.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.colorFFB800.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeText(
            text: 'Waypoint ${issue.waypoint + 1}',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textColor: ColorConst.colorFFB800,
          ),
          SizedBox(height: 4.h),
          ThemeText(
            text: issue.problem,
            fontSize: 13,
            textColor: ColorConst.colorDCDCDC,
            textAlign: TextAlign.left,
          ),
          if (issue.marineCondition.isNotEmpty) ...[
            SizedBox(height: 4.h),
            ThemeText(
              text: issue.marineCondition,
              fontSize: 12,
              textColor: ColorConst.colorDCDCDC60,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendation() {
    return Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: _getStatusColor(tripPlan.tripAnalysis.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(tripPlan.tripAnalysis.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getRecommendationIcon(tripPlan.tripAnalysis.status),
            size: 20.sp,
            color: _getStatusColor(tripPlan.tripAnalysis.status),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ThemeText(
              text: tripPlan.tripAnalysis.recommendation,
              fontSize: 13,
              textColor: ColorConst.colorDCDCDC,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onStartTrip,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ColorConst.color5AD1D3, ColorConst.color00FBFF],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConst.color5AD1D3.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ThemeText(
                    text: 'Start Trip',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    textColor: ColorConst.color07141F,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.safe:
        return ColorConst.color45FF01;
      case TripStatus.caution:
        return ColorConst.colorFFB800;
      case TripStatus.unsafe:
        return ColorConst.colorE8271B;
    }
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return ColorConst.color45FF01;
      case RiskLevel.moderate:
        return ColorConst.colorFFB800;
      case RiskLevel.high:
        return ColorConst.colorFF6B00;
      case RiskLevel.extreme:
        return ColorConst.colorE8271B;
    }
  }

  IconData _getRecommendationIcon(TripStatus status) {
    switch (status) {
      case TripStatus.safe:
        return Icons.check_circle;
      case TripStatus.caution:
        return Icons.warning;
      case TripStatus.unsafe:
        return Icons.cancel;
    }
  }
}


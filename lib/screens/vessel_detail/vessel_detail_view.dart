import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/widgets/common_fancy_shimmer.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../export_controllers.dart';
import '../export_views.dart';

class VesselDetailView extends GetView<VesselDetailController> {
  const VesselDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VesselDetailController>(
      init: VesselDetailController(),
      builder: (logic) {
        return Scaffold(
          body: FlexibleColumnScrollView.withSafeArea(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: ColorConst.color0D1E2E),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                ThemeText(text: "08-07-25 | 02:40 PM", fontSize: 10, fontWeight: FontWeight.w500),
                                SizedBoxH5(),
                                ThemeText(text: "HOU", fontSize: 30, fontWeight: FontWeight.w500),
                                SizedBoxH5(),
                                ThemeText(text: "Houston", fontSize: 14, fontWeight: FontWeight.w400),
                                SizedBoxH5(),
                                ThemeText(text: "29.7310° N, –95.2650° W", fontSize: 10, textColor: ColorConst.color5AD1D3, fontWeight: FontWeight.w400),
                              ],
                            ),
                          ),
                          VerticalDivider(width: 2, color: ColorConst.color07141F),
                          Expanded(
                            child: Column(
                              children: [
                                ThemeText(text: "12-07-25 | 03:25 AM", fontSize: 10, fontWeight: FontWeight.w500),
                                SizedBoxH5(),
                                ThemeText(text: "PTY", fontSize: 30, fontWeight: FontWeight.w500),
                                SizedBoxH5(),
                                ThemeText(text: "Panama", fontSize: 14, fontWeight: FontWeight.w400),
                                SizedBoxH5(),
                                ThemeText(text: "8.9490° N, –79.5667° W", fontSize: 10, textColor: ColorConst.color5AD1D3, fontWeight: FontWeight.w400),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBoxH10(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ThemeText(text: "30NM | 19 hr 40 min", fontSize: 10, fontWeight: FontWeight.w500),
                        ThemeText(text: "90NM | 71 hr 25 min", fontSize: 10, fontWeight: FontWeight.w500),
                      ],
                    ),
                    SizedBoxH20(),
                    Row(
                      children: [
                        CommonShimmerImage(
                          imageUrl: "https://www.shutterstock.com/image-photo/smiling-african-american-millennial-businessman-600nw-1437938108.jpg",
                          height: 32,
                          width: 32,
                          borderRadius: 5,
                        ),
                        SizedBoxW10(),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ThemeText(text: "Peter Haul", fontSize: 15, fontWeight: FontWeight.w700),
                                  ThemeText(text: "109", fontSize: 15, fontWeight: FontWeight.w700),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ThemeText(text: "Captain", fontSize: 10, textColor: ColorConst.color5AD1D3, fontWeight: FontWeight.w500),
                                  Spacer(),
                                  SvgPicture.asset(ImageConst.crewMembers),
                                  SizedBoxW5(),
                                  ThemeText(text: "Crew Members", fontSize: 10, fontWeight: FontWeight.w500),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBoxW10(),
                  ],
                ),
              ),
              SizedBoxH20(),
              Table(
                columnWidths: const {0: FixedColumnWidth(100), 1: FixedColumnWidth(130), 2: FixedColumnWidth(100)},
                border: TableBorder.all(color: ColorConst.color00293B, borderRadius: BorderRadius.circular(8)),
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: ColorConst.color0D1E2E, borderRadius: BorderRadius.circular(8)),
                    children: [tableHeader(ImageConst.clock, "TIME"), tableHeader(ImageConst.severity, "SEVERITY"), tableHeader(ImageConst.type, "TYPE")],
                  ),
                  // Rows
                  ...controller.data.map((row) {
                    return TableRow(
                      decoration: const BoxDecoration(color: ColorConst.color07141F),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.center,
                          child: ThemeText(text: row["time"]!, fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 10),
                            decoration: BoxDecoration(color: controller.getSeverityBackgroundColor(row["severity"]!), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: controller.getSeverityColor(row["severity"]!)),
                                ),
                                SizedBoxW10(),
                                ThemeText(text: row["severity"]!, fontSize: 12, fontWeight: FontWeight.w500),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.center,
                          child: ThemeText(text: row["type"]!, fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              SizedBoxH20(),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: ColorConst.color0D1E2E),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        color: ColorConst.color11283D,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ThemeText(text: "TRIP LOGS"),
                      ),
                    ),
                    SizedBoxH15(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InfoItemWidget(value: "26", label: "Alerts", iconPath: ImageConst.alert, crossAxisAlignment: CrossAxisAlignment.start),
                            InfoItemWidget(value: "18.9 Kn", label: "Speed", iconPath: ImageConst.flash),
                            InfoItemWidget(value: "34.6°", label: "Course", iconPath: ImageConst.course, crossAxisAlignment: CrossAxisAlignment.start),
                          ],
                        ),
                        SizedBoxH15(),
                        Divider(color: ColorConst.color457F88.withValues(alpha: 0.5)),
                        SizedBoxH5(),
                        ReportRowWidget(iconPath: ImageConst.report, title: "Last Reported", detail: "5 Minutes ago"),
                        ReportRowWidget(iconPath: ImageConst.distanceTravelled, title: "Distance Travelled", detail: "10 NM"),
                        ReportRowWidget(iconPath: ImageConst.distanceToGo, title: "Distance To Go", detail: "100 NM"),
                        ReportRowWidget(iconPath: ImageConst.draught, title: "Draught", detail: "11.3 M"),
                        ReportRowWidget(iconPath: ImageConst.weather1, title: "Weather", detail: "Heavy Rainfall"),
                        ReportRowWidget(iconPath: ImageConst.windSpeed, title: "Wind Speed", detail: "45 Kt", detailColor: ColorConst.colorCC2925),
                        SizedBoxH5(),
                      ],
                    ).applyPaddingHorizontal(16),
                  ],
                ),
              ),
              SizedBoxH20(),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: ColorConst.color0D1E2E),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        color: ColorConst.color11283D,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ThemeText(text: "VESSEL SPEED"),
                      ),
                    ),
                    SizedBoxH15(),
                    RunningSpeedometer(maxSpeed: 200),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoItemWidget(value: "110 NM", label: "Total Distance", iconPath: ImageConst.distanceToGo, crossAxisAlignment: CrossAxisAlignment.start),
                        InfoItemWidget(value: "20k MT", label: "Total Fuel", iconPath: ImageConst.fuel, crossAxisAlignment: CrossAxisAlignment.start),
                      ],
                    ).applyPaddingHorizontal(16),
                    SizedBoxH25(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoItemWidget(value: "11 NM", label: "Travelled", iconPath: ImageConst.distanceTravelled, crossAxisAlignment: CrossAxisAlignment.start),
                        InfoItemWidget(value: "1.1k MT", label: "Fuel Used", iconPath: ImageConst.fuel, crossAxisAlignment: CrossAxisAlignment.start),
                      ],
                    ).applyPaddingHorizontal(16),
                    SizedBoxH15(),
                  ],
                ),
              ),
              SizedBoxH15(),
              PrimaryButton(
                icon: SvgPicture.asset(ImageConst.arrowRight, colorFilter: ColorFilter.mode(ColorConst.color2D2D2D, BlendMode.srcIn)),
                label: StringConst.viewAllTrip,
                onPressed: () {
                  // controller.handleAddButtonNavigation();
                },
              ),
            ],
          ).applyPaddingAll(kDefaultHPadding),
        );
      },
    );
  }

  Widget tableHeader(String image, String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(image),
          SizedBoxW5(),
          ThemeText(text: title, fontSize: 14, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}

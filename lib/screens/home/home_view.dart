import 'dart:io';

import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:aiSeaSafe/screens/voice_dialog/voice_dialog_view.dart';
import 'package:aiSeaSafe/utils/constants/export_const.dart';
import 'package:aiSeaSafe/utils/extensions/export_const.dart';
import 'package:aiSeaSafe/widgets/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../widgets/common_fancy_shimmer.dart' show CommonShimmerImage;
import '../export_controllers.dart';
import '../export_views.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Voice Assistant Floating Action Button
      floatingActionButton: _buildVoiceAssistantFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThemeText(text: "Welcome,", fontSize: 16, fontWeight: FontWeight.w400),
                  ThemeText(text: "Peter", fontSize: 24, fontWeight: FontWeight.w500),
                  ThemeText(text: DateFormat('EEE, dd MMM, hh:mm a').format(DateTime.now()), fontSize: 14.0, fontWeight: FontWeight.w400),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorConst.white),
                  shape: BoxShape.circle,
                ),
                child: CommonShimmerImage(imageUrl: "https://www.shutterstock.com/image-photo/smiling-african-american-millennial-businessman-600nw-1437938108.jpg", height: 45, width: 45),
              ),
            ],
          ),
          SizedBoxH30(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThemeText(text: "23", fontSize: 60, fontWeight: FontWeight.w300),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: ThemeText(text: "°", fontSize: 24),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 14.0),
                child: ThemeText(text: "c", fontSize: 24),
              ),
            ],
          ),
          Row(
            children: [
              Image.asset(ImageConst.weather, scale: 3.5),
              SizedBoxW5(),
              ThemeText(text: "Sunny", fontSize: 14, fontWeight: FontWeight.w500),
            ],
          ),
          SizedBoxH40(),

          // Conditional rendering based on vessel availability
          Obx(() {
            if (controller.hasVessels.value) {
              return _buildVesselAndTripView();
            } else {
              return _buildAddVesselView();
            }
          }),
        ],
      ).applyPaddingHorizontal(kDefaultPaddingValue),
    );
  }

  // Widget for when user has vessels - shows current vessel and add trip option
  Widget _buildVesselAndTripView() {
    return Column(
      children: [
        // Current vessel display
        Obx(() {
          if (controller.currentVessel.value != null) {
            final vessel = controller.currentVessel.value!;
            return InkWell(
              onTap: () {
                Get.toNamed(Routes.vesselDetail);
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: kDefaultVPadding),
                padding: EdgeInsets.all(kDefaultVPadding),
                decoration: BoxDecoration(
                  color: ColorConst.color091B2C,
                  borderRadius: BorderRadius.circular(10.sp),
                  border: Border.all(color: ColorConst.color11242F),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vessel.imageUrl!.contains("http")
                        ? CommonShimmerImage(
                            imageUrl: vessel.imageUrl ?? "https://www.shutterstock.com/image-photo/smiling-african-american-millennial-businessman-600nw-1437938108.jpg",
                            height: 45,
                            width: 45,
                            borderRadius: 6,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6.sp),
                            child: Image.file(height: 45, width: 45, File(vessel.imageUrl ?? ""), fit: BoxFit.cover),
                          ),
                    SizedBoxW15(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ThemeText(text: vessel.name, fontSize: 16, fontWeight: FontWeight.w500),
                          SizedBoxH8(),
                          ThemeText(text: vessel.vesselId, fontSize: 12, fontWeight: FontWeight.w500, textColor: ColorConst.color457F88),
                        ],
                      ),
                    ),
                    SvgPicture.asset(ImageConst.arrowRight),
                  ],
                ),
              ).toCenter(),
            );
          }
          return SizedBox.shrink();
        }),

        // Add new trip section
        Container(
          margin: EdgeInsets.symmetric(vertical: kDefaultVPadding),
          padding: EdgeInsets.all(kDefaultVPadding),
          decoration: BoxDecoration(
            color: ColorConst.color091B2C,
            borderRadius: BorderRadius.circular(10.sp),
            border: Border.all(color: ColorConst.color11242F),
          ),
          child: Column(
            children: [
              if (controller.hasTripAdded.value) ...[
                Row(
                  children: [
                    ThemeText(text: "HOU", fontSize: 18, fontWeight: FontWeight.w700),
                    SizedBoxW10(),
                    Expanded(child: SvgPicture.asset(ImageConst.direction)),
                    SizedBoxW5(),
                    SvgPicture.asset(ImageConst.boat),
                    SizedBoxW5(),
                    Expanded(child: SvgPicture.asset(ImageConst.direction)),
                    SizedBoxW10(),
                    ThemeText(text: "PTY", fontSize: 18, fontWeight: FontWeight.w700),
                  ],
                ),
                SizedBoxH5(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ThemeText(text: "08-07-25 | 02:40 PM", fontSize: 10, fontWeight: FontWeight.w500),
                    ThemeText(text: "10%", fontSize: 16, fontWeight: FontWeight.w600),
                    ThemeText(text: "12-07-25 | 03:25 AM", fontSize: 10, fontWeight: FontWeight.w500),
                  ],
                ),
                SizedBoxH25(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    InfoItemWidget(value: "04", label: "Alerts", iconPath: ImageConst.alert, crossAxisAlignment: CrossAxisAlignment.start),
                    InfoItemWidget(value: "18.9 Kn", label: "Speed", iconPath: ImageConst.flash),
                    InfoItemWidget(value: "34.6°", label: "Course", iconPath: ImageConst.course, crossAxisAlignment: CrossAxisAlignment.start),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    SvgPicture.asset(ImageConst.radio),
                    SizedBoxW10(),
                    Expanded(child: SvgPicture.asset(ImageConst.direction)),
                    SizedBoxW5(),
                    SvgPicture.asset(ImageConst.boat),
                    SizedBoxW5(),
                    Expanded(child: SvgPicture.asset(ImageConst.direction)),
                    SizedBoxW10(),
                    SvgPicture.asset(ImageConst.location),
                  ],
                ),
                SizedBoxH5(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ThemeText(text: StringConst.from, fontSize: 12, fontWeight: FontWeight.w700),
                    ThemeText(text: StringConst.to, fontSize: 12, fontWeight: FontWeight.w700),
                  ],
                ),
                SizedBoxH15(),
                PrimaryButton(
                  icon: Icon(Hicons.addBold),
                  label: StringConst.addNewTrip,
                  onPressed: () {
                    controller.handleAddButtonNavigation();
                  },
                ),
              ],
            ],
          ),
        ),
        SizedBoxH15(),
        if (controller.hasTripAdded.value)
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ColorConst.colorED0E00),
            child: Center(
              child: ThemeText(text: "SOS", fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  // Widget for when user has no vessels - shows add vessel option
  Widget _buildAddVesselView() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultVPadding),
      padding: EdgeInsets.symmetric(horizontal: kDefaultHPadding, vertical: 30.h),
      decoration: BoxDecoration(
        color: ColorConst.color091B2C,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: ColorConst.color11242F),
      ),
      child: Column(
        children: [
          SvgPicture.asset(ImageConst.vesselSvg),
          SizedBoxH30(),
          PrimaryButton(
            icon: Icon(Hicons.addBold),
            label: StringConst.addYourVessel,
            onPressed: () {
              controller.handleAddButtonNavigation();
            },
          ),
        ],
      ),
    ).toCenter();
  }

  /// Builds the Voice Assistant Floating Action Button.
  ///
  /// This FAB provides quick access to the voice assistant feature
  /// from the home screen. Tapping it opens the voice dialog.
  Widget _buildVoiceAssistantFab() {
    return FloatingActionButton(
      onPressed: () {
        // Open voice assistant dialog
        Get.dialog<void>(
          const VoiceDialogView(),
          barrierDismissible: true,
          useSafeArea: false,
        );
      },
      backgroundColor: ColorConst.color5AD1D3,
      elevation: 8,
      child: Icon(
        Icons.mic,
        color: ColorConst.white,
        size: 28.sp,
      ),
    );
  }
}

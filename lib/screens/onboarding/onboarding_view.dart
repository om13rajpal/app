import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoatScene extends StatefulWidget {
  const BoatScene({super.key});

  @override
  State<BoatScene> createState() => _BoatSceneState();
}

class _BoatSceneState extends State<BoatScene> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2)).then((value) {
      Get.offAllNamed(Routes.login);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/wave.png"),
          fit: BoxFit.cover,
        ),
      ),
    ),);
  }
}

import 'package:flutter/material.dart';

class ColorConst {
  static final ColorConst _instance = ColorConst._internal();

  ColorConst._internal();

  static ColorConst get instance => _instance;
  static const Color primary = Color(0xFF007BFF);
  static const Color red = Colors.red;
  static const Color colorED0E00 = Color(0xffED0E00);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color color000000 = Color(0xff000000);
  static const Color grey = Colors.grey;

  static const Color color07141F = Color(0xFF07141F);
  static const Color color0D1E2E = Color(0xFF0D1E2E);
  static const Color colorCDCDCC = Color(0xffCDCDCC);
  static const Color colorDCDCDC87 = Color.fromRGBO(220, 220, 220, 0.87);
  static const Color colorDCDCDC80 = Color.fromRGBO(220, 220, 220, 0.80);
  static const Color colorDCDCDC38 = Color.fromRGBO(220, 220, 220, 0.38);
  static const Color colorDCDCDC40 = Color.fromRGBO(220, 220, 220, 0.40);
  static const Color colorDCDCDC60 = Color.fromRGBO(220, 220, 220, 0.6);

  static const Color colorFFFFFF13 = Color.fromRGBO(255, 255, 255, 0.13);

  static const Color color091B2C = Color(0xFF091B2C);
  static const Color color457F88 = Color(0xFF457F88);
  static const Color color00293B = Color(0xFF00293B);
  static const Color color11283D = Color(0xFF11283D);
  static const Color color45FF01 = Color(0xFF45FF01);
  static const Color color2CA300 = Color(0xFF2CA300);
  static const Color colorFFB78A = Color(0xFFFFB78A);
  static const Color colorF35D00 = Color(0xFFF35D00);
  static const Color colorE8271B = Color(0xFFE8271B);
  static const Color color840F08 = Color(0xFF840F08);
  static const Color colorCC2925 = Color(0xFFCC2925);
  static const Color colorA56DFF = Color(0xFFA56DFF);
  static const Color color5AD1D3 = Color(0xFF5AD1D3);
  static const Color color00FBFF = Color(0xFF00FBFF);

  static const Color colorD1D1D1 = Color(0xFFD1D1D1);

  static const Color color11242F = Color(0xFF11242F);

  static const Color color28333D = Color(0xFF28333D);

  static const Color colorDCDCDC = Color(0xFFDCDCDC);
  static const Color color2D2D2D = Color(0xFF2D2D2D);

  // Additional colors for AI response widgets
  static const Color colorFFB800 = Color(0xFFFFB800); // Warning/Caution yellow
  static const Color colorFF6B00 = Color(0xFFFF6B00); // High risk orange
}

import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String toFormatted() => DateFormat('yyyy-MM-dd').format(this);
}

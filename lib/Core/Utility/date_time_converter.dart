import 'package:intl/intl.dart';

class DateAndTimeConvert {
  static String formatDateTime(
    String dateTimeString, {
    bool showDate = true,
    bool showTime = true,
  }) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();

    String datePart = showDate ? DateFormat('dd-MM-yyyy').format(dateTime) : '';
    String timePart = showTime ? DateFormat('hh:mm a').format(dateTime) : '';

    if (showDate && showTime) {
      return "$datePart $timePart"; // Both
    } else if (showDate) {
      return datePart; // Only Date
    } else if (showTime) {
      return timePart; // Only Time
    }
    return '';
  }

  static String timeAndDate(
    String dateTimeString, {
    bool showDate = true,
    bool showTime = true,
  }) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();

    // 👇 Updated date format to show "03 Jun 2025"
    String datePart = showDate
        ? DateFormat('dd MMM yyyy').format(dateTime)
        : '';
    String timePart = showTime ? DateFormat('hh:mm a').format(dateTime) : '';

    if (showDate && showTime) {
      // ✅ Show time first, then date
      return "$timePart  $datePart";
    } else if (showDate) {
      return datePart; // Only Date
    } else if (showTime) {
      return timePart; // Only Time
    }
    return '';
  }
}

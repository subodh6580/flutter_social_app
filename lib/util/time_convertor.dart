import 'package:foap/helper/imports/common_import.dart';

class TimeAgo {
  static String timeAgoSinceDate(DateTime timeAgoDate,
      {bool numericDates = true}) {
    final difference = DateTime.now().difference(timeAgoDate);

    if (difference.inDays > 8) {
      int days = difference.inDays;
      if (days > 365) {
        //Years
        int years = (days / 365).round();

        return years >= 2
            ? '$years ${monthsAgoString.tr}'
            : '$years ${monthAgoString.tr}';
      } else if (days > 30) {
        int months = (days / 30).round();
        return months >= 2
            ? '$months ${monthsAgoString.tr}'
            : '$months ${monthAgoString.tr}';
      } else {
        return '${(difference.inDays / 7).floor()} ${weekAgoString.tr}';
      }
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates)
          ? '1 ${weekAgoString.tr}'
          : lastWeekString.tr;
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} ${daysAgoString.tr}';
    } else if (difference.inDays >= 1) {
      return (numericDates)
          ? '1 ${dayAgoString.tr}'
          : yesterdayString.tr;
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} ${hoursAgoString.tr}';
    } else if (difference.inHours >= 1) {
      return (numericDates)
          ? '1 ${hoursAgoString.tr}'
          : anHourAgoString.tr;
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} ${minutesAgoString.tr}';
    } else if (difference.inMinutes >= 1) {
      return (numericDates)
          ? '1 ${minutesAgoString.tr}'
          : aMinuteAgoString.tr;
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} ${secondsAgoString.tr}';
    } else {
      return justNowString.tr;
    }
  }
}

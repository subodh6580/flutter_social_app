extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // String messageTimeForChat() {
  //   final difference = DateTime.now().difference(this).inDays;
  //
  //   if (isToday()) {
  //     return DateFormat('hh:mm a').format(this);
  //   } else if (isYesterday()) {
  //     return yesterday;
  //   } else if (difference < 7) {
  //     return DateFormat('EEEE').format(this);
  //   }
  //   return DateFormat('dd-MMM-yyyy').format(this);
  // }

  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool get isThisWeek {
    var now = DateTime.now();
    var thisWeek = now.subtract(const Duration(days: 7));

    return thisWeek.isBefore(this);
  }

  bool get isThisMonth {
    var now = DateTime.now();
    var thisMonth = DateTime(now.year, now.month - 1, now.day);

    return thisMonth.isBefore(this);
  }

  String get getTimeAgo {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(this);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Just now';
    }
  }
}

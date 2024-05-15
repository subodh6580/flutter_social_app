extension IntegerExtension on int {
  String get formatNumber {
    if (this > 999 && this < 99999) {
      return "${(this / 1000).toStringAsFixed(1)} K";
    } else if (this > 99999 && this < 999999) {
      return "${(this / 1000).toStringAsFixed(0)} K";
    } else if (this > 999999 && this < 999999999) {
      return "${(this / 1000000).toStringAsFixed(1)} M";
    } else if (this > 999999999) {
      return "${(this / 1000000000).toStringAsFixed(1)} B";
    } else {
      return toString();
    }
  }

  String get fileSizeSpecifier {
    var divider = 1024;

    if (this < divider) {
      return '$this B';
    }

    if (this < divider * divider && this % divider == 0) {
      return '${(this / divider).toStringAsFixed(0)} KB';
    }

    if (this < divider * divider) {
      return '${(this / divider).toStringAsFixed(2)} KB';
    }

    if (this < divider * divider * divider && this % divider == 0) {
      return '${(this / (divider * divider)).toStringAsFixed(0)} MB';
    }

    if (this < divider * divider * divider) {
      return '${(this / divider / divider).toStringAsFixed(2)} MB';
    }

    if (this < divider * divider * divider * divider && this % divider == 0) {
      return '${(this / (divider * divider * divider)).toStringAsFixed(0)} GB';
    }

    if (this < divider * divider * divider * divider) {
      return '${(this / divider / divider / divider).toStringAsFixed(2)} GB';
    }

    if (this < divider * divider * divider * divider * divider &&
        this % divider == 0) {
      num r = this / divider / divider / divider / divider;
      return '${r.toStringAsFixed(0)} TB';
    }

    if (this < divider * divider * divider * divider * divider) {
      num r = this / divider / divider / divider / divider;
      return '${r.toStringAsFixed(2)} TB';
    }

    if (this < divider * divider * divider * divider * divider * divider &&
        this % divider == 0) {
      num r = this / divider / divider / divider / divider / divider;
      return '${r.toStringAsFixed(0)} PB';
    } else {
      num r = this / divider / divider / divider / divider / divider;
      return '${r.toStringAsFixed(2)} PB';
    }
  }

  String get formatTime {
    return '${(Duration(seconds: this))}'.split('.')[0].padLeft(8, '0');
  }

  String get convertSecondsToTimeString {
    if (this < 60) {
      return '${this}s';
    } else {
      int minutes = this ~/ 60;
      int remainingSeconds = this % 60;
      if (remainingSeconds == 0) {
        return '${minutes}m';
      } else {
        return '${minutes}m:${remainingSeconds}s';
      }
    }
  }
}

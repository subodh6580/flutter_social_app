import 'dart:math';
import 'package:foap/helper/imports/common_import.dart';

bool isDarkMode = true;

String randomId() {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();

  return String.fromCharCodes(Iterable.generate(
      25, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}


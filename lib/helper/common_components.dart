import 'package:foap/helper/imports/common_import.dart';

Widget divider({double? height, Color? color}) {
  return Container(
    height: height ?? 0.1,
    color: color ?? AppColorConstants.dividerColor,
  );
}

Widget verifiedUserTag() {
  return Row(
    children: [
      const SizedBox(
        width: 5,
      ),
      Image.asset(
        'assets/verified.png',
        height: 15,
        width: 15,
      )
    ],
  );
}
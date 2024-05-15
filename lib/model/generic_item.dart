import 'package:foap/helper/imports/common_import.dart';

class GenericItem {
  String id;
  String title;
  String? subTitle;
  String? image;
  ThemeIcon? icon;
  RecordType? recordType;
  bool? isSelected;

  GenericItem({
    required this.id,
    required this.title,
    this.image,
    this.subTitle,
    this.icon,
    this.recordType,
    this.isSelected,
  });
}

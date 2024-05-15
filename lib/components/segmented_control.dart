import 'package:flutter/cupertino.dart';
import 'package:foap/helper/imports/common_import.dart';

class SegmentedControl extends StatefulWidget {
  final List<String>? segments;
  final int? value;
  final ValueChanged<int> onValueChanged;

  const SegmentedControl({
    Key? key,
    required this.onValueChanged,
    this.segments,
    this.value,
  }) : super(key: key);

  @override
  State<SegmentedControl> createState() => SegmentedControlState();
}

class SegmentedControlState extends State<SegmentedControl> {
  late List<String>? segments;
  late int? value;
  late ValueChanged<int> onValueChanged;

  @override
  void initState() {
    segments = widget.segments;
    onValueChanged = widget.onValueChanged;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    value = widget.value;
    return CupertinoSegmentedControl<int>(
      padding: EdgeInsets.zero,
      selectedColor: AppColorConstants.themeColor,
      unselectedColor: AppColorConstants.backgroundColor,
      borderColor: AppColorConstants.disabledColor,
      children: addSegmentedChips(segments!),
      groupValue: value,
      onValueChanged: (value) {
        onValueChanged(value);
      },
    );
  }

  addSegmentedChips(List<String> segments) {
    Map<int, Widget> hashmap = {};
    for (int i = 0; i < segments.length; i++) {
      hashmap[i] = SizedBox(
          width: (MediaQuery.of(context).size.width - 40) / segments.length,
          height: 36,
          child: BodySmallText(
            segments[i],
              weight: TextWeight.regular
          ).alignCenter);
    }
    return hashmap;
  }
}

import 'package:foap/helper/imports/common_import.dart';

class SFSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchStarted;
  final ValueChanged<String> onSearchCompleted;

  final Color? iconColor;
  final Color? backgroundColor;
  final double? radius;

  final bool? needBackButton;
  final bool? showSearchIcon;
  final TextStyle? textStyle;
  final double? shadowOpacity;
  final String? hintText;

  const SFSearchBar({
    Key? key,
    required this.onSearchCompleted,
    this.onSearchStarted,
    this.onSearchChanged,
    this.iconColor,
    this.radius,
    this.backgroundColor,
    this.needBackButton,
    this.showSearchIcon,
    this.textStyle,
    this.shadowOpacity,
    this.hintText,
  }) : super(key: key);

  @override
  State<SFSearchBar> createState() => _SFSearchBarState();
}

class _SFSearchBarState extends State<SFSearchBar> {
  late ValueChanged<String>? onSearchChanged;
  late VoidCallback? onSearchStarted;
  late ValueChanged<String> onSearchCompleted;
  TextEditingController controller = TextEditingController();
  late Color? iconColor;
  String? searchText;
  bool? needBackButton;
  bool? showSearchIcon;
  late TextStyle? textStyle;
  late Color? backgroundColor;
  late double? radius;
  late double? shadowOpacity;
  late String? hintText;

  @override
  void initState() {
    onSearchChanged = widget.onSearchChanged;
    onSearchStarted = widget.onSearchStarted;
    onSearchCompleted = widget.onSearchCompleted;
    iconColor = widget.iconColor;
    needBackButton = widget.needBackButton;
    showSearchIcon = widget.showSearchIcon;
    textStyle = widget.textStyle;
    backgroundColor = widget.backgroundColor;
    radius = widget.radius;
    shadowOpacity = widget.shadowOpacity;
    hintText = widget.hintText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            needBackButton == true
                ? IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: ThemeIconWidget(
                      ThemeIcon.backArrow,
                      color: AppColorConstants.themeColor,
                    ))
                : Container(),
            showSearchIcon == true
                ? ThemeIconWidget(
                    ThemeIcon.search,
                    color: iconColor,
                    size: 20,
                  ).lP16.ripple(() {
                    if (searchText != null && searchText!.length > 2) {
                      onSearchChanged!(searchText!);
                    }
                  })
                : Container(),
            Expanded(

              child: TextField(
                  autocorrect: false,
                  controller: controller,
                  onEditingComplete: () {
                    onSearchCompleted(controller.text);
                  },
                  onChanged: (value) {
                    searchText = value;
                    // controller.text = searchText!;
                    if (onSearchChanged != null) {
                      onSearchChanged!(value);
                    }
                    setState(() {});
                  },
                  onTap: () {
                    if (onSearchStarted != null) {
                      onSearchStarted!();
                    }
                  },
                  style: textStyle ??
                      TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor),
                  cursorColor: AppColorConstants.iconColor,
                  decoration: InputDecoration(
                    hintStyle: textStyle ??
                        TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.mainTextColor),
                    hintText: hintText ?? searchAnythingString.tr,
                    border: InputBorder.none,
                  )).setPadding(bottom: 4, left: 8),
            ),
          ],
        ),
      ),
    ).backgroundCard(
        radius: radius ?? 20,
        fillColor: backgroundColor,
        shadowOpacity: shadowOpacity);
  }
}

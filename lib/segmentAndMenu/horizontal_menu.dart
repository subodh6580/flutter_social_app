import 'package:flutter/material.dart';
import 'package:foap/segmentAndMenu/triangle_shape.dart';
import 'package:foap/helper/extension.dart';
import 'package:get/get.dart';

import '../components/custom_texts.dart';
import '../util/app_config_constants.dart';

class HorizontalMenuBar extends StatefulWidget {
  final Function(int) onSegmentChange;
  final List<String> menus;

  final double? height;
  final EdgeInsets? padding;
  final int selectedIndex;

  const HorizontalMenuBar(
      {Key? key,
      required this.onSegmentChange,
      required this.menus,
      required this.selectedIndex,
      this.height,
      this.padding})
      : super(key: key);

  @override
  HorizontalMenuBarState createState() => HorizontalMenuBarState();
}

class HorizontalMenuBarState extends State<HorizontalMenuBar> {
  String selectedMenu = 'Sports';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ??
          (widget.padding == null
              ? 35
              : (35 + widget.padding!.top + widget.padding!.bottom)),
      child: Center(
        child: ListView.separated(
            padding: widget.padding ?? EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Column(
                children: [
                  Container(
                    color: index == widget.selectedIndex
                        ? AppColorConstants.themeColor
                        : AppColorConstants.cardColor.darken(),
                    child: BodySmallText(
                      widget.menus[index].tr,
                      color: AppColorConstants.mainTextColor,
                      weight: index == widget.selectedIndex
                          ? TextWeight.semiBold
                          : TextWeight.medium,
                    )
                        .setPadding(
                            left: DesignConstants.horizontalPadding,
                            right: DesignConstants.horizontalPadding,
                            top: 5,
                            bottom: 5)
                        .ripple(() {
                      setState(() {
                        // selectedMenu = menus[index];
                        widget.onSegmentChange(index);
                      });
                    }),
                  ).round(20),
                  // const SizedBox(
                  //   height: 5,
                  // ),
                  // Container(
                  //   height: 2,
                  //   width: widget.menus[index].length * 8,
                  //   color: index == widget.selectedIndex
                  //       ? ColorConstants.themeColor
                  //       : Colors.transparent,
                  // ).round(10)
                ],
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return const SizedBox(width: 10);
            },
            itemCount: widget.menus.length),
      ),
    );
  }
}

class StaggeredMenuBar extends StatefulWidget {
  final String? title;
  final Function(int) onSegmentChange;
  final List<Widget> childs;

  const StaggeredMenuBar({
    Key? key,
    this.title,
    required this.childs,
    required this.onSegmentChange,
  }) : super(key: key);

  @override
  State<StaggeredMenuBar> createState() => _StaggeredMenuBarState();
}

class _StaggeredMenuBarState extends State<StaggeredMenuBar> {
  List<Widget> childs = [];
  String selectedMenu = 'Sports';
  Widget? selectedChild;
  late String? title;

  @override
  void initState() {
    childs = widget.childs;
    title = widget.title;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? BodyMediumText(title!, weight: TextWeight.medium).bP16
            : Container(),
        Wrap(
          spacing: 5,
          runSpacing: 10,
          children: <Widget>[for (int i = 0; i < childs.length; i++) childs[i]],
        ),
      ],
    ).vP16;
  }
}

class HorizontalSegmentBar extends StatefulWidget {
  final List<String> segments;
  final Function(int) onSegmentChange;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;
  final double? width;
  final bool? hideHighlightIndicator;
  final bool? adjustInMinimumWidth;

  const HorizontalSegmentBar({
    Key? key,
    required this.onSegmentChange,
    required this.segments,
    this.textStyle,
    this.selectedTextStyle,
    this.width,
    this.hideHighlightIndicator,
    this.adjustInMinimumWidth,
  }) : super(key: key);

  @override
  State<HorizontalSegmentBar> createState() => _HorizontalSegmentBarState();
}

class _HorizontalSegmentBarState extends State<HorizontalSegmentBar> {
  int selectedMenuIndex = 0;
  late double width;

  @override
  void initState() {
    super.initState();

    width = 0;
    Future.delayed(Duration.zero, () {
      setState(() {
        width = widget.width ?? MediaQuery.of(context).size.width - 40;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: ListView.separated(
            // shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedMenuIndex = index;
                    widget.onSegmentChange(index);
                  });
                },
                child: SizedBox(
                  width: widget.adjustInMinimumWidth == true
                      ? null
                      : width / widget.segments.length,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 10),
                      BodyLargeText(
                        widget.segments[index],
                        color: index == selectedMenuIndex
                            ? AppColorConstants.themeColor
                            : AppColorConstants.mainTextColor,
                        weight: index == selectedMenuIndex
                            ? TextWeight.bold
                            : TextWeight.medium,
                      ).hP8,
                      if (widget.hideHighlightIndicator == false)
                        index == selectedMenuIndex
                            ? Container(
                                height: 3,
                                width: widget.adjustInMinimumWidth == true
                                    ? widget.segments[index].length * 10
                                    : width / widget.segments.length,
                                color: AppColorConstants.themeColor,
                              ).round(10).tP16
                            : Container(
                                height: 0.5,
                                width: widget.adjustInMinimumWidth == true
                                    ? widget.segments[index].length * 10
                                    : width / widget.segments.length,
                                color: AppColorConstants.dividerColor,
                              ).tP16
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return widget.adjustInMinimumWidth == true &&
                      widget.hideHighlightIndicator == true
                  ? SizedBox(
                      width: 15,
                      height: 20,
                      child: Center(
                        child: Container(
                          height: 20,
                          width: 1,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                    )
                  : Container();
            },
            itemCount: widget.segments.length),
      ),
    );
  }
}

class LargeHorizontalMenuBar extends StatefulWidget {
  final Function(int) onSegmentChange;
  final List<Widget> childs;

  const LargeHorizontalMenuBar({
    Key? key,
    required this.onSegmentChange,
    required this.childs,
  }) : super(key: key);

  @override
  State<LargeHorizontalMenuBar> createState() => _LargeHorizontalMenuBarState();
}

class _LargeHorizontalMenuBarState extends State<LargeHorizontalMenuBar> {
  List<Widget> childs = [];
  Widget? selectedChild;

  @override
  void initState() {
    childs = widget.childs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, index) {
            return Align(
                alignment: Alignment.centerLeft,
                child: childs[index].rp(25).ripple(() {
                  setState(() {
                    // selectedMenu = menus[index];
                    widget.onSegmentChange(index);
                  });
                }));
          },
          itemCount: childs.length),
    );
  }
}

class HorizontalSegmentBarWithPointer extends StatefulWidget {
  final List<String> segments;
  final Function(int) onSegmentChange;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;
  final double? width;
  final int? selectedMenuIndex;

  const HorizontalSegmentBarWithPointer(
      {Key? key,
      required this.onSegmentChange,
      required this.segments,
      this.textStyle,
      this.selectedTextStyle,
      this.width,
      this.selectedMenuIndex})
      : super(key: key);

  @override
  State<HorizontalSegmentBarWithPointer> createState() =>
      _HorizontalSegmentBarWithPointerState();
}

class _HorizontalSegmentBarWithPointerState
    extends State<HorizontalSegmentBarWithPointer> {
  List<String> menus = ['Detail', 'Related'];
  int selectedMenuIndex = 0;
  late TextStyle? textStyle;
  late TextStyle? selectedTextStyle;
  late double width;

  @override
  void initState() {
    super.initState();

    menus = widget.segments;
    textStyle = widget.textStyle;
    selectedTextStyle = widget.selectedTextStyle;
    width = 0;
    selectedMenuIndex = widget.selectedMenuIndex ?? 0;

    Future.delayed(Duration.zero, () {
      setState(() {
        width = widget.width ?? MediaQuery.of(context).size.width - 40;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  selectedMenuIndex = index;
                  widget.onSegmentChange(index);
                });
              },
              child: SizedBox(
                width: width / menus.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 10),
                    BodyLargeText(
                      menus[index],
                      color: index == selectedMenuIndex
                          ? AppColorConstants.themeColor
                          : AppColorConstants.mainTextColor,
                      weight: index == selectedMenuIndex
                          ? TextWeight.bold
                          : TextWeight.medium,
                    ),
                    index == selectedMenuIndex
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomPaint(
                                  size: const Size(5, 5),
                                  painter: TopPointingTriangle(
                                      color: AppColorConstants.themeColor)),
                              Container(
                                height: 2,
                                width: width / menus.length,
                                color: AppColorConstants.themeColor,
                              ).round(10),
                            ],
                          )
                        : Container(
                            height: 2,
                            width: width / menus.length,
                            color: AppColorConstants.disabledColor
                                .withOpacity(0.5),
                          )
                  ],
                ),
              ),
            );
          },
          itemCount: menus.length),
    );
  }
}

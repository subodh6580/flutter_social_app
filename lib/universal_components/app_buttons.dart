import 'package:flutter/material.dart';
import 'package:foap/helper/extension.dart';

import '../components/custom_texts.dart';
import '../util/app_config_constants.dart';

class AppThemeButton extends StatelessWidget {
  final String? text;
  final double? height;
  final double? width;
  final double? cornerRadius;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;

  final VoidCallback? onPress;

  const AppThemeButton({
    Key? key,
    required this.text,
    required this.onPress,
    this.height,
    this.width,
    this.cornerRadius,
    this.leading,
    this.trailing,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 50,
      color: backgroundColor ?? AppColorConstants.themeColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading != null ? leading!.hP8 : Container(),
          Center(
            child: Text(
              text!,
              style: TextStyle(
                  fontSize: FontSizes.b2,
                  fontWeight: TextWeight.medium,
                  color: Colors.white),
            ).hP8,
          ),
          trailing != null ? trailing!.hP4 : Container()
        ],
      ),
    ).round(10).ripple(() {
      onPress!();
    });
  }
}

class AppThemeBorderButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPress;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? height;
  final double? cornerRadius;
  final TextStyle? textStyle;
  final double? width;

  const AppThemeBorderButton(
      {Key? key,
      required this.text,
      required this.onPress,
      this.height,
      this.width,
      this.cornerRadius,
      this.borderColor,
      this.backgroundColor,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 50,
      color: backgroundColor,
      child: Center(
        child: Text(
          text!,
          style: textStyle ??
              TextStyle(
                  fontSize: FontSizes.b2,
                  fontWeight: TextWeight.medium,
                  color: AppColorConstants.mainTextColor),
        ).hP8,
      ),
    )
        .borderWithRadius(
            value: 1,
            radius: 10,
            color: borderColor ?? AppColorConstants.dividerColor)
        .ripple(onPress!);
  }
}

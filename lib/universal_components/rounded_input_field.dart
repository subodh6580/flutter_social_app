import 'dart:math';
import 'package:currency_picker/currency_picker.dart';
import 'package:foap/helper/extension.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../components/custom_texts.dart';
import '../helper/localization_strings.dart';
import '../theme/theme_icon.dart';
import '../util/app_config_constants.dart';

//ignore: must_be_immutable
class InputField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  final String? defaultText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ThemeIcon? icon;
  final int? maxLines;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  bool? startedEditing;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;
  final Color? cursorColor;
  final int? maxLength;

  final Function(bool)? focusStatusChangeHandler;

  InputField(
      {Key? key,
        this.label,
        this.showLabelInNewLine = true,
        this.hintText,
        this.defaultText,
        this.controller,
        this.onChanged,
        this.onSubmitted,
        this.icon,
        this.maxLines,
        this.showDivider = false,
        this.iconColor,
        this.isDisabled,
        this.startedEditing = false,
        this.isError = false,
        this.iconOnRightSide = false,
        this.backgroundColor,
        this.showBorder = false,
        this.borderColor,
        this.cornerRadius = 12,
        this.cursorColor,
        this.maxLength,
        this.focusStatusChangeHandler})
      : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxLines != null
          ? (min(widget.maxLines!, 10) * 20) + 45
          : widget.label != null
          ? 70
          : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP8
              : Container(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.isError == false
                    ? widget.backgroundColor
                    : (widget.showDivider == false &&
                    widget.showBorder == false)
                    ? AppColorConstants.red
                    : widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.cornerRadius!),
                border: widget.showBorder == true
                    ? Border.all(
                    width: 0.5,
                    color: widget.isError == true
                        ? AppColorConstants.red
                        : widget.borderColor ??
                        AppColorConstants.dividerColor)
                    : null,
              ),
              child: Row(
                children: [
                  (widget.label != null && widget.showLabelInNewLine == false)
                      ? BodySmallText(
                    widget.label!,
                  ).bP4
                      : Container(),
                  widget.iconOnRightSide == false
                      ? iconView().lP16
                      : Container(),
                  Expanded(
                    child: Focus(
                      child: TextField(
                        controller: widget.controller,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        maxLength: widget.maxLength,
                        style: TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.inputFieldTextColor),
                        onChanged: widget.onChanged,
                        maxLines: widget.maxLines,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: InputBorder.none,
                            counterText: "",
                            // labelText: hintText,
                            hintStyle: TextStyle(
                                fontSize: FontSizes.b3,
                                color: AppColorConstants
                                    .inputFieldPlaceholderTextColor),
                            hintText: widget.hintText),
                      ),
                      onFocusChange: (hasFocus) {
                        widget.startedEditing = hasFocus;
                        if (widget.focusStatusChangeHandler != null) {
                          widget.focusStatusChangeHandler!(hasFocus);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  widget.iconOnRightSide == true ? iconView() : Container(),
                ],
              ),
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
        height: 0.5,
        color: widget.startedEditing == true
            ? AppColorConstants.themeColor
            : widget.isError == true
            ? AppColorConstants.red
            : AppColorConstants.red)
        : Container();
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(widget.icon!,
        color: widget.iconColor ?? AppColorConstants.iconColor,
        size: 20)
        .rP16
        : Container();
  }
}

//ignore: must_be_immutable
class PasswordField extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final String? label;
  final bool? showDivider;
  final bool? iconOnRightSide;
  final ThemeIcon? icon;
  final Color? iconColor;
  final bool? showRevealPasswordIcon;
  final bool? showLabelInNewLine;
  final bool? showBorder;
  final Color? borderColor;
  final bool? isError;
  bool? startedEditing;
  final double? cornerRadius;

  final Color? cursorColor;

  PasswordField({
    Key? key,
    required this.onChanged,
    this.controller,
    this.label,
    this.hintText,
    this.showDivider = false,
    this.backgroundColor,
    this.iconOnRightSide,
    this.iconColor,
    this.icon,
    this.showLabelInNewLine = true,
    this.showRevealPasswordIcon = false,
    this.showBorder = false,
    this.borderColor,
    this.isError = false,
    this.startedEditing = false,
    this.cornerRadius = 12,
    this.cursorColor,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // margin: EdgeInsets.symmetric(vertical: 5),
      height: widget.label != null ? 70 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP8
              : Container(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.isError == false
                    ? widget.backgroundColor
                    : (widget.showDivider == false &&
                    widget.showBorder == false)
                    ? AppColorConstants.red
                    : widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.cornerRadius!),
                border: widget.showBorder == true
                    ? Border.all(
                    width: 0.5,
                    color: widget.isError == true
                        ? AppColorConstants.red
                        : widget.borderColor ??
                        AppColorConstants.dividerColor)
                    : null,
              ),
              child: Row(
                children: [
                  (widget.label != null && widget.showLabelInNewLine == false)
                      ? BodySmallText(
                    widget.label!,
                  ).bP4
                      : Container(),
                  iconView().lP16,
                  Expanded(
                      child: Focus(
                        child: TextField(
                            style: TextStyle(
                                fontSize: FontSizes.b3,
                                color: AppColorConstants.inputFieldTextColor),
                            controller: widget.controller,
                            onChanged: widget.onChanged,
                            cursorColor: AppColorConstants.themeColor,
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              hintStyle: TextStyle(
                                  fontSize: FontSizes.b3,
                                  color: AppColorConstants
                                      .inputFieldPlaceholderTextColor),
                              border: InputBorder.none,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                            )),
                        onFocusChange: (hasFocus) {
                          widget.startedEditing = hasFocus;
                          setState(() {});
                        },
                      )),
                  revealPasswordIcon()
                ],
              ),
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget revealPasswordIcon() {
    return widget.showRevealPasswordIcon == true
        ? Row(
      children: [
        ThemeIconWidget(
          showPassword == false ? ThemeIcon.showPwd : ThemeIcon.hide,
          color: AppColorConstants.iconColor,
          size: 20,
        ).ripple(() {
          setState(() {
            showPassword = !showPassword;
          });
        }),
        const SizedBox(
          width: 16,
        )
      ],
    )
        : Container();
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
        height: 0.5,
        color: widget.startedEditing == true
            ? AppColorConstants.themeColor
            : widget.isError == true
            ? AppColorConstants.red
            : AppColorConstants.dividerColor)
        : Container();
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(
      widget.icon!,
      color: widget.iconColor ?? AppColorConstants.themeColor,
      size: 20,
    ).rP16
        : Container();
  }
}

//ignore: must_be_immutable
class RoundedInputMobileNumberField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  final String? defaultText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ThemeIcon? icon;
  final int? maxLines;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  bool? startedEditing;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;

  final Color? cursorColor;
  final TextStyle? textStyle;

  String? countryCodeText;

  final ValueChanged<String>? countrycodeValueChanged;

  RoundedInputMobileNumberField({
    Key? key,
    this.label,
    this.showLabelInNewLine = true,
    this.hintText,
    this.defaultText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.icon,
    this.maxLines,
    this.showDivider = false,
    this.iconColor,
    this.isDisabled,
    this.startedEditing = false,
    this.isError = false,
    this.iconOnRightSide = false,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor,
    this.cornerRadius = 12,
    this.cursorColor,
    this.textStyle,
    this.countryCodeText,
    this.countrycodeValueChanged,
  }) : super(key: key);

  @override
  State<RoundedInputMobileNumberField> createState() =>
      _RoundedInputMobileNumberFieldState();
}

class _RoundedInputMobileNumberFieldState
    extends State<RoundedInputMobileNumberField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // margin: EdgeInsets.symmetric(vertical: 5),
      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: widget.maxLines != null
          ? (min(widget.maxLines!, 10) * 20) + 45
          : widget.label != null
          ? 70
          : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP4
              : Container(),
          Container(
            decoration: BoxDecoration(
              color: widget.isError == false
                  ? widget.backgroundColor
                  : (widget.showDivider == false && widget.showBorder == false)
                  ? AppColorConstants.red
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.cornerRadius!),
              border: widget.showBorder == true
                  ? Border.all(
                  width: 0.5,
                  color: widget.isError == true
                      ? AppColorConstants.red
                      : widget.borderColor ??
                      AppColorConstants.dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 80,
                    // height: 55,
                    // color: AppColorConstants.grey.withOpacity(0.2),
                    child: InkWell(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BodyMediumText(
                              widget.countryCodeText ?? "+1",
                              // style: TextStyles.body,
                            ).lP8,
                            const Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          // optional. Shows phone code before the country name.
                          onSelect: (Country country) {
                            setState(() {
                              widget.countryCodeText = '+${country.phoneCode}';
                              widget.countrycodeValueChanged!(
                                  widget.countryCodeText!);
                            });
                          },
                        );
                      },
                    )).rP16,
                (widget.label != null && widget.showLabelInNewLine == false)
                    ? BodySmallText(
                  widget.label!,
                ).bP4
                    : Container(),
                widget.iconOnRightSide == false ? iconView().lP16 : Container(),
                Expanded(
                  child: Focus(
                    child: TextField(
                      controller: widget.controller,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.inputFieldTextColor),
                      onChanged: widget.onChanged,
                      maxLines: widget.maxLines,
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: InputBorder.none,
                          counterText: "",
                          // labelText: hintText,
                          hintStyle: TextStyle(
                              fontSize: FontSizes.b3,
                              color: AppColorConstants
                                  .inputFieldPlaceholderTextColor),
                          hintText: widget.hintText),
                    ),
                    onFocusChange: (hasFocus) {
                      widget.startedEditing = hasFocus;
                      setState(() {});
                    },
                  ),
                ),
                widget.iconOnRightSide == true ? iconView() : Container(),
              ],
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
        height: 0.5,
        color: widget.startedEditing == true
            ? AppColorConstants.themeColor
            : widget.isError == true
            ? AppColorConstants.red
            : AppColorConstants.red)
        : Container();
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(widget.icon!,
        color: widget.iconColor ?? AppColorConstants.iconColor,
        size: 20)
        .rP16
        : Container();
  }
}

//ignore: must_be_immutable
class RoundedInputDateField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  String? defaultText;

  // final TextEditingController? controller;
  final ValueChanged<TimeOfDay>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ThemeIcon? icon;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  bool? startedEditing;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;

  final Color? cursorColor;
  final TextStyle? textStyle;

  final DateTime? minDate;
  final DateTime? maxDate;

  RoundedInputDateField({
    Key? key,
    this.label,
    this.showLabelInNewLine = true,
    this.hintText,
    this.defaultText,
    // this.controller,
    this.onChanged,
    this.onSubmitted,
    this.icon,
    this.showDivider = false,
    this.iconColor,
    this.isDisabled,
    this.startedEditing = false,
    this.isError = false,
    this.iconOnRightSide = false,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor,
    this.cornerRadius = 12,
    this.cursorColor,
    this.textStyle,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

  @override
  State<RoundedInputDateField> createState() => _RoundedInputDateFieldState();
}

class _RoundedInputDateFieldState extends State<RoundedInputDateField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // margin: EdgeInsets.symmetric(vertical: 5),
      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: widget.label != null ? 70 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP8
              : Container(),
          Container(
            decoration: BoxDecoration(
              // color: widget.isError == false
              //     ? widget.backgroundColor
              //     : (widget.showDivider == false && widget.showBorder == false)
              //         ? AppColorConstants.red
              //         : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.cornerRadius!),
              border: widget.showBorder == true
                  ? Border.all(
                  width: 0.5,
                  color: widget.isError == true
                      ? AppColorConstants.red
                      : widget.borderColor ??
                      AppColorConstants.dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                if (widget.label != null && widget.showLabelInNewLine == false)
                  BodySmallText(
                    widget.label!,
                    textAlign: TextAlign.center,
                  ),
                if (widget.icon != null && widget.iconOnRightSide == false)
                  iconView().lP16,
                Expanded(
                  child: BodySmallText(
                      widget.defaultText ?? widget.hintText ?? '',
                      textAlign: TextAlign.center,
                      color: widget.defaultText == null
                          ? AppColorConstants.inputFieldPlaceholderTextColor
                          : AppColorConstants.inputFieldTextColor)
                      .ripple(() async {
                    TimeOfDay initialTime = TimeOfDay.now();
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: initialTime,
                    );

                    if (pickedTime != null) {
                      widget.onChanged!(pickedTime);
                      setState(() {
                        widget.defaultText = pickedTime.format(
                            context); //set output date to TextField value.
                      });
                    } else {}
                  }),
                ),
                widget.iconOnRightSide == true ? iconView() : Container(),
              ],
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
        height: 0.5,
        color: widget.startedEditing == true
            ? AppColorConstants.themeColor
            : widget.isError == true
            ? AppColorConstants.red
            : AppColorConstants.red)
        : Container();
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(widget.icon!,
        color: widget.iconColor ?? AppColorConstants.iconColor,
        size: 20)
        .rP16
        : Container();
  }
}

//ignore: must_be_immutable
class RoundedInputPriceField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  String? currency;

  final String? defaultText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? currencyValueChanged;

  final ThemeIcon? icon;
  final int? maxLines;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  bool? startedEditing;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;
  final bool? disable;

  final Color? cursorColor;
  final TextStyle? textStyle;

  RoundedInputPriceField({
    Key? key,
    this.label,
    this.showLabelInNewLine = true,
    this.hintText,
    this.disable,
    this.currency,
    this.defaultText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.currencyValueChanged,
    this.icon,
    this.maxLines,
    this.showDivider = false,
    this.iconColor,
    this.isDisabled,
    this.startedEditing = false,
    this.isError = false,
    this.iconOnRightSide = false,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor,
    this.cornerRadius = 12,
    this.cursorColor,
    this.textStyle,
  }) : super(key: key);

  @override
  State<RoundedInputPriceField> createState() => _RoundedInputPriceFieldState();
}

class _RoundedInputPriceFieldState extends State<RoundedInputPriceField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxLines != null
          ? (min(widget.maxLines!, 10) * 20) + 45
          : widget.label != null
          ? 70
          : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP8
              : Container(),
          Container(
            decoration: BoxDecoration(
              color: widget.isError == false
                  ? widget.backgroundColor
                  : (widget.showDivider == false && widget.showBorder == false)
                  ? AppColorConstants.red
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.cornerRadius!),
              border: widget.showBorder == true
                  ? Border.all(
                  width: 0.5,
                  color: widget.isError == true
                      ? AppColorConstants.red
                      : widget.borderColor ??
                      AppColorConstants.dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                (widget.label != null && widget.showLabelInNewLine == false)
                    ? BodySmallText(
                  widget.label!,
                ).bP4
                    : Container(),
                widget.iconOnRightSide == false ? iconView().lP16 : Container(),
                SizedBox(
                  width: 80,
                  // height: 50,
                  // color: AppColorConstants.grey.withOpacity(0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BodyMediumText(
                        widget.currency ?? "\$",
                        // style: TextStyles.body,
                      ).lP8,
                      const Icon(Icons.arrow_drop_down)
                    ],
                  ).ripple(() {
                    if (widget.disable == false) {
                      showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (Currency currency) {
                          setState(() {
                            widget.currency = currency.code;
                            widget.currencyValueChanged!(widget.currency!);
                          });
                        },
                      );
                    }
                  }),
                ).rP16,
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    // style: TextStyles.body,
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    // cursorColor: ThemeColors.PrimaryTextColor,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                widget.iconOnRightSide == true ? iconView() : Container(),
              ],
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
        height: 0.5,
        color: widget.startedEditing == true
            ? AppColorConstants.themeColor
            : widget.isError == true
            ? AppColorConstants.red
            : AppColorConstants.red)
        : Container();
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(widget.icon!,
        color: widget.iconColor ?? AppColorConstants.iconColor,
        size: 20)
        .rP16
        : Container();
  }
}
//ignore: must_be_immutable
class RoundedInputDateTimeField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  final String? defaultText;
  final TextEditingController? controller;
  final ValueChanged<DateTime>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ThemeIcon? icon;
  final int? maxLines;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  bool? startedEditing;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;

  final Color? cursorColor;
  final TextStyle? textStyle;

  final DateTime? minDate;
  final DateTime? maxDate;

  RoundedInputDateTimeField({
    Key? key,
    this.label,
    this.showLabelInNewLine = true,
    this.hintText,
    this.defaultText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.icon,
    this.maxLines,
    this.showDivider = false,
    this.iconColor,
    this.isDisabled,
    this.startedEditing = false,
    this.isError = false,
    this.iconOnRightSide = false,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor,
    this.cornerRadius = 12,
    this.cursorColor,
    this.textStyle,
    this.minDate,
    this.maxDate,
  }) : super(key: key);

  @override
  State<RoundedInputDateTimeField> createState() =>
      _RoundedInputDateTimeFieldState();
}

class _RoundedInputDateTimeFieldState extends State<RoundedInputDateTimeField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // margin: EdgeInsets.symmetric(vertical: 5),
      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: widget.maxLines != null
          ? (min(widget.maxLines!, 10) * 20) + 45
          : widget.label != null
          ? 70
          : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP8
              : Container(),
          Container(
            decoration: BoxDecoration(
              color: widget.isError == false
                  ? widget.backgroundColor
                  : (widget.showDivider == false && widget.showBorder == false)
                  ? AppColorConstants.red
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.cornerRadius!),
              border: widget.showBorder == true
                  ? Border.all(
                  width: 0.5,
                  color: widget.isError == true
                      ? AppColorConstants.red
                      : widget.borderColor ??
                      AppColorConstants.dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                (widget.label != null && widget.showLabelInNewLine == false)
                    ? BodySmallText(
                  widget.label!,
                ).bP4
                    : Container(),
                widget.iconOnRightSide == false ? iconView().lP16 : Container(),
                Expanded(
                  child: Focus(
                    child: TextField(
                      controller: widget.controller,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.inputFieldTextColor),
                      // onChanged: widget.onChanged,
                      maxLines: widget.maxLines,
                      readOnly: true,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            firstDate: widget.minDate ?? DateTime(1960),
                            initialDate: DateTime.now(),
                            lastDate: widget.maxDate ?? DateTime(2100));
                        if (pickedDate != null) {
                          widget.onChanged!(pickedDate);
                          setState(() {
                            String formattedDate =
                            DateFormat('dd-MMM-yyyy').format(pickedDate);
                            widget.controller!.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {}
                      },
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: InputBorder.none,
                          counterText: "",
                          // labelText: hintText,
                          hintStyle: TextStyle(
                              fontSize: FontSizes.b3,
                              color: AppColorConstants
                                  .inputFieldPlaceholderTextColor),
                          hintText: widget.hintText),
                    ),
                    onFocusChange: (hasFocus) {
                      widget.startedEditing = hasFocus;
                      setState(() {});
                    },
                  ),
                ),
                widget.iconOnRightSide == true ? iconView() : Container(),
              ],
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
        height: 0.5,
        color: widget.startedEditing == true
            ? AppColorConstants.themeColor
            : widget.isError == true
            ? AppColorConstants.red
            : AppColorConstants.red)
        : Container();
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(widget.icon!,
        color: widget.iconColor ?? AppColorConstants.iconColor,
        size: 20)
        .rP16
        : Container();
  }
}

class RoundedDropdownField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  final String? value;
  final ValueChanged<String> onChanged;
  final ThemeIcon? icon;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;

  final TextStyle? textStyle;
  final List<String> options;

  const RoundedDropdownField(
      {Key? key,
        this.label,
        this.showLabelInNewLine = true,
        this.hintText,
        this.value,
        required this.onChanged,
        this.icon,
        this.showDivider = false,
        this.iconColor,
        this.isDisabled,
        this.isError = false,
        this.iconOnRightSide = false,
        this.backgroundColor,
        this.showBorder = false,
        this.borderColor,
        this.cornerRadius = 12,
        this.textStyle,
        required this.options})
      : super(key: key);

  @override
  State<RoundedDropdownField> createState() => _RoundedDropdownFieldState();
}

class _RoundedDropdownFieldState extends State<RoundedDropdownField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // margin: EdgeInsets.symmetric(vertical: 5),
      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: widget.label != null ? 70 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.label != null && widget.showLabelInNewLine == true)
              ? BodySmallText(
            widget.label!,
          ).bP8
              : Container(),
          Container(
            decoration: BoxDecoration(
              color: widget.isError == false
                  ? widget.backgroundColor
                  : (widget.showDivider == false && widget.showBorder == false)
                  ? AppColorConstants.red
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.cornerRadius!),
              border: widget.showBorder == true
                  ? Border.all(
                  width: 0.5,
                  color: widget.isError == true
                      ? AppColorConstants.red
                      : widget.borderColor ??
                      AppColorConstants.dividerColor)
                  : null,
            ),
            child: Row(
              children: [
                (widget.label != null && widget.showLabelInNewLine == false)
                    ? BodySmallText(
                  widget.label!,
                ).bP4
                    : Container(),
                widget.iconOnRightSide == false ? iconView().lP16 : Container(),
                Expanded(
                  child: DropdownButton<String>(
                    dropdownColor: AppColorConstants.cardColor,
                    isExpanded: true,
                    hint: Text(
                      widget.value ??
                          widget.hintText ??
                          selectString,
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: widget.value == null
                              ? AppColorConstants.inputFieldPlaceholderTextColor
                              : AppColorConstants.inputFieldTextColor),
                    ),
                    underline: Container(),
                    items: widget.options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                              fontSize: FontSizes.b3,
                              color: AppColorConstants.inputFieldTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      widget.onChanged(value!);
                    },
                  ).rP8,
                ),
                widget.iconOnRightSide == true ? iconView() : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget iconView() {
    return widget.icon != null
        ? ThemeIconWidget(widget.icon!,
        color: widget.iconColor ?? AppColorConstants.iconColor,
        size: 20)
        .rP16
        : Container();
  }
}

class DropdownBorderedField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ThemeIcon? icon;
  final Color? iconColor;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;
  final VoidCallback? onTap;

  final TextStyle? textStyle;

  const DropdownBorderedField(
      {Key? key,
        this.hintText,
        this.controller,
        this.icon,
        this.iconColor,
        this.iconOnRightSide = false,
        this.backgroundColor,
        this.showBorder = false,
        this.borderColor,
        this.cornerRadius = 0,
        this.textStyle,
        this.onTap})
      : super(key: key);

  @override
  State<DropdownBorderedField> createState() => _DropdownBorderedState();
}

class _DropdownBorderedState extends State<DropdownBorderedField> {
  late String? hintText;
  late TextEditingController? controller;
  late ThemeIcon? icon;
  late Color? iconColor;
  late bool? iconOnRightSide;
  late Color? backgroundColor;
  late bool? showBorder;
  late Color? borderColor;
  late double? cornerRadius;

  @override
  void initState() {
    hintText = widget.hintText;
    controller = widget.controller;
    icon = widget.icon;
    iconColor = widget.iconColor;
    iconOnRightSide = widget.iconOnRightSide;
    backgroundColor = widget.backgroundColor;
    showBorder = widget.showBorder;
    borderColor = widget.borderColor;
    cornerRadius = widget.cornerRadius;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius ?? 0),
        border: showBorder == true
            ? Border.all(
            width: 0.5,
            color: borderColor ?? AppColorConstants.dividerColor)
            : null,
      ),
      height: 60,
      child: Row(children: [
        Expanded(
          child: AbsorbPointer(
              absorbing: true,
              child: TextField(
                readOnly: true,
                controller: controller,
                keyboardType: hintText == hintText
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                textAlign: TextAlign.left,
                style: widget.textStyle ??
                    TextStyle(
                        fontSize: FontSizes.b3,
                        color: AppColorConstants.mainTextColor),
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    counterText: "",
                    // labelText: hintText,
                    labelStyle: TextStyle(
                        fontSize: FontSizes.b2,
                        color: AppColorConstants.mainTextColor),
                    hintStyle: widget.textStyle ??
                        TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.mainTextColor),
                    hintText: hintText),
              )),
        ),
        iconOnRightSide == true ? iconView() : Container(),
      ]),
    ).ripple(() {
      widget.onTap!();
    });
  }

  Widget iconView() {
    return icon != null
        ? ThemeIconWidget(icon!,
        color: iconColor ?? AppColorConstants.themeColor, size: 20)
        .rP16
        : Container();
  }
}

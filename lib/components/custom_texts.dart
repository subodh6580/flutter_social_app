import 'package:flutter/material.dart';

import '../util/app_config_constants.dart';

class FontSizes {
  static double scale = 1;

  static double get h1 => 48 * scale;

  static double get h2 => 40 * scale;

  static double get h3 => 32 * scale;

  static double get h4 => 24 * scale;

  static double get h5 => 20 * scale;

  static double get h6 => 18 * scale;

  static double get b1 => 18 * scale;

  static double get b2 => 16 * scale;

  static double get b3 => 14 * scale;

  static double get b4 => 12 * scale;

  static double get b5 => 10 * scale;
}

class TextWeight {
  static FontWeight get regular => FontWeight.w300;

  static FontWeight get medium => FontWeight.w500;

  static FontWeight get semiBold => FontWeight.w700;

  static FontWeight get bold => FontWeight.w900;
}


class Heading1Text extends StatelessWidget {
  final String text;
  final int? maxLines;
  final FontWeight? weight;
  final Color? color;
  final TextAlign? textAlign;

  const Heading1Text(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
          fontSize: FontSizes.h1,
          color: color ?? AppColorConstants.mainTextColor,
          fontWeight: weight ?? TextWeight.medium),
    );
  }
}

class Heading2Text extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const Heading2Text(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
          fontSize: FontSizes.h2,
          color: color ?? AppColorConstants.mainTextColor,
          fontWeight: weight ?? TextWeight.medium),
    );
  }
}

class Heading3Text extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const Heading3Text(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
        textAlign: textAlign ?? TextAlign.left,
        style: TextStyle(
            fontSize: FontSizes.h3,
            color: color ?? AppColorConstants.mainTextColor,
            fontWeight: weight ?? TextWeight.medium));
  }
}

class Heading4Text extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const Heading4Text(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
          fontSize: FontSizes.h4,
          color: color ?? AppColorConstants.mainTextColor,
          fontWeight: weight ?? TextWeight.medium),
    );
  }
}

class Heading5Text extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const Heading5Text(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
          fontSize: FontSizes.h5,
          color: color ?? AppColorConstants.mainTextColor,
          fontWeight: weight ?? TextWeight.medium),
    );
  }
}

class Heading6Text extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const Heading6Text(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
          fontSize: FontSizes.h6,
          color: color ?? AppColorConstants.mainTextColor,
          fontWeight: weight ?? TextWeight.medium),
    );
  }
}

class BodyExtraLargeText extends StatelessWidget {
  final String text;

  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const BodyExtraLargeText(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign ?? TextAlign.left,
        overflow: TextOverflow.clip,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: FontSizes.b1,
            color: color ?? AppColorConstants.mainTextColor,
            fontWeight: weight ?? TextWeight.medium));
  }
}

class BodyLargeText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const BodyLargeText(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign ?? TextAlign.left,
        overflow: TextOverflow.clip,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: FontSizes.b2,
            color: color ?? AppColorConstants.mainTextColor,
            fontWeight: weight ?? TextWeight.medium));
  }
}

class BodyMediumText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const BodyMediumText(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign ?? TextAlign.left,
        overflow: TextOverflow.clip,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: FontSizes.b3,
            color: color ?? AppColorConstants.mainTextColor,
            fontWeight: weight ?? TextWeight.medium));
  }
}

class BodySmallText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const BodySmallText(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign ?? TextAlign.left,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
        style: TextStyle(
            fontSize: FontSizes.b4,
            color: color ?? AppColorConstants.mainTextColor,
            fontWeight: weight ?? TextWeight.medium));
  }
}

class BodyExtraSmallText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  final FontWeight? weight;
  final Color? color;

  const BodyExtraSmallText(this.text,
      {Key? key, this.textAlign, this.maxLines, this.weight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign ?? TextAlign.left,
        overflow: TextOverflow.clip,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: FontSizes.b5,
            color: color ?? AppColorConstants.mainTextColor,
            fontWeight: weight ?? TextWeight.medium));
  }
}

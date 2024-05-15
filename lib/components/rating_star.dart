import 'package:flutter/material.dart';

import '../util/app_config_constants.dart';

class RatingStar extends StatefulWidget {
  const RatingStar({Key? key, this.rating}) : super(key: key);
  final double? rating;

  @override
  RatingStarState createState() => RatingStarState();
}

class RatingStarState extends State<RatingStar> {
  Widget _start(int index) {
    bool halfStar = false;
    if ((widget.rating! * 2) % 2 != 0) {
      if (index < widget.rating! && index == widget.rating! - .5) {
        halfStar = true;
      }
    }

    return Icon(
      halfStar ? Icons.star_half : Icons.star,
      color: index < widget.rating!
          ? AppColorConstants.themeColor
          : AppColorConstants.dividerColor,
      size: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 5),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Wrap(
            children: Iterable.generate(value.toInt(), (index) => _start(index))
                .toList());
      },
    );
  }
}

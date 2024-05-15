import 'package:flutter/material.dart';
import 'package:foap/controllers/misc/rating_controller.dart';
import 'package:foap/helper/extension.dart';
import 'package:get/get.dart';
import '../../components/review_tile.dart';
import '../../helper/common_components.dart';
import '../../util/app_config_constants.dart';

class ReviewsList extends StatelessWidget {
  final RatingController _ratingController = Get.find();

  ReviewsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
        padding: EdgeInsets.only(
            top: 25,
            bottom: 100,
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding),
        itemCount: _ratingController.ratings.length,
        itemBuilder: (context, index) {
          return ReviewsTile(review: _ratingController.ratings[index]);
        },
        separatorBuilder: (context, index) {
          return divider().vP16;
        }));
  }
}

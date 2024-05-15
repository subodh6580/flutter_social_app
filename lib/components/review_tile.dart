import 'package:foap/components/rating_star.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/model/rating_model.dart';
import '../helper/imports/common_import.dart';

class ReviewsTile extends StatelessWidget {
  final RatingModel review;

  const ReviewsTile({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              review.user!.picture != null
                  ? CachedNetworkImage(
                      imageUrl: review.user!.picture!,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ).round(10).rP16
                  : Container(
                      color: AppColorConstants.themeColor,
                      height: 48,
                      width: 48,
                      child: Center(
                        child: Heading4Text(
                            review.user!.userName.getInitials.toUpperCase()),
                      ),
                    ).circular,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          review.user!.name!,
                          weight: TextWeight.bold,
                        ),
                        const Spacer(),
                        BodyExtraSmallText(
                          review.timeAgoStr,
                          weight: TextWeight.bold,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        width: 80, child: RatingStar(rating: review.rating)),
                  ],
                ).hP8,
              )
            ],
          ).vP16,
          BodyMediumText(review.reviewMsg).bP16,
        ],
      ).p16,
    ).round(10);
  }
}

import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/helper/imports/common_import.dart';

import '../../components/post_card.dart';
import '../../model/post_model.dart';

class ViewPostInsights extends StatefulWidget {
  final PostModel post;

  const ViewPostInsights({Key? key, required this.post}) : super(key: key);

  @override
  State<ViewPostInsights> createState() => _ViewPostInsightsState();
}

class _ViewPostInsightsState extends State<ViewPostInsights> {
  final PostController _postController = Get.find();

  @override
  void initState() {
    // _postController.viewInsight(widget.post.id);
    _postController.viewInsight(widget.post.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          backNavigationBar(
               title: insightsString.tr),
          divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: PostMediaTile(
                      model: widget.post,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const ThemeIconWidget(ThemeIcon.message),
                        const SizedBox(
                          height: 5,
                        ),
                        BodySmallText(
                          widget.post.totalComment.toString(),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        const ThemeIconWidget(ThemeIcon.favFilled),
                        const SizedBox(
                          height: 5,
                        ),
                        BodySmallText(
                          widget.post.totalLike.toString(),
                        )
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     ThemeIconWidget(ThemeIcon.send),
                    //     const SizedBox(
                    //       height: 5,
                    //     ),
                    //     BodySmallText(
                    //       '10',
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ThemeIconWidget(ThemeIcon.bookMark),
                    //     const SizedBox(
                    //       height: 5,
                    //     ),
                    //     BodySmallText(
                    //       '10',
                    //     )
                    //   ],
                    // )
                  ],
                ).hp(50),
                divider().vP25,
                overView(),
                divider().vP25,
                viewByNetwork(),
                divider().vP25,
                postInteraction(),
                divider().vP25,
                profileActivity(),
                divider().vP25,
                viewByGender()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget overView() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                overviewString.tr,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    accountsReachedString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.totalView.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     BodyMediumText(
              //       accountsEngaged,
              //       weight: TextWeight.medium,
              //     ),
              //     BodyMediumText(_postController.insight.value!.totalView.toString()),
              //   ],
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(viewsString.tr,
                      weight: TextWeight.medium),
                  BodyMediumText(
                      _postController.insight.value!.totalView.toString()),
                ],
              ),
            ],
          ).hp(DesignConstants.horizontalPadding));
  }

  Widget postInteraction() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                postInteractionsString.tr,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    profileVisitsString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.profileViewFromPost
                      .toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    followsString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.followFromPost.toString()),
                ],
              ),
            ],
          ).hp(DesignConstants.horizontalPadding));
  }

  Widget viewByGender() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                genderString.tr,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    maleString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.viewFromMale.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    femaleString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.viewFromFemale.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    otherString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.viewFromOther.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    noSpecifiedString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.viewFromGenderNotDisclosed
                      .toString()),
                ],
              ),
            ],
          ).hp(DesignConstants.horizontalPadding));
  }

  Widget viewByNetwork() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                networkString.tr,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    followersString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.viewFromFollowers
                      .toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    nonFollowersString.tr,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.viewFromNonFollowers
                      .toString()),
                ],
              ),
            ],
          ).hp(DesignConstants.horizontalPadding));
  }

  Widget profileActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLargeText(
          profileActivityString.tr,
          weight: TextWeight.bold,
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyMediumText(
              commentsString.tr,
              weight: TextWeight.medium,
            ),
            BodyMediumText(widget.post.totalComment.toString()),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyMediumText(
              likesString.tr,
              weight: TextWeight.medium,
            ),
            BodyMediumText(widget.post.totalLike.toString()),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     BodyMediumText(
        //       saved,
        //       weight: TextWeight.medium,
        //     ),
        //     BodyMediumText('20'),
        //   ],
        // ),
      ],
    ).hp(DesignConstants.horizontalPadding);
  }
}

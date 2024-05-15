import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../model/post_model.dart';
import '../profile/other_user_profile.dart';
import 'comments_screen.dart';

class EnlargeImageViewScreen extends StatefulWidget {
  final PostModel model;
  final VoidCallback? handler;

  const EnlargeImageViewScreen({Key? key, required this.model, this.handler})
      : super(key: key);

  @override
  EnlargeImageViewState createState() => EnlargeImageViewState();
}

class EnlargeImageViewState extends State<EnlargeImageViewScreen> {
  late PostModel? model;
  late File file;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ThemeIconWidget(
                      ThemeIcon.backArrow,
                      size: 20,
                    ).ripple(() {
                      Get.back();
                    }),
                    const Spacer(),
                    model == null
                        ? Container()
                        : Heading6Text(
                                model!.isReported
                                    ? reportedString.tr
                                    : reportString.tr,
                                weight: TextWeight.medium)
                            .ripple(() {
                            openReportPostPopup();
                          }),
                  ],
                ),
                model == null
                    ? Container()
                    : Positioned(
                        left: 0,
                        right: 0,
                        child: Center(
                          child: InkWell(
                              onTap: () {
                                Get.to(() =>
                                    OtherUserProfile(userId: model!.user.id));
                              },
                              child: Heading5Text(
                                model!.user.userName,
                                weight: TextWeight.medium,
                              )),
                        ),
                      ),
              ],
            ).hp(DesignConstants.horizontalPadding),
            divider().vP8,
            Expanded(
              child: Stack(children: [
                CachedNetworkImage(
                        imageUrl: widget.model.gallery.first.filePath)
                    .addPinchAndZoom(),
                model == null
                    ? Container()
                    : Positioned(
                        bottom: 40,
                        left: 15,
                        right: 15,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () => likeUnlikeApiCall(),
                                        child: ThemeIconWidget(
                                            model!.isLike
                                                ? ThemeIcon.filledStar
                                                : ThemeIcon.star,
                                            size: 25)),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    BodyLargeText(
                                        model!.totalLike > 1
                                            ? '${model!.totalLike} ${likesString.tr}'
                                            : '${model!.totalLike} ${likeString.tr}',
                                        weight: TextWeight.medium)
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    InkWell(
                                        onTap: () => openComments(),
                                        child: const ThemeIconWidget(
                                            ThemeIcon.message)),
                                    InkWell(
                                      onTap: () => openComments(),
                                      child: model!.totalComment > 0
                                          ? Heading5Text(
                                              '${model!.totalComment} ${commentsString.tr}',
                                            )
                                          : Container(),
                                    )
                                  ])
                            ]),
                      )
              ]),
            ),
          ],
        ));
  }

  void openReportPostPopup() {
    if (!model!.isReported) {
      showModalBottomSheet(
          context: context,
          builder: (context) => Wrap(
                children: [
                  Heading3Text(wantToReportString.tr,
                          weight: TextWeight.semiBold)
                      .p16,
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.camera),
                      title: Heading4Text(reportString.tr,
                          weight: TextWeight.regular),
                      onTap: () async {
                        Navigator.of(context).pop();
                        reportPostApiCall();
                      }),
                  divider(),
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.close),
                      title: Heading4Text(cancelString.tr,
                          weight: TextWeight.regular),
                      onTap: () => Navigator.of(context).pop()),
                ],
              ));
    }
  }

  void openComments() {
    Get.to(() => CommentsScreen(
        model: model!,
        isPopup: true,
        commentPostedCallback: () {
          model!.totalComment += 1;
        },
        commentDeletedCallback: () {
          model!.totalComment -= 1;
        },
        handler: () {
          if (widget.handler != null) {
            widget.handler!();
          }

          setState(() {});
        }).round(40));
  }

  void likeUnlikeApiCall() {
    model!.isLike = !model!.isLike;
    model!.totalLike =
        model!.isLike ? (model!.totalLike) + 1 : (model!.totalLike) - 1;

    if (widget.handler != null) {
      widget.handler!();
    }

    setState(() {});

    PostApi.likeUnlikePost(like: !model!.isLike, postId: model!.id);
  }

  void reportPostApiCall() {
    model!.isReported = true;
    if (widget.handler != null) {
      widget.handler!();
    }

    PostApi.reportPost(
        postId: model!.id,
        resultCallback: () {
          AppUtil.showToast(
              message: postReportedSuccessfullyString.tr, isSuccess: true);
        });
  }
}

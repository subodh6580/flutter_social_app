import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../apiHandler/apis/users_api.dart';
import '../model/comment_model.dart';
import '../model/post_gallery.dart';
import '../model/search_model.dart';
import '../screens/dashboard/posts.dart';
import '../screens/home_feed/post_media_full_screen.dart';
import '../screens/profile/other_user_profile.dart';

class CommentTile extends StatefulWidget {
  final CommentModel model;
  final Function(CommentModel) replyActionHandler;
  final Function(CommentModel) deleteActionHandler;
  final Function(CommentModel) favActionHandler;
  final Function(CommentModel) reportActionHandler;
  final Function(CommentModel) loadMoreChildCommentsActionHandler;

  const CommentTile({
    Key? key,
    required this.model,
    required this.replyActionHandler,
    required this.deleteActionHandler,
    required this.favActionHandler,
    required this.reportActionHandler,
    required this.loadMoreChildCommentsActionHandler,
  }) : super(key: key);

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool isFavourite = false;

  @override
  void initState() {
    isFavourite = widget.model.isFavourite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: widget.model.userPicture,
                name: widget.model.user!.userName.isEmpty
                    ? widget.model.user!.name
                    : widget.model.user!.userName,
                size: widget.model.level == 1 ? 35 : 20,
              ).ripple(() {
                Get.to(() => OtherUserProfile(
                      userId: widget.model.userId,
                    ));
              }),
              const SizedBox(width: 10),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          BodyMediumText(
                            widget.model.userName,
                            weight: TextWeight.medium,
                          ).rP8,
                          if (widget.model.user?.isVerified == true)
                            verifiedUserTag().rP4,
                          BodySmallText(
                            widget.model.commentTime,
                            weight: TextWeight.semiBold,
                            color:
                                AppColorConstants.mainTextColor.withOpacity(0.5),
                          ),
                        ],
                      ).ripple(() {
                        Get.to(() => OtherUserProfile(
                              userId: widget.model.userId,
                            ));
                      }),
                      const Spacer(),
                      ThemeIconWidget(
                        isFavourite ? ThemeIcon.favFilled : ThemeIcon.fav,
                        color: isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor,
                      ).ripple(() {
                        setState(() {
                          isFavourite = !isFavourite;
                          widget.model.isFavourite = !widget.model.isFavourite;
                        });
                        widget.favActionHandler(widget.model);
                      }),
                    ],
                  ),
                  widget.model.type == CommentType.text
                      ? showCommentText()
                      : showCommentMedia(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      if (widget.model.canReply)
                        BodySmallText(
                          replyString.tr,
                          weight: TextWeight.semiBold,
                        ).rp(20).ripple(() {
                          widget.replyActionHandler(widget.model);
                        }),
                      if (widget.model.user?.isMe == true)
                        BodySmallText(
                          deleteString.tr,
                          weight: TextWeight.semiBold,
                          color: Colors.red,
                        ).ripple(() {
                          widget.deleteActionHandler(widget.model);
                        }),
                      if (widget.model.user?.isMe == false)
                        BodySmallText(
                          reportString.tr,
                          weight: TextWeight.semiBold,
                          color: Colors.red,
                        ).ripple(() {
                          widget.reportActionHandler(widget.model);
                        }),
                    ],
                  )
                ],
              ))
            ],
          ),
          Column(
            children: [
              for (CommentModel comment in widget.model.replies)
                CommentTile(
                    model: comment,
                    replyActionHandler: (comment) {
                      widget.reportActionHandler(comment);
                    },
                    deleteActionHandler: (comment) {
                      widget.deleteActionHandler(comment);
                    },
                    favActionHandler: (comment) {
                      widget.favActionHandler(comment);
                    },
                    reportActionHandler: (comment) {
                      widget.reportActionHandler(comment);
                    },
                    loadMoreChildCommentsActionHandler: (comment) {
                      widget.loadMoreChildCommentsActionHandler(comment);
                    }).setPadding(left: 50, top: 15)
            ],
          ),
          if (widget.model.pendingReplies > 0)
            BodySmallText(
              '${viewString.tr} ${widget.model.pendingReplies} ${moreRepliesString.tr}',
              weight: TextWeight.bold,
              color: AppColorConstants.mainTextColor,
            ).setPadding(top: 25, left: 50).ripple(() {
              widget.loadMoreChildCommentsActionHandler(widget.model);
            }),
        ]);
  }

  showCommentText() {
    return DetectableText(
      text: widget.model.comment,
      detectionRegExp: RegExp(
        "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
        multiLine: true,
      ),
      detectedStyle: TextStyle(
          fontSize: FontSizes.b3,
          fontWeight: TextWeight.semiBold,
          color: AppColorConstants.mainTextColor),
      basicStyle: TextStyle(
          fontSize: FontSizes.b3, color: AppColorConstants.mainTextColor),
      onTap: (tappedText) {
        commentTextTapHandler(text: tappedText);
      },
    );
  }

  showCommentMedia() {
    return CachedNetworkImage(
      imageUrl: widget.model.filename,
      height: 150,
      width: 150,
      fit: BoxFit.cover,
    ).round(10).tP16.ripple(() {
      Navigator.push(
        Get.context!,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              PostMediaFullScreen(gallery: [
            PostGallery(
              id: 0,
              postId: 0,
              fileName: "",
              filePath: widget.model.filename,
              height: 0,
              width: 0,
              mediaType: 1, //  image=1, video=2, audio=3
            )
          ]),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  commentTextTapHandler({required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
            hashTag: text.replaceAll('#', ''),
          ));
    } else {
      String userTag = text.replaceAll('@', '');

      UserSearchModel searchModel = UserSearchModel();
      searchModel.isExactMatch = 1;
      searchModel.searchText = userTag;
      UsersApi.searchUsers(
          searchModel: searchModel,
          page: 1,
          resultCallback: (result, metadata) {
            if (result.isNotEmpty) {
              Get.to(() => OtherUserProfile(userId: result.first.id));
            }
          });
    }
  }
}

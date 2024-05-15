import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/actionSheets/action_sheet1.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/post/select_media.dart';
import '../../model/generic_item.dart';
import '../chat/chat_detail.dart';

class ClubDetail extends StatefulWidget {
  final ClubModel club;
  final VoidCallback needRefreshCallback;
  final Function(ClubModel) deleteCallback;

  const ClubDetail(
      {Key? key,
      required this.club,
      required this.needRefreshCallback,
      required this.deleteCallback})
      : super(key: key);

  @override
  ClubDetailState createState() => ClubDetailState();
}

class ClubDetailState extends State<ClubDetail> {
  final ClubDetailController _clubDetailController = ClubDetailController();
  final ChatDetailController _chatDetailController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final PostController _postController = Get.find();

  final _controller = ScrollController();

  @override
  void initState() {
    _clubDetailController.setClub(widget.club);
    refreshPosts();
    _clubDetailController.getClubJoinRequests(clubId: widget.club.id!);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _clubDetailController.clear();
  }

  refreshPosts() {
    PostSearchQuery query = PostSearchQuery();
    query.clubId = widget.club.id!;

    _postController.setPostSearchQuery(
        query: query,
        callback: () {
          _refreshController.refreshCompleted();
        });
    // _clubDetailController.getPosts(
    //     clubId: ,
    //     callback: () {
    //       _refreshController.refreshCompleted();
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton:
          _clubDetailController.club.value!.createdByUser!.isMe
              ? Container(
                  height: 50,
                  width: 50,
                  color: AppColorConstants.themeColor,
                  child: const ThemeIconWidget(
                    ThemeIcon.edit,
                    size: 25,
                    color: Colors.white,
                  ),
                ).circular.ripple(() {
                  Future.delayed(
                    Duration.zero,
                    () => showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddPostScreen(
                                postType: PostType.club,
                                clubId: _clubDetailController.club.value!.id!)),
                  );
                })
              : null,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                          height: 350,
                          child: CachedNetworkImage(
                            imageUrl: _clubDetailController.club.value!.image!,
                            fit: BoxFit.cover,
                          )
                          // CachedNetworkImage(

                          ),
                      const SizedBox(
                        height: 24,
                      ),
                      BodyLargeText(_clubDetailController.club.value!.name!,
                              weight: TextWeight.medium)
                          .hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const ThemeIconWidget(ThemeIcon.userGroup),
                          const SizedBox(
                            width: 5,
                          ),
                          BodyMediumText(
                            _clubDetailController.club.value!.groupType,
                            weight: TextWeight.medium,
                          ),
                          const ThemeIconWidget(
                            ThemeIcon.circle,
                            size: 8,
                          ).hP8,
                          BodyMediumText(
                                  '${_clubDetailController.club.value!.totalMembers!.formatNumber} ${clubMembersString.tr}',
                                  weight: TextWeight.regular)
                              .ripple(() {
                            Get.to(() => ClubMembers(
                                club: _clubDetailController.club.value!));
                          })
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 12,
                      ),
                      buttonsWidget().hp(DesignConstants.horizontalPadding),
                    ],
                  );
                }),
                Obx(() => SizedBox(
                      height: (_clubDetailController.posts.length * 500) +
                          (_clubDetailController.posts.length * 40),
                      child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, index) {
                            return PostCard(
                              model: _clubDetailController.posts[index],
                              // likeTapHandler: () {},
                              removePostHandler: () {},
                              blockUserHandler: () {
                                // _homeController.removeUsersAllPostFromList(model);
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, index) {
                            return const SizedBox(
                              height: 40,
                            );
                          },
                          itemCount: _clubDetailController.posts.length),
                    ).vP16)
              ]))
            ],
          ),
          appBar()
        ],
      ),
    );
  }

  Widget buttonsWidget() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_clubDetailController.club.value!.createdByUser!.isMe == false)
          Container(
                  // width: 40,
                  height: 30,
                  color: AppColorConstants.themeColor.withOpacity(0.2),
                  child: Row(
                    children: [
                      Icon(
                        _clubDetailController.club.value!.isJoined == true
                            ? Icons.exit_to_app
                            : Icons.add,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(_clubDetailController
                                  .club.value!.isJoined ==
                              true
                          ? joinedString.tr
                          : _clubDetailController.club.value!.isRequestBased ==
                                  true
                              ? _clubDetailController.club.value!.isRequested ==
                                      true
                                  ? requestedString.tr
                                  : requestJoinString.tr
                              : joinString.tr)
                    ],
                  ).hP8)
              .round(5)
              .ripple(() {
            if (_clubDetailController.club.value!.isRequested == false) {
              if (_clubDetailController.club.value!.isJoined == true) {
                _clubDetailController.leaveClub();
              } else {
                _clubDetailController.joinClub();
              }
            }
          }).rP8,
        if (_clubDetailController.club.value!.enableChat == 1 &&
            _clubDetailController.club.value!.isJoined == true)
          Container(
                  // width: 40,
                  height: 30,
                  color: AppColorConstants.themeColor.withOpacity(0.2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat,
                        size: 15,
                        color: AppColorConstants.iconColor,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(chatString.tr)
                    ],
                  ).hP8)
              .round(5)
              .ripple(() {
            EasyLoading.show(status: loadingString.tr);
            _chatDetailController.getRoomDetail(
                _clubDetailController.club.value!.chatRoomId!, (room) {
              EasyLoading.dismiss();
              Get.to(() => ChatDetail(chatRoom: room));
            });
          }).rP8,
        if (_clubDetailController.club.value!.createdByUser!.isMe)
          Container(
                  // width: 40,
                  height: 30,
                  color: AppColorConstants.themeColor.withOpacity(0.2),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/request.png',
                        fit: BoxFit.contain,
                        color: AppColorConstants.iconColor,
                        height: 15,
                        width: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(inviteString.tr)
                    ],
                  ).hP8)
              .round(5)
              .ripple(() {
            Get.to(() => InviteUsersToClub(
                  clubId: widget.club.id!,
                ));
          }),
      ],
    );
  }

  Widget appBar() {
    return Positioned(
      child: Container(
        height: 150.0,
        width: Get.width,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.5),
                  Colors.grey.withOpacity(0.0),
                ],
                stops: const [
                  0.0,
                  0.5,
                  1.0
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: Colors.white,
            ).ripple(() {
              Get.back();
            }),
            widget.club.amIAdmin
                ? Row(
                    children: [
                      Obx(() => _clubDetailController.joinRequests.isEmpty
                          ? Container()
                          : Stack(
                              children: [
                                Container(
                                  color: AppColorConstants.themeColor
                                      .withOpacity(0.2),
                                  child: const ThemeIconWidget(
                                    ThemeIcon.request,
                                    size: 20,
                                    color: Colors.white,
                                  ).p8.ripple(() {
                                    Get.to(() => ClubJoinRequests(
                                          club: widget.club,
                                        ));
                                  }),
                                ).circular,
                                Positioned(
                                    right: 0,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      color: AppColorConstants.red,
                                    ).circular)
                              ],
                            )),
                      const SizedBox(width: 10),
                      const ThemeIconWidget(
                        ThemeIcon.setting,
                        size: 20,
                        color: Colors.white,
                      ).ripple(() {
                        Get.to(() => ClubSettings(
                              club: widget.club,
                              deleteClubCallback: (club) {
                                Get.back();
                                widget.deleteCallback(club);
                              },
                            ));
                      }),
                    ],
                  )
                : const SizedBox(
                    width: 20,
                  )
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  postsView() {
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              itemCount: _clubDetailController.posts.length,
              itemBuilder: (context, index) {
                PostModel model = _clubDetailController.posts[index - 3];

                return PostCard(
                  model: model,
                  removePostHandler: () {
                    _clubDetailController.removePostFromList(model);
                  },
                  blockUserHandler: () {
                    _clubDetailController.removePostFromList(model);
                  },
                );
              },
              separatorBuilder: (context, index) {
                if (index == 1) {
                  return Container();
                } else {
                  return const SizedBox(
                    height: 20,
                  );
                }
              })
          .addPullToRefresh(
              refreshController: _refreshController,
              enablePullUp: false,
              enablePullDown: true,
              onRefresh: refreshPosts,
              onLoading: () {});
    });
  }

  showActionSheet(PostModel post) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                    id: '1', title: shareString.tr, icon: ThemeIcon.share),
                GenericItem(
                    id: '2', title: reportString.tr, icon: ThemeIcon.report),
                GenericItem(
                    id: '3', title: hideString.tr, icon: ThemeIcon.hide),
              ],
              itemCallBack: (item) {},
            ));
  }
}

import '../../components/notification_tile.dart';
import '../../controllers/notification/notifications_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/notification_modal.dart';
import '../competitions/competition_detail_screen.dart';
import '../home_feed/comments_screen.dart';
import '../post/single_post_detail.dart';
import '../profile/follow_requests.dart';
import '../profile/other_user_profile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController =
      NotificationController();
  final ProfileController _profileController = Get.find();

  @override
  void initState() {
    _notificationController.getNotifications();
    _notificationController.getFollowRequests(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBarWithTrailingWidget(
              title: notificationsString,
              widget: BodyLargeText(
                filterString,
                weight: TextWeight.semiBold,
              ).ripple(() {
                filterNotifications();
              }),
            ),
            Obx(() => _notificationController.followRequests.isEmpty
                ? Container()
                : Container(
                    height: 80,
                    color: AppColorConstants.themeColor.withOpacity(0.1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ThemeIconWidget(
                          ThemeIcon.request,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyMediumText(
                                followRequestsString.tr,
                                weight: TextWeight.semiBold,
                              ),
                              BodySmallText(
                                acceptFollowRequestsString.tr,
                                weight: TextWeight.semiBold,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const ThemeIconWidget(ThemeIcon.nextArrow),
                      ],
                    ).hp(DesignConstants.horizontalPadding),
                  ).round(20).ripple(() {
                    Get.to(() => const FollowRequestList());
                  }).p(DesignConstants.horizontalPadding)),
            Expanded(
              child: GetBuilder<NotificationController>(
                  init: _notificationController,
                  builder: (ctx) {
                    return _notificationController
                            .groupedNotifications.keys.isNotEmpty
                        ? ListView.separated(
                            padding: EdgeInsets.only(
                                top: 20,
                                left: DesignConstants.horizontalPadding,
                                right: DesignConstants.horizontalPadding,
                                bottom: 50),
                            itemCount: _notificationController
                                .groupedNotifications.keys.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = _notificationController
                                  .groupedNotifications.keys
                                  .toList()[index];
                              List<NotificationModel> notifications =
                                  _notificationController
                                          .groupedNotifications[key] ??
                                      [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Heading5Text(
                                    key,
                                    weight: TextWeight.bold,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  for (NotificationModel notification
                                      in notifications)
                                    Column(
                                      children: [
                                        NotificationTileType4(
                                          notification: notification,
                                          followBackUserHandler: () {
                                            _profileController.followUser(
                                                notification.actionBy!);
                                            _notificationController
                                                .getNotifications();
                                          },
                                        ).ripple(() {
                                          handleNotificationTap(notification);
                                        }),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    ),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return divider(height: 0.2).vP8;
                            })
                        : emptyData(
                            title: noNotificationFoundString,
                            subTitle: '',
                          );
                  }),
            ),
          ],
        ));
  }

  filterNotifications() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          BodyLargeText(
            filterString,
          ),
          const SizedBox(
            height: 20,
          ),
          divider().vP8,
          Column(
            children: [
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        commentsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(NotificationType.comment)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(NotificationType.comment);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        likesString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(NotificationType.like)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(NotificationType.like);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        followsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(NotificationType.follow)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(NotificationType.follow);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        giftsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(NotificationType.gift)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(NotificationType.gift);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        clubsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(NotificationType.clubInvitation)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(NotificationType.clubInvitation);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        competitionString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(NotificationType.competitionAdded)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(NotificationType.competitionAdded);
              }),
              const SizedBox(
                height: 20,
              ),
              AppThemeButton(
                  text: doneString,
                  onPress: () {
                    _notificationController.filterNotifications();
                    Get.back();
                  })
            ],
          ).hp16,
        ],
      ),
    ).topRounded(40));
  }

  handleNotificationTap(NotificationModel notification) {
    if (notification.type == NotificationType.follow) {
      int userId = notification.actionBy!.id;
      Get.to(() => OtherUserProfile(userId: userId));
    } else if (notification.type == NotificationType.comment) {
      int postId = notification.post!.id;
      Get.to(() => CommentsScreen(
            postId: postId,
            isPopup: false,
            handler: () {},
            commentPostedCallback: () {},
            commentDeletedCallback: () {},
          ));
    } else if (notification.type == NotificationType.like) {
      Get.to(() => SinglePostDetail(postId: notification.post!.id));
    } else if (notification.type == NotificationType.competitionAdded) {
      int competitionId = notification.competition!.id;
      Get.to(() => CompetitionDetailScreen(
            competitionId: competitionId,
            refreshPreviousScreen: () {},
          ));
    }
    // else if (notification.type == 7) {
    //   Get.to(() => SinglePostDetail(
    //         postId: notification.post!.id,
    //       ));
    // }
  }
}

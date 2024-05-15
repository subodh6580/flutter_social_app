import 'package:flutter/gestures.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../model/notification_modal.dart';
import '../screens/profile/other_user_profile.dart';

class NotificationTileType4 extends StatelessWidget {
  final NotificationModel notification;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? dateTextStyle;
  final Color? borderColor;
  final VoidCallback? followBackUserHandler;

  const NotificationTileType4(
      {Key? key,
        required this.notification,
        this.backgroundColor,
        this.titleTextStyle,
        this.subTitleTextStyle,
        this.dateTextStyle,
        this.followBackUserHandler,
        this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (notification.actionBy != null)
          UserAvatarView(
            user: notification.actionBy!,
            hideLiveIndicator: true,
            hideOnlineIndicator: true,
            size: 40,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  maxLines: 2,
                  text: TextSpan(children: [
                    TextSpan(
                      text: notification.actionBy?.userName ?? '',
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor,
                          fontWeight: TextWeight.semiBold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (notification.actionBy != null) {
                            openProfile(notification.actionBy!.id);
                          }
                        },
                    ),
                    TextSpan(
                      text: ' ${notificationMessage(notification.type)}',
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor,
                          fontWeight: TextWeight.medium),
                    ),
                    TextSpan(
                      text: ' ${notification.notificationTime}',
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor,
                          fontWeight: TextWeight.semiBold),
                    ),
                  ]))
            ],
          ).setPadding(top: 16, bottom: 16, left: 12, right: 12),
        ),
        if ((notification.type == NotificationType.like ||
            notification.type == NotificationType.comment) &&
            notification.post!.gallery.isNotEmpty)
          CachedNetworkImage(
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              imageUrl: notification.post!.gallery.first.thumbnail)
              .round(20),
      ],
    ).hP8;
  }

  void openProfile(int userId) async {
    Get.to(() => OtherUserProfile(userId: userId));
  }

  followBack() {
    followBackUserHandler!();
  }

  String notificationMessage(NotificationType type) {
    if (type == NotificationType.follow) {
      return startedFollowingYouString.tr;
    } else if (type == NotificationType.followRequest) {
      return sentYourFollowRequestString.tr;
    } else if (type == NotificationType.comment) {
      return commentedOnYourPostString.tr;
    } else if (type == NotificationType.like) {
      return likedYourPostString.tr;
    } else if (type == NotificationType.competitionAdded) {

      return adminAddedNewCompetitionString.tr;
    } else if (type == NotificationType.supportRequest) {
      return adminRepliedOnYourSupportRequestString.tr;
    } else if (type == NotificationType.verification) {
      return congratsYourVerificationIsApprovedString.tr;
    }
    return '';
  }
}

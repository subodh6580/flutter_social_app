import 'package:flutter/material.dart';
import '../../helper/localization_strings.dart';
import '../../model/club_invitation.dart';
import '../../model/club_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/number_extension.dart';
import '../../universal_components/app_buttons.dart';
import 'package:get/get.dart';

import '../../util/app_config_constants.dart';
import '../custom_texts.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  final VoidCallback joinBtnClicked;
  final VoidCallback previewBtnClicked;
  final VoidCallback leaveBtnClicked;

  const ClubCard(
      {Key? key,
      required this.club,
      required this.joinBtnClicked,
      required this.leaveBtnClicked,
      required this.previewBtnClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: club.image!,
              fit: BoxFit.cover,
            ).topRounded(10).ripple(() {
              previewBtnClicked();
            }),
          ),
          const SizedBox(
            height: 5,
          ),
          BodyLargeText(
            club.name!,
            maxLines: 1,
            weight: TextWeight.semiBold,
          ).hP8,
          const SizedBox(
            height: 5,
          ),
          BodySmallText(
            '${club.totalMembers!.formatNumber} ${clubMembersString.tr}',
          ).hP8,
          const SizedBox(
            height: 10,
          ),
          !club.createdByUser!.isMe
              ? SizedBox(
                  height: 40,
                  width: 120,
                  child: AppThemeButton(
                      text: club.isJoined == true
                          ? leaveClubString.tr
                          : club.isRequested == true
                              ? requestedString.tr
                              : club.isRequestBased == true
                                  ? requestJoinString.tr
                                  : joinString.tr,
                      backgroundColor: club.isJoined == true
                          ? AppColorConstants.red
                          : AppColorConstants.themeColor,
                      onPress: () {
                        if (club.isJoined == true) {
                          leaveBtnClicked();
                        } else {
                          joinBtnClicked();
                        }
                      }))
              : SizedBox(
                  height: 40,
                  width: 120,
                  child: AppThemeButton(
                      text: adminString,
                      backgroundColor: AppColorConstants.themeColor,
                      onPress: () {})),
        ],
      ),
    ).round(15);
  }
}

class ClubInvitationCard extends StatelessWidget {
  final ClubInvitation invitation;
  final VoidCallback acceptBtnClicked;
  final VoidCallback previewBtnClicked;
  final VoidCallback declineBtnClicked;

  const ClubInvitationCard(
      {Key? key,
      required this.invitation,
      required this.acceptBtnClicked,
      required this.declineBtnClicked,
      required this.previewBtnClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 250,
      height: 300,
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: invitation.club!.image!,
              fit: BoxFit.cover,
            ).topRounded(10).ripple(() {
              previewBtnClicked();
            }),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading4Text(invitation.club!.name!, weight: TextWeight.bold).vP8,
              BodyLargeText(
                '${invitation.club!.totalMembers!.formatNumber} ${clubMembersString.tr}',
              ),
              SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppThemeButton(
                          width: Get.width * 0.4,
                          text: acceptString.tr,
                          onPress: () {
                            acceptBtnClicked();
                          }),
                      AppThemeBorderButton(
                          width: Get.width * 0.4,
                          text: declineString.tr,
                          onPress: () {
                            declineBtnClicked();
                          })
                    ],
                  )).vP16,
            ],
          ).hp(DesignConstants.horizontalPadding),
        ],
      ),
    ).round(15);
  }
}

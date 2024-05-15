import 'package:foap/helper/imports/common_import.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../controllers/live/agora_live_controller.dart';
import '../controllers/profile/profile_controller.dart';
import '../model/call_model.dart';
import '../model/club_join_request.dart';
import '../model/club_member_model.dart';
import '../model/gift_model.dart';
import '../model/story_model.dart';
import '../screens/profile/other_user_profile.dart';
import '../screens/profile/update_profile.dart';
import '../screens/settings_menu/settings_controller.dart';

class FollowUnfollowButton extends StatelessWidget {
  final UserModel user;
  final VoidCallback? followCallback;
  final VoidCallback? unFollowCallback;

  const FollowUnfollowButton(
      {Key? key,
      required this.user,
      required this.followCallback,
      required this.unFollowCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 120,
      child: user.followingStatus == FollowingStatus.notFollowing
          ? AppThemeBorderButton(
              text: user.isFollower == true
                  ? followBackString.tr
                  : followString.tr,
              onPress: () {
                if (followCallback != null) {
                  followCallback!();
                }
              })
          : user.followingStatus == FollowingStatus.requested
              ? AppThemeBorderButton(
                  text: requestedString.tr,
                  backgroundColor:
                      AppColorConstants.themeColor.withOpacity(0.2),
                  onPress: () {
                    if (unFollowCallback != null) {
                      unFollowCallback!();
                    }
                  })
              : AppThemeButton(
                  text: unFollowString.tr,
                  onPress: () {
                    if (unFollowCallback != null) {
                      unFollowCallback!();
                    }
                  }),
    );
  }
}

class UserInfo extends StatelessWidget {
  final UserModel model;

  const UserInfo({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatarView(
          user: model,
          size: 40,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BodyLargeText(
                    model.name ?? model.userName,
                    weight: TextWeight.semiBold,
                    maxLines: 1,
                  ),
                  if (model.isVerified) verifiedUserTag()
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              model.country != null
                  ? BodySmallText(
                      '${model.country},${model.city}',
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectableUserCard extends StatefulWidget {
  final UserModel model;
  final bool isSelected;
  final VoidCallback? selectionHandler;

  const SelectableUserCard(
      {Key? key,
      required this.model,
      required this.isSelected,
      this.selectionHandler})
      : super(key: key);

  @override
  SelectableUserCardState createState() => SelectableUserCardState();
}

class SelectableUserCardState extends State<SelectableUserCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Stack(
            children: [
              UserAvatarView(
                user: widget.model,
                size: 50,
              ),
              widget.isSelected == true
                  ? Positioned(
                      child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.black45,
                      child: const Center(
                        child: ThemeIconWidget(
                          ThemeIcon.checkMark,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ).round(15))
                  : Container()
            ],
          ).ripple(
            () {
              widget.selectionHandler!();
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            BodyLargeText(widget.model.userName,
                maxLines: 1, weight: TextWeight.medium),
            if (widget.model.isVerified) verifiedUserTag()
          ],
        )
      ],
    );
  }
}

class SelectableUserTile extends StatefulWidget {
  final UserModel model;
  final bool? canSelect;
  final bool? isSelected;
  final VoidCallback? selectionHandler;

  const SelectableUserTile(
      {Key? key,
      required this.model,
      this.canSelect,
      this.isSelected,
      this.selectionHandler})
      : super(key: key);

  @override
  SelectableUserTileState createState() => SelectableUserTileState();
}

class SelectableUserTileState extends State<SelectableUserTile> {
  final UserProfileManager _userProfileManager = Get.find();
  late final UserModel model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserInfo(model: model),
        const Spacer(),
        widget.canSelect == true
            ? ThemeIconWidget(
                widget.isSelected == true
                    ? ThemeIcon.checkMarkWithCircle
                    : ThemeIcon.circleOutline,
                color: AppColorConstants.themeColor,
                size: 25,
              )
            : Container()
      ],
    ).ripple(
      () {
        if (widget.canSelect != true) {
          if (model.id == _userProfileManager.user.value!.id) {
            Get.to(() => const UpdateProfile());
          } else {
            Get.to(() => OtherUserProfile(
                  userId: model.id,
                ));
          }
        }

        if (widget.selectionHandler != null) {
          widget.selectionHandler!();
        }
      },
    );
  }
}

class UserTile extends StatelessWidget {
  final UserModel profile;

  final VoidCallback? followCallback;
  final VoidCallback? unFollowCallback;
  final VoidCallback? viewCallback;

  final VoidCallback? chatCallback;
  final VoidCallback? audioCallCallback;
  final VoidCallback? videoCallCallback;

  final VoidCallback? sendCallback;

  const UserTile({
    Key? key,
    required this.profile,
    this.followCallback,
    this.unFollowCallback,
    this.viewCallback,
    this.chatCallback,
    this.audioCallCallback,
    this.videoCallCallback,
    this.sendCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    final AgoraLiveController agoraLiveController = Get.find();
    final SettingsController settingsController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              UserAvatarView(
                user: profile,
                size: 40,
                onTapHandler: () {
                  Live live = Live(
                      channelName: profile.liveCallDetail!.channelName,
                      // isHosting: false,
                      mainHostUserDetail: profile,
                      // battleUsers: [],
                      token: profile.liveCallDetail!.token,
                      id: profile.liveCallDetail!.id);
                  agoraLiveController.joinAsAudience(
                    live: live,
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          profile.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (profile.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    profile.country != null
                        ? BodyMediumText(
                            '${profile.city!}, ${profile.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ).ripple(() {
            if (viewCallback == null) {
              profileController.setUser(profile);
              Get.to(() => OtherUserProfile(userId: profile.id));
            } else {
              viewCallback!();
            }
          }),
        ),
        // const Spacer(),
        if (followCallback != null && profile.isMe == false)
          FollowUnfollowButton(
            user: profile,
            followCallback: followCallback,
            unFollowCallback: unFollowCallback,
          ),
        if (chatCallback != null)
          Row(
            children: [
              if (settingsController.setting.value!.enableChat)
                const ThemeIconWidget(
                  ThemeIcon.chat,
                  size: 20,
                ).rP16.ripple(() {
                  chatCallback!();
                }),
              if (settingsController.setting.value!.enableAudioCalling)
                const ThemeIconWidget(
                  ThemeIcon.mobile,
                  size: 20,
                ).rP16.ripple(() {
                  audioCallCallback!();
                }),
              if (settingsController.setting.value!.enableVideoCalling)
                const ThemeIconWidget(
                  ThemeIcon.videoCamera,
                  size: 20,
                ).ripple(() {
                  videoCallCallback!();
                }),
            ],
          ),
        if (sendCallback != null)
          SizedBox(
            height: 30,
            width: 80,
            child: ProgressButton.icon(iconedButtons: {
              ButtonState.idle: IconedButton(
                  text: sendString.tr,
                  icon: const Icon(Icons.send, color: Colors.white),
                  color: Colors.deepPurple.shade500),
              ButtonState.loading: IconedButton(
                  text: loadingString.tr, color: Colors.deepPurple.shade700),
              ButtonState.fail: IconedButton(
                  text: failedString.tr,
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  color: Colors.red.shade300),
              ButtonState.success: IconedButton(
                  text: sentString.tr,
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  color: Colors.green.shade400)
            }, onPressed: sendCallback, state: ButtonState.idle),
          )
      ],
    );
  }
}

class InviteUserTile extends StatelessWidget {
  final UserModel profile;

  final VoidCallback? inviteCallback;

  const InviteUserTile({
    Key? key,
    required this.profile,
    this.inviteCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AgoraLiveController agoraLiveController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              UserAvatarView(
                user: profile,
                size: 40,
                onTapHandler: () {
                  Live live = Live(
                      channelName: profile.liveCallDetail!.channelName,
                      // isHosting: false,
                      mainHostUserDetail: profile,
                      // battleUsers: [],
                      token: profile.liveCallDetail!.token,
                      id: profile.liveCallDetail!.id);
                  agoraLiveController.joinAsAudience(
                    live: live,
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          profile.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (profile.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    profile.country != null
                        ? BodyMediumText(
                            '${profile.city!}, ${profile.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ),
        ),
        // const Spacer(),
        SizedBox(
          height: 35,
          width: 120,
          child: AppThemeBorderButton(
              // icon: ThemeIcon.message,
              text: inviteString.tr,
              textStyle: TextStyle(
                  fontSize: FontSizes.b2,
                  fontWeight: TextWeight.medium,
                  color: AppColorConstants.themeColor),
              onPress: () {
                if (inviteCallback != null) {
                  inviteCallback!();
                }
              }),
        ),
      ],
    );
  }
}

class RelationUserTile extends StatelessWidget {
  final UserModel profile;

  final Function(int)? inviteCallback;
  final Function(int)? unInviteCallback;
  final VoidCallback? viewCallback;

  const RelationUserTile({
    Key? key,
    required this.profile,
    this.inviteCallback,
    this.unInviteCallback,
    this.viewCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserAvatarView(
              user: profile,
              size: 40,
            ),
            SizedBox(
              width: Get.width - 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(
                        profile.userName,
                        weight: TextWeight.bold,
                      ),
                      if (profile.isVerified) verifiedUserTag()
                    ],
                  ).bP4,
                  profile.country != null
                      ? BodyMediumText(
                          '${profile.city!}, ${profile.country!}',
                        )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
            // const Spacer(),
          ],
        ).ripple(() {
          if (viewCallback == null) {
            profileController.setUser(profile);
            Get.to(() => OtherUserProfile(userId: profile.id));
          } else {
            viewCallback!();
          }
        }),
        const Spacer(),
        if (inviteCallback != null && profile.isMe == false)
          SizedBox(
            height: 35,
            width: 120,
            child: AppThemeBorderButton(
                // icon: ThemeIcon.message,
                text: inviteString.tr,
                textStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    fontWeight: TextWeight.medium,
                    color: AppColorConstants.themeColor),
                onPress: () {
                  if (inviteCallback != null) {
                    inviteCallback!(profile.id);
                  }
                }),
          ),
      ],
    );
  }
}

class ClubMemberTile extends StatelessWidget {
  final ClubMemberModel member;
  final VoidCallback? removeBtnCallback;
  final VoidCallback? viewCallback;

  const ClubMemberTile({
    Key? key,
    required this.member,
    this.removeBtnCallback,
    this.viewCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AgoraLiveController agoraLiveController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserAvatarView(
              user: member.user!,
              size: 40,
              onTapHandler: () {
                Live live = Live(
                    channelName: member.user!.liveCallDetail!.channelName,
                    // isHosting: false,
                    mainHostUserDetail: member.user!,
                    // battleUsers: [],
                    token: member.user!.liveCallDetail!.token,
                    id: member.user!.liveCallDetail!.id);
                agoraLiveController.joinAsAudience(
                  live: live,
                );
              },
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(member.user!.userName,
                          weight: TextWeight.bold),
                      if (member.user!.isVerified) verifiedUserTag()
                    ],
                  ).bP4,
                  member.user!.country != null
                      ? BodyMediumText(
                          '${member.user!.city!}, ${member.user!.country!}',
                        )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ).ripple(() {
              if (viewCallback != null) {
                viewCallback!();
              }
            }),
            // const Spacer(),
          ],
        ),
        const Spacer(),
        member.isAdmin == 1
            ? SizedBox(
                height: 35,
                width: 120,
                child: Center(
                  child: BodyLargeText(
                    adminString.tr,
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ),
              )
            : removeBtnCallback != null
                ? SizedBox(
                    height: 35,
                    width: 120,
                    child: AppThemeButton(
                        // icon: ThemeIcon.message,
                        text: removeString.tr,
                        onPress: () {
                          if (removeBtnCallback != null) {
                            removeBtnCallback!();
                          }
                        }),
                  )
                : Container(),
      ],
    );
  }
}

class SendMessageUserTile extends StatelessWidget {
  final UserModel profile;
  final ButtonState state;
  final VoidCallback? viewCallback;
  final VoidCallback? sendCallback;

  const SendMessageUserTile({
    Key? key,
    required this.profile,
    required this.state,
    this.viewCallback,
    this.sendCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: UserInfo(model: profile).ripple(() {
            if (viewCallback == null) {
              profileController.setUser(profile);
              Get.to(() => OtherUserProfile(userId: profile.id));
            } else {
              viewCallback!();
            }
          }),
        ),
        // const Spacer(),
        const SizedBox(
          width: 10,
        ),
        sendCallback != null
            ? AbsorbPointer(
                absorbing: state == ButtonState.success,
                child: SizedBox(
                  height: 30,
                  width: 80,
                  child: ProgressButton.icon(
                      radius: 5.0,
                      textStyle: TextStyle(fontSize: FontSizes.b2),
                      iconedButtons: {
                        ButtonState.idle: IconedButton(
                            text: sendString.tr,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 15,
                            ),
                            color: AppColorConstants.themeColor.lighten(0.1)),
                        ButtonState.loading: IconedButton(
                            text: loadingString.tr, color: Colors.white),
                        ButtonState.fail: IconedButton(
                            text: failedString.tr,
                            icon: const Icon(Icons.cancel,
                                color: Colors.white, size: 15),
                            color: AppColorConstants.red),
                        ButtonState.success: IconedButton(
                            text: sentString.tr,
                            icon: const Icon(Icons.check_circle,
                                color: Colors.white, size: 15),
                            color: AppColorConstants.themeColor.darken())
                      },
                      onPressed: sendCallback,
                      state: state),
                ),
              )
            : Container()
      ],
    );
  }
}

class BlockedUserTile extends StatelessWidget {
  final UserModel profile;
  final VoidCallback? unBlockCallback;

  const BlockedUserTile({
    Key? key,
    required this.profile,
    this.unBlockCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UserInfo(model: profile),
        SizedBox(
            height: 35,
            width: 110,
            child: AppThemeBorderButton(
                // icon: ThemeIcon.message,
                text: unblockString.tr,
                textStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    fontWeight: TextWeight.medium,
                    color: AppColorConstants.themeColor),
                onPress: () {
                  if (unBlockCallback != null) {
                    unBlockCallback!();
                  }
                }))
      ],
    );
  }
}

class GifterUserTile extends StatelessWidget {
  final ReceivedGiftModel gift;

  const GifterUserTile({Key? key, required this.gift}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserInfo(model: gift.sender),
        const Spacer(),
        CachedNetworkImage(
          imageUrl: gift.giftDetail.logo,
          height: 40,
          width: 40,
        ),
        const SizedBox(
          width: 5,
        ),
        const ThemeIconWidget(
          ThemeIcon.diamond,
          color: Colors.yellow,
          size: 18,
        ),
        const SizedBox(
          width: 5,
        ),
        BodyLargeText(gift.giftDetail.coins.toString(),
            weight: TextWeight.semiBold)
      ],
    );
  }
}

class ClubJoinRequestTile extends StatelessWidget {
  final ClubJoinRequest request;
  final VoidCallback acceptBtnClicked;
  final VoidCallback declineBtnClicked;
  final VoidCallback viewCallback;

  const ClubJoinRequestTile({
    Key? key,
    required this.request,
    required this.viewCallback,
    required this.acceptBtnClicked,
    required this.declineBtnClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserAvatarView(
              user: request.user!,
              hideLiveIndicator: true,
              size: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(request.user!.userName,
                          weight: TextWeight.bold),
                      if (request.user!.isVerified) verifiedUserTag()
                    ],
                  ).bP4,
                  request.user!.country != null
                      ? BodyMediumText(
                          '${request.user!.city!}, ${request.user!.country!}',
                        )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
            // const Spacer(),
          ],
        ).ripple(() {
          viewCallback();
        }),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
                height: 35,
                width: 120,
                child: AppThemeButton(
                    // icon: ThemeIcon.message,
                    text: acceptString.tr,
                    onPress: () {
                      acceptBtnClicked();
                    })),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
                height: 35,
                width: 120,
                child: AppThemeBorderButton(
                    // icon: ThemeIcon.message,
                    text: declineString.tr,
                    textStyle: TextStyle(
                        fontSize: FontSizes.b2,
                        fontWeight: TextWeight.medium,
                        color: AppColorConstants.themeColor),
                    onPress: () {
                      declineBtnClicked();
                    })),
          ],
        ),
      ],
    );
  }
}

class StoryViewerTile extends StatelessWidget {
  final StoryViewerModel viewer;

  const StoryViewerTile({
    Key? key,
    required this.viewer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: UserInfo(model: viewer.user!)),
        BodyMediumText(
          viewer.viewedAt,
          maxLines: 1,
          color: AppColorConstants.subHeadingTextColor,
        )
        // const Spacer(),
      ],
    );
  }
}

class FollowRequestSenderUserTile extends StatelessWidget {
  final UserModel profile;

  final VoidCallback acceptCallback;
  final VoidCallback declineCallback;

  const FollowRequestSenderUserTile({
    Key? key,
    required this.profile,
    required this.acceptCallback,
    required this.declineCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatarView(
                user: profile,
                size: 40,
                hideLiveIndicator: true,
                hideOnlineIndicator: true,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          profile.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (profile.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    profile.country != null
                        ? BodyMediumText(
                      '${profile.city!}, ${profile.country!}',
                    )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ).ripple(() {
            Get.to(() => OtherUserProfile(
              userId: profile.id,
            ));
          }),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                height: 35,
                width: 120,
                child: AppThemeButton(
                  // icon: ThemeIcon.message,
                    text: acceptString.tr,
                    onPress: () {
                      acceptCallback();
                    }),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 35,
                width: 120,
                child: AppThemeBorderButton(
                    backgroundColor: AppColorConstants.cardColor,
                    // icon: ThemeIcon.message,
                    text: declineString.tr,
                    onPress: () {
                      declineCallback();
                    }),
              )
            ],
          ),
        ],
      ).p(DesignConstants.horizontalPadding),
    ).round(20);
  }
}

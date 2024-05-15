import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/chat/random_chat/choose_profile_category.dart';

import 'package:foap/helper/imports/chat_imports.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_state_button/progress_button.dart';
import '../../components/user_card.dart';
import '../../controllers/chat_and_call/agora_call_controller.dart';
import '../../helper/permission_utils.dart';
import '../../model/call_model.dart';

class SelectUserForChat extends StatefulWidget {
  final Function(UserModel) userSelected;

  const SelectUserForChat({Key? key, required this.userSelected})
      : super(key: key);

  @override
  SelectUserForChatState createState() => SelectUserForChatState();
}

class SelectUserForChatState extends State<SelectUserForChat> {
  final SelectUserForChatController _selectUserForChatController =
      SelectUserForChatController();
  final AgoraCallController _agoraCallController = Get.find();

  @override
  void initState() {
    super.initState();

    _selectUserForChatController.clear();
    _selectUserForChatController.getFollowingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColorConstants.cardColor.darken(),
            width: double.infinity,
            child: Column(
              children: [
                // const SizedBox(
                //   height: 20,
                // ),
                // SearchBar(
                //         showSearchIcon: true,
                //         iconColor: ColorConstants.themeColor,
                //         onSearchChanged: (value) {
                //           selectUserForChatController.searchTextChanged(value);
                //         },
                //         onSearchStarted: () {
                //           //controller.startSearch();
                //         },
                //         onSearchCompleted: (searchTerm) {})
                //     .hP8,
                // divider().tP16,
                Expanded(
                  child: GetBuilder<SelectUserForChatController>(
                      init: _selectUserForChatController,
                      builder: (ctx) {
                        ScrollController scrollController = ScrollController();
                        scrollController.addListener(() {
                          if (scrollController.position.maxScrollExtent ==
                              scrollController.position.pixels) {
                            if (!_selectUserForChatController
                                .followingIsLoading) {
                              _selectUserForChatController.getFollowingUsers();
                            }
                          }
                        });

                        List<UserModel> usersList =
                            _selectUserForChatController.following;
                        return _selectUserForChatController.followingIsLoading
                            ? const ShimmerUsers().hp(DesignConstants.horizontalPadding)
                            : usersList.isNotEmpty
                                ? ListView.separated(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 50),
                                    controller: scrollController,
                                    itemCount: usersList.length + 2,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return SizedBox(
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Container(
                                                      color: AppColorConstants
                                                          .themeColor
                                                          .withOpacity(0.2),
                                                      child: ThemeIconWidget(
                                                        ThemeIcon.group,
                                                        size: 15,
                                                        color: AppColorConstants
                                                            .themeColor,
                                                      ).p8)
                                                  .circular,
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Heading6Text(
                                                createGroupString.tr,
                                                weight: TextWeight.semiBold,
                                              )
                                            ],
                                          ),
                                        ).ripple(() {
                                          Get.back();
                                          Get.to(() =>
                                              const SelectUserForGroupChat());
                                        }).hp(DesignConstants.horizontalPadding);
                                      } else if (index == 1) {
                                        return SizedBox(
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Container(
                                                      color: AppColorConstants
                                                          .themeColor
                                                          .withOpacity(0.2),
                                                      child: ThemeIconWidget(
                                                        ThemeIcon.randomChat,
                                                        size: 15,
                                                        color: AppColorConstants
                                                            .themeColor,
                                                      ).p8)
                                                  .circular,
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Heading6Text(
                                                strangerChatString.tr,
                                                weight: TextWeight.semiBold,
                                              )
                                            ],
                                          ),
                                        ).ripple(() {
                                          Get.to(
                                              () => const ChooseProfileCategory(
                                                    isCalling: false,
                                                  ));
                                        }).hp(DesignConstants.horizontalPadding);
                                      } else {
                                        return UserTile(
                                          profile: usersList[index - 2],
                                          viewCallback: () {
                                            EasyLoading.show(
                                                status:
                                                    loadingString.tr);

                                            widget.userSelected(
                                                usersList[index - 2]);
                                          },
                                          audioCallCallback: () {
                                            Get.back();
                                            initiateAudioCall(
                                                 usersList[index - 2]);
                                          },
                                          chatCallback: () {
                                            EasyLoading.show(
                                                status:
                                                    loadingString.tr);

                                            widget.userSelected(
                                                usersList[index - 2]);
                                          },
                                          videoCallCallback: () {
                                            Get.back();
                                            initiateVideoCall(
                                                usersList[index - 2]);
                                          },
                                        ).hp(DesignConstants.horizontalPadding);
                                      }
                                    },
                                    separatorBuilder: (context, index) {
                                      if (index < 2) {
                                        return divider().vP16;
                                      }

                                      return const SizedBox(
                                        height: 20,
                                      );
                                    },
                                  )
                                : emptyUser(
                                    title: noUserFoundString.tr,
                                    subTitle:
                                        followSomeUserToChatString.tr,
                                  );
                      }),
                ),
              ],
            ),
          ).round(20).p16,
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 50,
            width: 50,
            color: AppColorConstants.backgroundColor,
            child: Center(
              child: ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.iconColor,
                size: 25,
              ),
            ),
          ).circular.ripple(() {
            Get.back();
          }),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void initiateVideoCall(UserModel opponent) {
    PermissionUtils.requestPermission(
        [Permission.camera, Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 2,
          opponent: opponent);

      _agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToCameraForVideoCallString.tr,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToCameraForVideoCallString.tr,
          isSuccess: false);
    });
  }

  void initiateAudioCall(UserModel opponent) {
    PermissionUtils.requestPermission([Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 1,
          opponent: opponent);

      _agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString.tr,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString.tr,
          isSuccess: false);
    });
  }
}

class SelectFollowingUserForMessageSending extends StatefulWidget {
  final Function(UserModel) sendToUserCallback;

  const SelectFollowingUserForMessageSending({
    Key? key,
    required this.sendToUserCallback,
    // this.post,
  }) : super(key: key);

  @override
  SelectFollowingUserForMessageSendingState createState() =>
      SelectFollowingUserForMessageSendingState();
}

class SelectFollowingUserForMessageSendingState
    extends State<SelectFollowingUserForMessageSending> {
  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();

  @override
  void initState() {
    super.initState();
    selectUserForChatController.getFollowingUsers();
  }

  @override
  void dispose() {
    selectUserForChatController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 340,
          width: Get.width,
          color: AppColorConstants.backgroundColor,
          child: GetBuilder<SelectUserForChatController>(
              init: selectUserForChatController,
              builder: (ctx) {
                ScrollController scrollController = ScrollController();
                scrollController.addListener(() {
                  if (scrollController.position.maxScrollExtent ==
                      scrollController.position.pixels) {
                    if (!selectUserForChatController.followingIsLoading) {
                      selectUserForChatController.getFollowingUsers();
                    }
                  }
                });

                List<UserModel> usersList =
                    selectUserForChatController.following;
                return selectUserForChatController.followingIsLoading
                    ? const ShimmerUsers().hp(DesignConstants.horizontalPadding)
                    : usersList.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.only(top: 20, bottom: 50),
                            controller: scrollController,
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              UserModel user = usersList[index];
                              return SendMessageUserTile(
                                state: selectUserForChatController
                                        .completedActionUsers
                                        .contains(user)
                                    ? ButtonState.success
                                    : selectUserForChatController
                                            .failedActionUsers
                                            .contains(user)
                                        ? ButtonState.fail
                                        : selectUserForChatController
                                                .processingActionUsers
                                                .contains(user)
                                            ? ButtonState.loading
                                            : ButtonState.idle,
                                profile: usersList[index],
                                sendCallback: () {
                                  Get.back();
                                  widget.sendToUserCallback(usersList[index]);
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            },
                          ).hp(DesignConstants.horizontalPadding)
                        : emptyUser(
                            title: noUserFoundString.tr,
                            subTitle:
                                followFriendsToSendPostString.tr,
                          );
              }),
        ).round(20).p16,
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 50,
            width: 50,
            color: AppColorConstants.backgroundColor,
            child: Center(
              child: ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.iconColor,
                size: 25,
              ),
            ),
          ).circular.ripple(() {
            Get.back();
          }),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

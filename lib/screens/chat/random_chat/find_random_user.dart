import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'package:ripple_wave/ripple_wave.dart';

class FindRandomUser extends StatefulWidget {
  final bool isCalling;
  final int? profileCategoryType;

  const FindRandomUser(
      {Key? key, required this.isCalling, this.profileCategoryType})
      : super(key: key);

  @override
  State<FindRandomUser> createState() => _FindRandomUserState();
}

class _FindRandomUserState extends State<FindRandomUser> {
  final RandomChatAndCallController _randomChatAndCallController = RandomChatAndCallController();
  final ChatDetailController _chatDetailController = Get.find();

  @override
  void initState() {
    _randomChatAndCallController.getRandomOnlineUsers(
        startFresh: true, profileCategoryType: widget.profileCategoryType);
    super.initState();
  }

  @override
  void dispose() {
    _randomChatAndCallController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar( title: findingString),
          const SizedBox(height: 8,),
          const Spacer(),
          Obx(() => _randomChatAndCallController.randomOnlineUser.value == null
              ? Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    RippleWave(
                      color: AppColorConstants.themeColor,
                      childTween: Tween(begin: 0.2, end: 1),
                      child: const Icon(
                        Icons.emoji_emotions,
                        size: 100,
                        color: Colors.white,
                      ),
                    ).p(50),
                    const SizedBox(
                      height: 150,
                    ),
                    Heading3Text(
                      findingPerfectUserToChatString.tr,
                      weight: TextWeight.regular,
                      textAlign: TextAlign.center,
                    ).hP25,
                  ],
                )
              : Column(
                  children: [
                    UserAvatarView(
                        size: 120,
                        user: _randomChatAndCallController
                            .randomOnlineUser.value!),
                    const SizedBox(
                      height: 20,
                    ),
                    Heading4Text(
                      _randomChatAndCallController
                          .randomOnlineUser.value!.userName,
                      weight: TextWeight.bold,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    widget.isCalling == true
                        ? callWidgets()
                        : SizedBox(
                            height: 50,
                            width: 250,
                            child: AppThemeButton(
                                text: chatString.tr,
                                onPress: () {
                                  EasyLoading.show(
                                      status: loadingString.tr);

                                  _chatDetailController.getChatRoomWithUser(
                                      userId: _randomChatAndCallController
                                          .randomOnlineUser.value!.id,
                                      callback: (room) {
                                        EasyLoading.dismiss();

                                        Get.back();
                                        Get.to(() => ChatDetail(
                                              // opponent: usersList[index - 1].toChatRoomMember,
                                              chatRoom: room,
                                            ));
                                      });
                                }),
                          ),
                  ],
                )),
          const Spacer(),
        ],
      ),
    );
  }

  Widget callWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Column(
            children: [
              const ThemeIconWidget(
                ThemeIcon.mobile,
                size: 20,
              ),
              const SizedBox(
                height: 5,
              ),
              BodyMediumText(
                audioString.tr,
                  weight: TextWeight.medium
              ),
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 8, bottom: 8),
        ).round(10).backgroundCard( shadowOpacity: 0.1).ripple(() {
          audioCall();
        }),
        const SizedBox(
          width: 20,
        ),
        Container(
          child: Column(
            children: [
              const ThemeIconWidget(
                ThemeIcon.videoCamera,
                size: 20,
              ),
              const SizedBox(
                height: 5,
              ),
              BodyMediumText(
                videoString.tr,
                  weight: TextWeight.medium
              ),
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 8, bottom: 8),
        ).round(10).backgroundCard( shadowOpacity: 0.1).ripple(() {
          videoCall();
        }),
      ],
    );
  }

  void videoCall() {
    _chatDetailController.initiateVideoCall();
  }

  void audioCall() {
    _chatDetailController.initiateAudioCall();
  }
}

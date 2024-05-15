import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';

class PublicGroupDetail extends StatefulWidget {
  const PublicGroupDetail({
    Key? key,
  }) : super(key: key);

  @override
  PublicGroupDetailState createState() => PublicGroupDetailState();
}

class PublicGroupDetailState extends State<PublicGroupDetail> {
  final ChatDetailController _chatDetailController = Get.find();
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
          Obx(() => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        height: 350,
                        child: _chatRoomDetailController
                                .currentRoom.value!.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _chatRoomDetailController
                                    .currentRoom.value!.image!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Heading1Text(_chatRoomDetailController
                                    .currentRoom.value!.name!.getInitials))),
                    const SizedBox(
                      height: 24,
                    ),
                    BodyLargeText(
                            _chatRoomDetailController.currentRoom.value!.name!,
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
                          publicGroupString.tr,
                          weight: TextWeight.medium,
                        ),
                        // const ThemeIconWidget(
                        //   ThemeIcon.circle,
                        //   size: 8,
                        // ).hP8,
                        // BodyMediumText(
                        //         '${_clubDetailController.club.value!.totalMembers!.formatNumber} ${clubMembersString.tr}',
                        //         weight: TextWeight.regular)
                        //     .ripple(() {
                        //   Get.to(() => ClubMembers(
                        //       club: _clubDetailController.club.value!));
                        // })
                      ],
                    ).hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 12,
                    ),
                    buttonsWidget().hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 20,
                    ),
                    BodyMediumText(_chatRoomDetailController
                            .currentRoom.value!.description!)
                        .hp(DesignConstants.horizontalPadding),
                  ],
                ),
              )),
          appBar()
        ],
      ),
    );
  }

  Widget buttonsWidget() {
    return Obx(() => Row(
          children: [
            if (_chatRoomDetailController.currentRoom.value!.amIGroupAdmin ==
                false)
              Container(
                      // width: 40,
                      height: 30,
                      color: AppColorConstants.themeColor.withOpacity(0.2),
                      child: Row(
                        children: [
                          Icon(
                            _chatRoomDetailController
                                        .currentRoom.value!.amIMember ==
                                    true
                                ? Icons.exit_to_app
                                : Icons.add,
                            color: AppColorConstants.iconColor,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          BodyLargeText(_chatRoomDetailController
                                      .currentRoom.value!.amIMember ==
                                  true
                              ? joinedString.tr
                              : joinString.tr)
                        ],
                      ).hP8)
                  .round(5)
                  .ripple(() {
                if (_chatRoomDetailController.currentRoom.value!.amIMember ==
                    true) {
                  _chatRoomDetailController.leavePublicGroup(
                      _chatRoomDetailController.currentRoom.value!);
                } else {
                  _chatRoomDetailController.addUsersToPublicRoom(
                      room: _chatRoomDetailController.currentRoom.value!,
                      selectedFriends: [_userProfileManager.user.value!]);
                }
              }).rP8,
            if (_chatRoomDetailController.currentRoom.value!.amIMember == true)
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
                Get.to(() => ChatDetail(
                    chatRoom: _chatRoomDetailController.currentRoom.value!));
              }).rP8,
          ],
        ));
  }

  Widget appBar() {
    return Positioned(
      child: Container(
        height: 150.0,
        width: MediaQuery.of(context).size.width,
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
            Obx(() => _chatRoomDetailController.currentRoom.value!.amIGroupAdmin
                ? Row(
                    children: [
                      const SizedBox(width: 10),
                      const ThemeIconWidget(
                        ThemeIcon.setting,
                        size: 20,
                        color: Colors.white,
                      ).ripple(() {
                        Get.to(() => UpdateGroupInfo(
                                group: _chatRoomDetailController
                                    .currentRoom.value!))!
                            .then((value) {
                          _chatDetailController.getUpdatedChatRoomDetail(
                              room:
                                  _chatRoomDetailController.currentRoom.value!,
                              callback: () {});
                        });
                      }),
                    ],
                  )
                : const SizedBox(
                    width: 20,
                  ))
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }
}

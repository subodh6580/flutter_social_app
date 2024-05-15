import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/search_bar.dart';
import '../../components/sm_tab_bar.dart';
import '../calling/call_history.dart';
import '../settings_menu/settings_controller.dart';
import 'group/public_chat_group_listing.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({Key? key}) : super(key: key);

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final ChatHistoryController _chatController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final SettingsController _settingsController = Get.find();
  List<String> tabs = [privateString.tr, openGroupsString.tr];

  @override
  void initState() {
    super.initState();
    _chatController.getPublicChatRooms(() { });
    _chatController.getChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: Container(
        height: 50,
        width: 50,
        color: AppColorConstants.themeColor,
        child: const ThemeIconWidget(
          ThemeIcon.edit,
          size: 25,
          color: Colors.white,
        ),
      ).circular.ripple(() {
        selectUsers();
      }).bP16,
      body: KeyboardDismissOnTap(
          child: DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      BodyLargeText(chatsString.tr, weight: TextWeight.medium),
                      _settingsController.setting.value!.enableAudioCalling ||
                              _settingsController
                                  .setting.value!.enableVideoCalling
                          ? ThemeIconWidget(
                              ThemeIcon.mobile,
                              color: AppColorConstants.iconColor,
                              size: 25,
                            ).ripple(() {
                              Get.to(() => const CallHistory());
                            })
                          : const SizedBox(
                              width: 25,
                            ),
                    ],
                  ).setPadding(
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding,
                      top: 8,
                      bottom: 16),
                  divider().tP8,
                  SFSearchBar(
                          showSearchIcon: true,
                          iconColor: AppColorConstants.themeColor,
                          onSearchChanged: (value) {
                            _chatController.searchTextChanged(value);
                          },
                          onSearchStarted: () {
                            //controller.startSearch();
                          },
                          onSearchCompleted: (searchTerm) {})
                      .p16,
                  SizedBox(
                      width: Get.width,
                      child: SMTabBar(
                        tabs: tabs,
                        canScroll: false,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: TabBarView(
                          children: [chatListView(), PublicChatGroupListing()]))
                ],
              ))),
    );
  }

  Widget chatListView() {
    return GetBuilder<ChatHistoryController>(
        init: _chatController,
        builder: (ctx) {
          return _chatController.searchedRooms.isNotEmpty
              ? ListView.separated(
                  padding: EdgeInsets.only(top: 10, bottom: 50,left: DesignConstants.horizontalPadding,right: DesignConstants.horizontalPadding),
                  itemCount: _chatController.searchedRooms.length,
                  itemBuilder: (ctx, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        _chatController
                            .deleteRoom(_chatController.searchedRooms[index]);
                      },
                      background: Container(
                        color: AppColorConstants.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Heading6Text(
                              deleteString.tr,
                              weight: TextWeight.bold,
                              color: AppColorConstants.mainTextColor,
                            )
                          ],
                        ).hP25,
                      ),
                      child: ChatHistoryTile(
                              model: _chatController.searchedRooms[index])
                          .ripple(() {
                        ChatRoomModel model =
                            _chatController.searchedRooms[index];
                        _chatController.clearUnreadCount(chatRoom: model);

                        Get.to(() => ChatDetail(chatRoom: model))!
                            .then((value) {
                          _chatController.getChatRooms();
                        });
                      }),
                    );
                  },
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(
                      height: 20,
                    );
                  })
              : emptyData(
                  title: noChatFoundString.tr,
                  subTitle: followSomeUserToChatString.tr,
                );
        });
  }

  void selectUsers() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: SelectUserForChat(userSelected: (user) {
                _chatDetailController.getChatRoomWithUser(
                    userId: user.id,
                    callback: (room) {
                      EasyLoading.dismiss();

                      Get.close(1);
                      Get.to(() => ChatDetail(
                                // opponent: usersList[index - 1].toChatRoomMember,
                                chatRoom: room,
                              ))!
                          .then((value) {
                        _chatController.getChatRooms();
                      });
                    });
              }),
            ));
  }
}

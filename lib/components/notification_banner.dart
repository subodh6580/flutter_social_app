import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:overlay_support/overlay_support.dart';
import '../manager/db_manager.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import '../screens/chat/chat_detail.dart';

showNewMessageBanner(ChatMessageModel message, int roomId) async {
  ChatRoomModel? room = await getIt<DBManager>().getRoomById(roomId);
  if (room == null) {
    ChatApi.getChatRoomDetail(roomId, resultCallback: (result) {
      showNotification(message, result);
    });
  } else {
    showNotification(message, room);
  }
}

showNotification(ChatMessageModel message, ChatRoomModel room) {
  showOverlayNotification((context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        color: AppColorConstants.cardColor.lighten(),
        child: ListTile(
          leading: AvatarView(
            size: 40,
            url: room.isGroupChat == true
                ? room.image
                : room.memberById(message.senderId).userDetail.picture,
            name: room.isGroupChat == true
                ? room.name
                : room.memberById(message.senderId).userDetail.userName,
          ),
          title: Heading5Text(
            room.isGroupChat == true
                ? '(${room.name}) ${room.memberById(message.senderId).userDetail.userName}'
                : room.memberById(message.senderId).userDetail.userName,
            weight: TextWeight.bold,
            color: AppColorConstants.themeColor,
          ),
          subtitle: Heading6Text(
            message.shortInfoForNotification,
          ),
        ).setPadding(top: 60, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding).ripple(() {
          OverlaySupportEntry.of(context)!.dismiss();

          Get.to(() => ChatDetail(
                chatRoom: room,
              ));
        }),
      ).backgroundCard().round(15),
    );
  }, duration: const Duration(milliseconds: 4000));
}

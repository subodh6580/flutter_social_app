import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';


import '../../../components/actionSheets/action_sheet1.dart';
import '../../../model/generic_item.dart';

class GroupSettings extends StatefulWidget {
  const GroupSettings({Key? key}) : super(key: key);

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

          backNavigationBar(
               title: groupSettingsString.tr),
          const SizedBox(height: 8,),
          const SizedBox(
            height: 20,
          ),
          Container(
            color: AppColorConstants.cardColor,
            height: 65,
            child: Column(
              // padding: const EdgeInsets.only(top: 10, bottom: 10),
              children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      color: AppColorConstants.themeColor,
                      child: const ThemeIconWidget(
                        ThemeIcon.send,
                        size: 20,
                      ),
                    ).round(5),
                    const SizedBox(
                      width: 15,
                    ),
                    Heading5Text(
                      sendMessagesString.tr,
                    ),
                    const Spacer(),
                    Obx(() => Heading6Text(
                          _chatDetailController.chatRoom.value!.groupAccess == 1
                              ? onlyAdminsString.tr
                              : allParticipantsString.tr,
                        )),
                    const ThemeIconWidget(
                      ThemeIcon.nextArrow,
                      size: 12,
                    )
                  ],
                ).ripple(() {
                  openActionSheetForSendMessage();
                }),
              ],
            ).p16,
          ),
        ],
      ),
    );
  }

  openActionSheetForSendMessage() {
    showModalBottomSheet(
        context: context,

        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                  id: '1',
                  title: allParticipantsString.tr,
                  subTitle: allParticipantsString.tr,
                  // isSelected: selectedItem?.id == '1',
                ),
                GenericItem(
                  id: '2',
                  title: onlyAdminsString.tr,
                  subTitle: onlyAdminsString.tr,
                  // isSelected: selectedItem?.id == '1',
                ),
              ],
              itemCallBack: (item) {
                if (item.id == '1') {
                  _chatRoomDetailController.updateGroupAccess(2);
                } else if (item.id == '2') {
                  _chatRoomDetailController.updateGroupAccess(1);
                }
              },
            ));
  }
}

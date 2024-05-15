import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../model/call_model.dart';
import '../../controllers/live/live_users_controller.dart';

class LiveUserScreen extends StatefulWidget {
  const LiveUserScreen({Key? key}) : super(key: key);

  @override
  State<LiveUserScreen> createState() => _LiveUserScreenState();
}

class _LiveUserScreenState extends State<LiveUserScreen> {
  final AgoraLiveController _agoraLiveController = Get.find();
  final LiveUserController _liveUserController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _liveUserController.getLiveUsers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColorConstants.backgroundColor,
      body: KeyboardDismissOnTap(
          child: Column(
        children: [
          backNavigationBar(title: liveUsersString.tr),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(
              () => _liveUserController.liveStreamUser.isEmpty
                  ? emptyData(title: noLiveUserString, subTitle: '')
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1),
                      itemCount: _liveUserController.liveStreamUser.length,
                      padding: EdgeInsets.only(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemBuilder: (context, index) {
                        final liveStreaming =
                            _liveUserController.liveStreamUser[index];

                        return Container(
                          color: AppColorConstants.themeColor.withOpacity(0.2),
                          child: Stack(
                            children: [
                              Center(
                                child: UserAvatarView(
                                  size: Get.width/2,
                                  user: liveStreaming.host![0],
                                  hideBorder: true,
                                  hideOnlineIndicator: true,
                                  hideLiveIndicator: true,
                                ),
                              ),
                              Positioned(
                                top: 15,
                                right: 10,
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  color: AppColorConstants.themeColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const ThemeIconWidget(
                                        ThemeIcon.group,
                                        color: Colors.white,
                                      ).p4,
                                      Obx(() => BodyLargeText(
                                            _liveUserController.totalLiveUsers
                                                .value.formatNumber,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ).round(20),
                              ),
                            ],
                          ),
                        ).round(20).ripple(() {
                          Live live = Live(
                              channelName: liveStreaming.channelName,
                              // isHosting: false,
                              mainHostUserDetail: liveStreaming.host!.first,
                              // battleUsers: [],
                              // battleId: ,
                              token: liveStreaming.token,
                              id: liveStreaming.id);
                          _agoraLiveController.joinAsAudience(
                            live: live,
                          );
                        });
                      }),
            ),
          ),
        ],
      )),
    );
  }
}

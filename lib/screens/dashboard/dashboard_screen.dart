import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/force_update_view.dart';
import '../add_on/ui/reel/reels.dart';
import '../home_feed/home_feed_screen.dart';
import '../profile/my_profile.dart';
import '../settings_menu/settings_controller.dart';
import 'explore.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxInt unreadMsgCount = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }

  updateUnreadMessageCount(int count) {
    unreadMsgCount.value = count;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardScreen> {
  final DashboardController _dashboardController = Get.find();
  final SettingsController _settingsController = Get.find();

  List<Widget> items = [];
  final picker = ImagePicker();
  bool hasPermission = false;

  @override
  void initState() {
    items = [
      const HomeFeedScreen(),
      const Explore(),
      const Reels(
        needBackBtn: false,
      ),
      const ChatHistory(),
      const MyProfile(
        showBack: false,
      ),
      //const Settings()
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => _dashboardController.isLoading.value == true
        ? SizedBox(
            height: Get.height,
            width: Get.width,
            child: const Center(child: CircularProgressIndicator()),
          )
        : _settingsController.forceUpdate.value == true
            ? ForceUpdateView()
            : _settingsController.appearanceChanged?.value == null
                ? Container()
                : Scaffold(
                    backgroundColor: AppColorConstants.backgroundColor,
                    body: items[_dashboardController.currentIndex.value],
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    bottomNavigationBar: SizedBox(
                      height: MediaQuery.of(context).viewPadding.bottom > 0
                          ? 100
                          : 80.0,
                      width: Get.width,
                      child: BottomNavigationBar(
                        backgroundColor: AppColorConstants.backgroundColor,
                        type: BottomNavigationBarType.fixed,
                        currentIndex: _dashboardController.currentIndex.value,
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        unselectedItemColor: Colors.grey,
                        selectedItemColor: AppColorConstants.themeColor,
                        onTap: (index) => {onTabTapped(index)},
                        items: [
                          BottomNavigationBarItem(
                              icon: Obx(() => ThemeIconWidget(
                                    ThemeIcon.home,
                                    size: 28,
                                    color: _dashboardController
                                                .currentIndex.value ==
                                            0
                                        ? AppColorConstants.themeColor
                                        : AppColorConstants.iconColor,
                                  ).bP8),
                              label: homeString.tr),
                          BottomNavigationBarItem(
                            icon: Obx(() => Stack(
                                  children: [
                                    Obx(() => ThemeIconWidget(
                                          ThemeIcon.search,
                                          size: 28,
                                          color: _dashboardController
                                                      .currentIndex.value ==
                                                  1
                                              ? AppColorConstants.themeColor
                                              : AppColorConstants.iconColor,
                                        ).bP8),
                                    if (_dashboardController
                                            .unreadMsgCount.value >
                                        0)
                                      Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            color: AppColorConstants.themeColor,
                                          ).circular)
                                  ],
                                )),
                            label: exploreString.tr,
                          ),
                          BottomNavigationBarItem(
                            icon: Obx(() => Container(
                                  color: AppColorConstants.themeColor
                                      .withOpacity(0.25),
                                  child: ThemeIconWidget(
                                    ThemeIcon.reels,
                                    size: 28,
                                    color: _dashboardController
                                                .currentIndex.value ==
                                            2
                                        ? AppColorConstants.themeColor
                                        : AppColorConstants.iconColor,
                                  ).p4,
                                ).circular),
                            label: reelsString.tr,
                          ),
                          BottomNavigationBarItem(
                            icon: Obx(() => ThemeIconWidget(
                                  ThemeIcon.chat,
                                  size: 28,
                                  color:
                                      _dashboardController.currentIndex.value ==
                                              3
                                          ? AppColorConstants.themeColor
                                          : AppColorConstants.iconColor,
                                ).bP8),
                            label: chatsString.tr,
                          ),
                          BottomNavigationBarItem(
                            icon: Obx(() => ThemeIconWidget(
                                  ThemeIcon.account,
                                  size: 28,
                                  color:
                                      _dashboardController.currentIndex.value ==
                                              4
                                          ? AppColorConstants.themeColor
                                          : AppColorConstants.iconColor,
                                ).bP8),
                            label: accountString.tr,
                          ),
                        ],
                      ),
                    )));
  }

  void onTabTapped(int index) async {
    // if (index == 2) {
    //   Future.delayed(
    //     Duration.zero,
    //     () => showGeneralDialog(
    //         context: context,
    //         pageBuilder: (context, animation, secondaryAnimation) =>
    //             const SelectMedia()),
    //   );
    // } else {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
    // }
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/tvs/subscribed_tvs.dart';
import 'package:foap/screens/tvs/tv_list_home.dart';


import 'fav_tv_list.dart';

class TvDashboardController extends GetxController {
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

class TvDashboardScreen extends StatefulWidget {
  const TvDashboardScreen({Key? key}) : super(key: key);

  @override
  TvDashboardScreenState createState() => TvDashboardScreenState();
}

class TvDashboardScreenState extends State<TvDashboardScreen> {
  final TvDashboardController _dashboardController = TvDashboardController();

  List<Widget> items = [];
  bool hasPermission = false;

  @override
  void initState() {
    items = [
      const TvListHome(),
      const FavTvList(),
      const SubscribedTvList()
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).viewPadding.bottom > 0 ? 90 : 70.0,
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
                  icon: Image.asset('assets/tv/tv.png',
                      height: 20,
                      width: 20,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Image.asset('assets/tv/fav.png',
                      height: 20,
                      width: 20,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                icon: Image.asset('assets/tv/subscribed.png',
                    height: 20,
                    width: 20,
                    color: _dashboardController.currentIndex.value == 2
                        ? AppColorConstants.themeColor
                        : AppColorConstants.iconColor),
                label: '',
              ),
            ],
          ),
        )));
  }

  void onTabTapped(int index) async {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/user_card.dart';
import '../../controllers/notification/notifications_controller.dart';
import 'other_user_profile.dart';

class FollowRequestList extends StatefulWidget {
  const FollowRequestList({Key? key}) : super(key: key);

  @override
  FollowRequestListState createState() => FollowRequestListState();
}

class FollowRequestListState extends State<FollowRequestList> {
  final NotificationController _notificationController =
      NotificationController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _notificationController.refreshFollowRequests(() {});
  }

  @override
  void dispose() {
    _notificationController.clearFollowRequests();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(title: followRequestsString.tr),
            Expanded(
              child: Obx(() => _notificationController
                      .followRequestDataWrapper.isLoading.value
                  ? const ShimmerUsers().hp(DesignConstants.horizontalPadding)
                  : Column(
                      children: [
                        _notificationController.followRequests.isEmpty
                            ? noUserFound(context)
                            : Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 50,
                                      left: DesignConstants.horizontalPadding,
                                      right: DesignConstants.horizontalPadding),
                                  itemCount: _notificationController
                                      .followRequests.length,
                                  itemBuilder: (context, index) {
                                    UserModel user = _notificationController
                                        .followRequests[index].sender;
                                    return FollowRequestSenderUserTile(
                                      profile: user,
                                      acceptCallback: () {
                                        _notificationController
                                            .acceptFollowRequest(user.id);
                                      },
                                      declineCallback: () {
                                        _notificationController
                                            .delcineFollowRequest(user.id);
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      height: 20,
                                    );
                                  },
                                ).addPullToRefresh(
                                    refreshController: _refreshController,
                                    onRefresh: () {
                                      _notificationController
                                          .refreshFollowRequests(() {
                                        _refreshController.refreshCompleted();
                                      });
                                    },
                                    onLoading: () {
                                      _notificationController
                                          .loadMoreFollowRequests(() {
                                        _refreshController.refreshCompleted();
                                      });
                                    },
                                    enablePullUp: true,
                                    enablePullDown: true),
                              ),
                      ],
                    )),
            ),
          ],
        ));
  }
}

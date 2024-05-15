import 'package:foap/helper/imports/common_import.dart';
import '../../components/user_card.dart';
import '../../controllers/misc/user_network_controller.dart';
import 'other_user_profile.dart';

class FollowerFollowingList extends StatefulWidget {
  final bool isFollowersList;
  final int userId;

  const FollowerFollowingList(
      {Key? key, required this.isFollowersList, required this.userId})
      : super(key: key);

  @override
  FollowerFollowingState createState() => FollowerFollowingState();
}

class FollowerFollowingState extends State<FollowerFollowingList> {
  final UserNetworkController _userNetworkController = UserNetworkController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    _userNetworkController.clear();
    if (widget.isFollowersList == true) {
      _userNetworkController.getFollowers(widget.userId);
    } else {
      _userNetworkController.getFollowingUsers(widget.userId);
    }
  }

  @override
  void didUpdateWidget(covariant FollowerFollowingList oldWidget) {
    loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _userNetworkController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(
                title: widget.isFollowersList
                    ? followersString.tr
                    : followingString.tr),
            Expanded(
              child: GetBuilder<UserNetworkController>(
                  init: _userNetworkController,
                  builder: (ctx) {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        if (widget.isFollowersList == true) {
                          if (!_userNetworkController.isLoading.value) {
                            _userNetworkController.getFollowers(widget.userId);
                          }
                        } else {
                          if (!_userNetworkController.isLoading.value) {
                            _userNetworkController
                                .getFollowingUsers(widget.userId);
                          }
                        }
                      }
                    });

                    List<UserModel> usersList = widget.isFollowersList == true
                        ? _userNetworkController.followers
                        : _userNetworkController.following;
                    return _userNetworkController.isLoading.value
                        ? const ShimmerUsers().hp(DesignConstants.horizontalPadding)
                        : Column(
                            children: [
                              usersList.isEmpty
                                  ? noUserFound(context)
                                  : Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 50),
                                        controller: scrollController,
                                        itemCount: usersList.length,
                                        itemBuilder: (context, index) {
                                          return UserTile(
                                            profile: usersList[index],
                                            viewCallback: () {
                                              Get.to(() => OtherUserProfile(
                                                      userId:
                                                          usersList[index].id))!
                                                  .then(
                                                      (value) => {loadData()});
                                            },
                                            followCallback: () {
                                              _userNetworkController
                                                  .followUser(usersList[index]);
                                            },
                                            unFollowCallback: () {
                                              _userNetworkController
                                                  .unFollowUser(
                                                      usersList[index]);
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height: 20,
                                          );
                                        },
                                      ).hp(DesignConstants.horizontalPadding),
                                    ),
                            ],
                          );
                  }),
            ),
          ],
        ));
  }
}

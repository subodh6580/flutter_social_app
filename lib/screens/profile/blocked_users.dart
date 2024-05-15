import 'package:foap/helper/imports/common_import.dart';


import '../../components/user_card.dart';
import '../../controllers/misc/blocked_users_controller.dart';

class BlockedUsersList extends StatefulWidget {
  const BlockedUsersList({Key? key}) : super(key: key);

  @override
  BlockedUsersListState createState() => BlockedUsersListState();
}

class BlockedUsersListState extends State<BlockedUsersList> {
  final BlockedUsersController blockedUsersController = BlockedUsersController();

  @override
  void initState() {
    blockedUsersController.getBlockedUsers();
    super.initState();
  }

  @override
  void dispose() {
    blockedUsersController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

          backNavigationBar( title:blockedUserString.tr),
          divider().vP8,
          Expanded(
            child: GetBuilder<BlockedUsersController>(
                init: blockedUsersController,
                builder: (ctx) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.maxScrollExtent ==
                        scrollController.position.pixels) {
                      if (!blockedUsersController.isLoading) {
                        blockedUsersController.getBlockedUsers();
                      }
                    }
                  });

                  return blockedUsersController.isLoading
                      ? const ShimmerUsers().hp(DesignConstants.horizontalPadding)
                      : Column(
                          mainAxisAlignment:
                              blockedUsersController.usersList.isEmpty &&
                                      blockedUsersController.isLoading == false
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                          children: [
                            blockedUsersController.usersList.isEmpty
                                ? blockedUsersController.isLoading == false
                                    ? noUserFound(context)
                                    : Container()
                                : Expanded(
                                    child: ListView.separated(
                                      padding: const EdgeInsets.only(top: 20),
                                      controller: scrollController,
                                      itemCount: blockedUsersController
                                          .usersList.length,
                                      itemBuilder: (context, index) {
                                        return BlockedUserTile(
                                          profile: blockedUsersController
                                              .usersList[index],
                                          unBlockCallback: () {
                                            blockedUsersController.unBlockUser(
                                                blockedUsersController
                                                    .usersList[index].id);
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
      ),
    );
  }
}

import 'package:foap/helper/imports/common_import.dart';
import '../../components/search_bar.dart';
import '../../components/user_card.dart';
import '../../controllers/misc/users_controller.dart';

class InviteUsers extends StatefulWidget {
  final Function(UserModel) userSelectedHandler;

  const InviteUsers({Key? key, required this.userSelectedHandler})
      : super(key: key);

  @override
  State<InviteUsers> createState() => _InviteUsersState();
}

class _InviteUsersState extends State<InviteUsers> {
  final UsersController _usersController = Get.find();

  @override
  void initState() {
    _usersController.setIsOnlineFilter();
    super.initState();
  }

  @override
  void dispose() {
    _usersController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Heading6Text(inviteUserString.tr, weight: TextWeight.bold),
          const SizedBox(
            height: 20,
          ),
          divider(),
          SFSearchBar(
              showSearchIcon: true,
              iconColor: AppColorConstants.themeColor,
              onSearchChanged: (value) {
                _usersController.setSearchTextFilter(value, () {});
                // exploreController.searchTextChanged(value);
              },
              onSearchStarted: () {
                //controller.startSearch();
              },
              onSearchCompleted: (searchTerm) {}),
          Expanded(
            child: GetBuilder<UsersController>(
                init: _usersController,
                builder: (ctx) {
                  return ListView.separated(
                      padding: const EdgeInsets.only(top: 20),
                      itemBuilder: (ctx, index) {
                        return InviteUserTile(
                          profile: _usersController.searchedUsers[index],
                          inviteCallback: () {
                            Get.back();
                            widget.userSelectedHandler(
                                _usersController.searchedUsers[index]);
                          },
                        );
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          height: 20,
                        );
                      },
                      itemCount: _usersController.searchedUsers.length);
                }),
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    ).topRounded(40);
  }
}

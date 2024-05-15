import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/user_card.dart';
import '../profile/other_user_profile.dart';

class ClubJoinRequests extends StatefulWidget {
  final ClubModel club;

  const ClubJoinRequests({Key? key, required this.club}) : super(key: key);

  @override
  ClubJoinRequestsState createState() => ClubJoinRequestsState();
}

class ClubJoinRequestsState extends State<ClubJoinRequests> {
  final ClubDetailController _clubDetailController = ClubDetailController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
               title: joinRequestsString.tr),
          const SizedBox(height: 8,),
          Expanded(
            child: GetBuilder<ClubDetailController>(
                init: _clubDetailController,
                builder: (ctx) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.maxScrollExtent ==
                        scrollController.position.pixels) {
                      if (!_clubDetailController.isLoading.value) {
                        _clubDetailController.getClubJoinRequests(
                            clubId: widget.club.id!);
                      }
                    }
                  });

                  List<ClubJoinRequest> requestsList =
                      _clubDetailController.joinRequests;
                  return ListView.separated(
                      padding:  EdgeInsets.only(
                          top: 25, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, bottom: 100),
                      itemCount: requestsList.length,
                      itemBuilder: (context, index) {
                        return ClubJoinRequestTile(
                          request: requestsList[index],
                          viewCallback: () {
                            Get.to(() => OtherUserProfile(
                                userId: requestsList[index].user!.id));
                          },
                          acceptBtnClicked: () {
                            _clubDetailController
                                .acceptClubJoinRequest(requestsList[index]);
                          },
                          declineBtnClicked: () {
                            _clubDetailController
                                .declineClubJoinRequest(requestsList[index]);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return divider().vP16;
                      });
                }),
          ),
        ],
      ),
    );
  }
}

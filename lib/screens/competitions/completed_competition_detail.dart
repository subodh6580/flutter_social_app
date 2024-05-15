import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/competition_imports.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apiHandler/apis/users_api.dart';
import '../home_feed/enlarge_image_view.dart';
import '../post/single_post_detail.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class CompletedCompetitionDetail extends StatefulWidget {
  final int competitionId;

  const CompletedCompetitionDetail({Key? key, required this.competitionId})
      : super(key: key);

  @override
  CompletedCompetitionDetailState createState() =>
      CompletedCompetitionDetailState();
}

class CompletedCompetitionDetailState
    extends State<CompletedCompetitionDetail> {
  final CompetitionController competitionController = CompetitionController();
  SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (widget.competition != null) {
      //   competitionController.setCompetition(widget.competition!);
      // } else {
      competitionController.loadCompetitionDetail(id: widget.competitionId);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBarWithIcon(
              icon: ThemeIcon.privacyPolicy,
              title: competitionString.tr,
              iconBtnClicked: () async {
                if (await canLaunchUrl(Uri.parse(
                    settingsController.setting.value!.disclaimerUrl!))) {
                  await launchUrl(Uri.parse(
                      settingsController.setting.value!.disclaimerUrl!));
                } else {
                  // throw 'Could not launch $url';
                }
                // Get.to(() => WebViewScreen(
                //     header: disclaimerString.tr,
                //     url: ));
              }),
          Expanded(
            child: Stack(children: [
              Obx(() {
                CompetitionModel? competition =
                    competitionController.competition.value;
                return competition == null
                    ? Container()
                    : SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Stack(
                              children: [
                                Container(
                                    height: 270.0,
                                    margin: const EdgeInsets.only(bottom: 30),
                                    child: CachedNetworkImage(
                                      imageUrl: competition.photo,
                                      fit: BoxFit.cover,
                                      width: Get.width,
                                      placeholder: (context, url) =>
                                          AppUtil.addProgressIndicator(
                                              size: 100),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )),
                                applyShader(),
                                CompetitionHighlightBar(model: competition)
                              ],
                            ),
                            competition.winnerAnnounced()
                                ? Column(
                                    children: [
                                      for (CompetitionPositionModel position
                                          in competition.competitionPositions)
                                        winnerInfo(
                                            forPosition: position,
                                            competition: competition),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BodyLargeText(
                                        competition.description,
                                        weight: TextWeight.regular,
                                      ),
                                      addPhotoGrid(competition: competition),
                                    ],
                                  ).setPadding(
                                    top: 16, bottom: 16, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                          ]));
              }),
              // addBottomActionButton()
            ]),
          ),
        ],
      ),
    );
  }

  Widget winnerInfo(
      {required CompetitionPositionModel forPosition,
      required CompetitionModel competition}) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          UserModel winner = snapshot.data as UserModel;
          return competition.mainWinnerId() == winner.id
              ? winnerDetailCard(
                      position: forPosition,
                      winner: winner,
                      competition: competition)
                  .backgroundCard()
                  .p16
              : winnerDetailCard(
                      position: forPosition,
                      winner: winner,
                      competition: competition)
                  .p16;
        } else {
          return SizedBox(
              width: Get.width - 32,
              child: Center(
                child: Heading6Text('Loading...',
                        color: AppColorConstants.themeColor)
                    .vP25,
              )).backgroundCard().p16;
        }
      },

      // Future that needs to be resolved
      // inorder to display something on the Canvas
      future: getOtherUserDetailApi(forPosition.winnerUserId.toString()),
    );
  }

  Widget winnerDetailCard(
      {required CompetitionPositionModel position,
      required UserModel winner,
      required CompetitionModel competition}) {
    return SizedBox(
      width: Get.width - 32,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Heading3Text(position.title, weight: TextWeight.medium).hP4,
                  Image.asset(
                    'assets/trophy.png',
                    height: 30,
                  )
                ],
              ).bP8,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BodyLargeText('${userString.tr} :', weight: TextWeight.medium)
                      .hP4,
                  BodyLargeText(winner.userName,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor)
                      .ripple(() {
                    Get.to(() => OtherUserProfile(userId: winner.id));
                  }),
                ],
              ).bP8,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BodyLargeText('${prizeString.tr}: ',
                          weight: TextWeight.medium)
                      .hP4,
                  BodyLargeText(
                    competition.awardType == 2
                        ? '${competition.awardedValueForUser(winner.id)} ${coinsString.tr}'
                        : '\$${competition.awardedValueForUser(winner.id)} ${inRewardsString.tr}',
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          SizedBox(
              width: 100,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: position.post!.gallery.first.filePath,
                fit: BoxFit.cover,
              ).round(20))
        ],
      ).p(10),
    ).ripple(() {
      Get.to(() => SinglePostDetail(postId: position.post!.id));
    });
  }

  Widget addPhotoGrid({required CompetitionModel competition}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      competition.posts.isNotEmpty
          ? Heading4Text(
              submittedPhotosString.tr,
              weight: FontWeight.bold,
              color: AppColorConstants.subHeadingTextColor,
            ).tP25
          : Container(),
      competition.posts.isNotEmpty
          ? GridView.builder(
              itemCount: competition.posts.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // You won't see infinite size error
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  mainAxisExtent: 100),
              itemBuilder: (BuildContext context, int index) => InkWell(
                  onTap: () async {
                    // File path = await AppUtil.findPath(
                    //     model.posts[index].gallery.first.filePath);
                    Get.to(() => EnlargeImageViewScreen(
                          model: competition.posts[index],
                          // file: path,
                          handler: () {},
                        ));
                  },
                  child: ClipRRect(
                      child: competition.posts[index].gallery.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: competition
                                  .posts[index].gallery.first.filePath,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  AppUtil.addProgressIndicator(size: 100),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ).round(10)
                          : Container())),
              // staggeredTileBuilder: (int index) => new StaggeredTile.count(1, 1),
            )
          : Container(),
      const SizedBox(height: 65)
    ]);
  }

  applyShader() {
    return Container(
        height: 270.0,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
              stops: const [
                0.0,
                1.0
              ]),
        ));
  }

  addBottomActionButton({required CompetitionModel competition}) {
    return Positioned(
      bottom: 0,
      child: InkWell(
          onTap: () {
            if (competition.winnerId != '') {
              Get.to(() =>
                  WinnerDetailScreen(winnerPost: competition.winnerPost.first));
            }
          },
          child: Container(
            width: Get.width,
            height: 60,
            color: AppColorConstants.themeColor,
            child: Center(
              child: BodyLargeText(
                  competition.winnerId == ''
                      ? winnerAnnouncementPendingString.tr
                      : viewWinnerString.tr,
                  weight: TextWeight.medium,
                  color: AppColorConstants.themeColor),
            ),
          )),
    );
  }

  Future<UserModel?> getOtherUserDetailApi(String userId) async {
    UserModel? user;
    await UsersApi.getOtherUser(
        userId: int.parse(userId),
        resultCallback: (result) {
          user = result;
        });

    return user;
  }
}

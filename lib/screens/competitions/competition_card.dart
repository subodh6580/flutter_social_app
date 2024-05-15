import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/competition_imports.dart';
import '../../apiHandler/apis/users_api.dart';

class CompetitionCard extends StatefulWidget {
  final CompetitionModel model;
  final VoidCallback handler;

  const CompetitionCard({Key? key, required this.model, required this.handler})
      : super(key: key);

  @override
  CompetitionCardState createState() => CompetitionCardState();
}

class CompetitionCardState extends State<CompetitionCard> {
  late final CompetitionModel model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => widget.handler(),
        child: SizedBox(
          height: 250,
          child: Column(children: [
            Stack(
              fit: StackFit.loose,
              children: [
                SizedBox(
                  height: 250,
                  child: CachedNetworkImage(
                    imageUrl: model.photo,
                    fit: BoxFit.cover,
                    width: Get.width,
                    height: 200,
                    placeholder: (context, url) =>
                        AppUtil.addProgressIndicator(size: 100),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ).overlay(Colors.black38).round(20).bP25,
                ),
                CompetitionHighlightBar(model: model),
                Positioned(
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    bottom: 70,
                    child: Heading4Text(
                      model.title,
                      weight: TextWeight.semiBold,
                      color: Colors.white,
                    ))
              ],
            ),
          ]),
        )).hp(DesignConstants.horizontalPadding);
  }
}

class CompetitionHighlightBar extends StatefulWidget {
  final CompetitionModel model;

  const CompetitionHighlightBar({Key? key, required this.model})
      : super(key: key);

  @override
  State<CompetitionHighlightBar> createState() =>
      _CompetitionHighlightBarState();
}

class _CompetitionHighlightBarState extends State<CompetitionHighlightBar> {
  late CompetitionModel model;

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 30,
      right: 30,
      child: Container(
        height: 50.0,
        color: AppColorConstants.backgroundColor,
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
            mainAxisAlignment: model.winnerAnnounced()
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              model.winnerAnnounced()
                  ? BodyLargeText('Winner : ',
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor)
                  : BodyLargeText(
                      model.awardType == 2
                          ? '${prizeString.tr} : ${model.totalAwardValue()} ${coinsString.tr}'
                          : '${prizeString.tr} : \$${model.totalAwardValue()}',
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
              model.winnerAnnounced()
                  ? FutureBuilder(
                      builder: (ctx, snapshot) {
                        // Displaying LoadingSpinner to indicate waiting state
                        if (snapshot.hasData) {
                          UserModel? user = snapshot.data as UserModel?;

                          return user == null
                              ? BodyLargeText(loadingString.tr)
                              : BodyLargeText(
                                  user.isMe ? youString.tr : user.userName,
                                  weight: TextWeight.bold,
                                  color: AppColorConstants.themeColor);
                        } else {
                          return BodyLargeText(loadingString.tr,
                              color: AppColorConstants.themeColor);
                        }
                      },
                      future: getOtherUserDetailApi(
                          model.mainWinnerId().toString()),
                    )
                  : BodyLargeText(
                      model.isPast ? completedString.tr : model.timeLeft,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor)
            ]),
      ).shadowWithBorder(
          shadowOpacity: 0.1,
          borderColor: AppColorConstants.themeColor,
          radius: 15,
          borderWidth: 2),
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

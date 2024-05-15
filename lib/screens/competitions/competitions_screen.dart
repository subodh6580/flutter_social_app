import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/competition_imports.dart';


class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({Key? key}) : super(key: key);

  @override
  CompetitionsState createState() => CompetitionsState();
}

class CompetitionsState extends State<CompetitionsScreen> {
  List<String> competitionsArr = [
    currentString.tr,
    completedString.tr,
    winnersString.tr,
  ];

  final CompetitionController competitionController = CompetitionController();

  @override
  void initState() {
    competitionController.getCompetitions(() {});

    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        competitionController.getCompetitions(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    competitionController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: competitionsArr.length,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: <Widget>[

          backNavigationBar(
            title: competitionString.tr,
          ),
          divider().vP8,
          TabBar(
            labelColor: AppColorConstants.themeColor,
            unselectedLabelColor: AppColorConstants.mainTextColor,
            indicatorColor: AppColorConstants.themeColor,
            indicatorWeight: 2,
            unselectedLabelStyle: TextStyle(
            fontSize: FontSizes.b2),
            labelStyle: TextStyle(
                fontSize: FontSizes.b2,
                fontWeight: TextWeight.bold,
                ),
            tabs: List.generate(competitionsArr.length, (int index) {
              return Visibility(
                visible: true,
                child: Tab(
                  text: competitionsArr[index],
                ),
              );
            }),
          ),
          divider(),
          GetBuilder<CompetitionController>(
              init: competitionController,
              builder: (ctx) {
                return Expanded(
                    child: TabBarView(
                  children: List.generate(competitionsArr.length, (int index) {
                    return index == 0
                        ? addCompetitionsList(competitionController.current)
                        : index == 1
                            ? addCompetitionsList(
                                competitionController.completed)
                            : addCompetitionsList(
                                competitionController.winners);
                  }),
                ));
              })
        ]),
      ),
    );
  }

  addCompetitionsList(List<CompetitionModel> arr) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      itemCount: arr.length,
      itemBuilder: (context, index) {
        CompetitionModel model = arr[index];
        return CompetitionCard(
            model: model,
            handler: () {
              model.isPast
                  ? Get.to(
                      () => CompletedCompetitionDetail(competitionId: model.id))
                  : Get.to(() => CompetitionDetailScreen(
                      competitionId: model.id,
                      refreshPreviousScreen: () {
                        competitionController.getCompetitions(() {});
                      }));
            });
      },
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 20,
        );
      },
    );
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import '../../controllers/live/live_history_controller.dart';
import '../../model/live_model.dart';

class LiveHistory extends StatefulWidget {
  const LiveHistory({Key? key}) : super(key: key);

  @override
  LiveHistoryState createState() => LiveHistoryState();
}

class LiveHistoryState extends State<LiveHistory> {
  final LiveHistoryController _liveHistoryController = LiveHistoryController();
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          _liveHistoryController.getLiveHistory();
        }
      }
    });

    _liveHistoryController.getLiveHistory();
  }

  @override
  void dispose() {
    super.dispose();
    _liveHistoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        backNavigationBar(title: liveString.tr),
        Expanded(
          child: Obx(() => ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(top: 20, bottom: 70),
              itemBuilder: (ctx, index) {
                LiveModel live = _liveHistoryController.lives[index];
                return Container(
                  color: AppColorConstants.cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ThemeIconWidget(
                            ThemeIcon.calendar,
                            size: 15,
                            color: AppColorConstants.themeColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          BodySmallText(
                            '${startedAtString.tr} ${live.startedAt!}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ThemeIconWidget(
                            ThemeIcon.diamond,
                            size: 15,
                            color: AppColorConstants.themeColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          BodySmallText(
                            live.giftSummary!.totalCoin.toString(),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              ThemeIconWidget(
                                ThemeIcon.clock,
                                size: 15,
                                color: AppColorConstants.themeColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              BodySmallText(
                                live.totalTime.formatTime,
                                weight: TextWeight.medium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ).p16,
                ).round(10);
              },
              separatorBuilder: (ctx, index) {
                return const SizedBox(
                  height: 20,
                );
              },
              itemCount: _liveHistoryController.lives.length)).hp(DesignConstants.horizontalPadding),
        ),
      ]),
    );
  }
}

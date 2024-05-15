import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_list_dashboard.dart';
import 'package:foap/screens/chatgpt/chat_gpt.dart';
import 'package:foap/screens/home_feed/story_uploader.dart';
import 'package:foap/screens/live/live_users_screen.dart';
import '../../controllers/home/home_controller.dart';
import '../chat/random_chat/choose_profile_category.dart';

import '../club/clubs_listing.dart';
import '../competitions/competitions_screen.dart';
import '../highlights/choose_stories.dart';
import '../live/checking_feasibility.dart';
import '../tvs/tv_dashboard.dart';

enum QuickLinkType {
  live,
  randomChat,
  randomCall,
  competition,
  clubs,
  pages,
  tv,
  podcast,
  story,
  highlights,
  goLive,
  liveUsers,
  chatGPT
}

class QuickLink {
  String icon;
  String heading;
  String subHeading;
  QuickLinkType linkType;

  QuickLink(
      {required this.icon,
      required this.heading,
      required this.subHeading,
      required this.linkType});
}

class QuickLinkWidget extends StatefulWidget {
  final VoidCallback callback;

  const QuickLinkWidget({Key? key, required this.callback}) : super(key: key);

  @override
  State<QuickLinkWidget> createState() => _QuickLinkWidgetState();
}

class _QuickLinkWidgetState extends State<QuickLinkWidget> {
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView(
            padding: EdgeInsets.only(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                top: 20,
                bottom: 100),
            // spacing: 10,
            // runSpacing: 10,
            clipBehavior: Clip.hardEdge,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.1),
            children: [
              for (QuickLink link in _homeController.quickLinks)
                quickLinkView(link).ripple(() {
                  widget.callback();

                  if (link.linkType == QuickLinkType.competition) {
                    Get.to(() => const CompetitionsScreen());
                  } else if (link.linkType == QuickLinkType.randomChat) {
                    if (AppConfigConstants.isDemoApp) {
                      AppUtil.showDemoAppConfirmationAlert(
                          title: 'Demo app',
                          subTitle:
                              'This is demo app so might not find online user to test it',
                          okHandler: () {
                            Get.to(() => const ChooseProfileCategory(
                                  isCalling: false,
                                ));
                          });
                      return;
                    } else {
                      Get.to(() => const ChooseProfileCategory(
                            isCalling: false,
                          ));
                    }
                  } else if (link.linkType == QuickLinkType.randomCall) {
                    Get.to(() => const ChooseProfileCategory(
                          isCalling: true,
                        ));
                  } else if (link.linkType == QuickLinkType.clubs) {
                    Get.to(() => const ExploreClubs());
                  } else if (link.linkType == QuickLinkType.pages) {
                  } else if (link.linkType == QuickLinkType.goLive) {
                    Get.to(() => CheckingLiveFeasibility(
                          successCallbackHandler: () {},
                        ));
                  } else if (link.linkType == QuickLinkType.story) {
                    openStoryUploader();
                  } else if (link.linkType == QuickLinkType.highlights) {
                    Get.to(() => const ChooseStoryForHighlights());
                  } else if (link.linkType == QuickLinkType.tv) {
                    Get.to(() => const TvDashboardScreen());
                  } else if (link.linkType == QuickLinkType.liveUsers) {
                    Get.to(() => const LiveUserScreen());
                  } else if (link.linkType == QuickLinkType.podcast) {
                    Get.to(() => const PodcastListDashboard());
                  } else if (link.linkType == QuickLinkType.chatGPT) {
                    Get.to(() => const ChatGPT());
                  }
                })
            ]));
  }

  Widget quickLinkView(QuickLink link) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              link.icon,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Heading6Text(
            link.heading.tr,
          ),
        ],
      ).p16,
    ).round(20);
  }
}

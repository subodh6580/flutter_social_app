import 'package:foap/components/reply_chat_cells/post_gift_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../model/post_gift_model.dart';
import '../screens/settings_menu/coin_packages_widget.dart';

class PostGiftPageView extends StatefulWidget {
  final Function(PostGiftModel) giftSelectedCompletion;

  const PostGiftPageView({Key? key, required this.giftSelectedCompletion})
      : super(key: key);

  @override
  State<PostGiftPageView> createState() => _PostGiftPageViewState();
}

class _PostGiftPageViewState extends State<PostGiftPageView> {
  final UserProfileManager _userProfileManager = Get.find();

  int currentView = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      GiftsListing(
        giftSelectedCompletion: widget.giftSelectedCompletion,
      ),
      coinPackages(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.themeColor.darken(0.48),
      child: Column(
        children: [
          Container(
            height: 60,
            color: AppColorConstants.themeColor.darken(0.48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BodyLargeText(
                      '${availableCoinsString.tr} : ',
                      color: Colors.white,
                    ),
                    ThemeIconWidget(
                      ThemeIcon.diamond,
                      size: 20,
                      color: AppColorConstants.themeColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    BodyLargeText(
                      _userProfileManager.user.value!.coins.toString(),
                      color: Colors.white,
                    )
                  ],
                ),
                currentView == 0
                    ? Container(
                            color: AppColorConstants.themeColor,
                            child: BodyLargeText(
                              coinsString.tr,
                              weight: TextWeight.semiBold,
                            ).setPadding(
                                left: 10, right: 10, top: 5, bottom: 5))
                        .round(20)
                        .ripple(() {
                        setState(() {
                          currentView = 1;
                        });
                      })
                    : const ThemeIconWidget(
                        ThemeIcon.close,
                        size: 20,
                      ).ripple(() {
                        setState(() {
                          currentView = 0;
                        });
                      }),
              ],
            ).p16,
          ).topRounded(20),
          Expanded(child: pages[currentView]),
        ],
      ),
    );
  }

  Widget coinPackages() {
    return const CoinPackagesWidget();
  }
}

class GiftsListing extends StatefulWidget {
  final Function(PostGiftModel) giftSelectedCompletion;

  const GiftsListing({Key? key, required this.giftSelectedCompletion})
      : super(key: key);

  @override
  State<GiftsListing> createState() => _GiftsListingState();
}

class _GiftsListingState extends State<GiftsListing> {
  final PostGiftController _postGiftController = Get.find();

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() {
    _postGiftController.fetchTimelinePostGift();
  }

  @override
  void dispose() {
    _postGiftController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor.darken(),
      child: Obx(() {
        return ListView.separated(
            padding:
                 EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 20, bottom: 50),
            itemCount: _postGiftController.timelineGift.length,
            itemBuilder: (context, index) {
              PostGiftModel postGift = _postGiftController.timelineGift[index];
              // return Container(child: Text(postGift.name.toString()));
              return giftBox(postGift).ripple(() {
                widget.giftSelectedCompletion(postGift);
              });
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 25,
              );
            });
      }),
    );
  }

  Widget giftBox(PostGiftModel gift) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ThemeIconWidget(
          ThemeIcon.diamond,
          size: 25,
          color: AppColorConstants.iconColor,
        ),
        const SizedBox(
          width: 2,
        ),
        Heading6Text(
          gift.coin.toString(),
          weight: TextWeight.semiBold,
        ),

        const SizedBox(
          width: 25,
        ),
        Expanded(
          child: Row(
            children: [
              // const Spacer(),
              Container(
                color: AppColorConstants.themeColor,
                child: Center(
                  child: Heading6Text(
                    gift.name.toString(),
                    weight: TextWeight.semiBold,
                    color: Colors.white,
                  ).setPadding(top: 5, bottom: 5, left: 10, right: 10),
                ),
              ).round(40),
              const Spacer(),
            ],
          ),
        ),
        // const Spacer()
      ],
    ).round(10);
  }
}

class PostGiftsReceived extends StatefulWidget {
  final int postId;

  const PostGiftsReceived({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostGiftsReceived> createState() => _PostGiftsReceivedState();
}

class _PostGiftsReceivedState extends State<PostGiftsReceived> {
  final PostGiftController _postGiftController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() {
    _postGiftController.fetchReceivedTimelineGift(widget.postId);
  }

  @override
  void dispose() {
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
          Heading6Text(
            giftsReceivedString.tr,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(() {
              return ListView.separated(
                  padding:  EdgeInsets.only(
                      left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 20, bottom: 50),
                  itemCount: _postGiftController.timelineGift.length,
                  itemBuilder: (context, index) {
                    PostGiftModel postGift =
                        _postGiftController.timelineGift[index];
                    // return Container(child: Text(postGift.name.toString()));
                    return giftBox(postGift);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 25,
                    );
                  }).addPullToRefresh(
                  refreshController: _refreshController,
                  onRefresh: () {},
                  onLoading: () {
                    loadData();
                  },
                  enablePullUp: true,
                  enablePullDown: false);
            }),
          ),
        ],
      ),
    ).topRounded(40);
  }

  Widget giftBox(PostGiftModel gift) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ThemeIconWidget(
          ThemeIcon.diamond,
          size: 25,
          color: AppColorConstants.iconColor,
        ),
        const SizedBox(
          width: 2,
        ),
        Heading6Text(
          gift.coin.toString(),
          weight: TextWeight.semiBold,
          color: Colors.white,
        ),
        const SizedBox(
          width: 25,
        ),
        Expanded(
          child: Row(
            children: [
              // const Spacer(),
              Container(
                color: AppColorConstants.themeColor,
                child: Center(
                  child: Heading6Text(
                    gift.name.toString(),
                    weight: TextWeight.semiBold,
                    color: Colors.white,
                  ).setPadding(top: 5, bottom: 5, left: 10, right: 10),
                ),
              ).round(40),
              const Spacer(),
            ],
          ),
        ),
        // const Spacer()
      ],
    ).round(10);
  }
}

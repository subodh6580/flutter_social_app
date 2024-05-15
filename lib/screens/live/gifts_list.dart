import 'package:foap/helper/imports/common_import.dart';


import '../../controllers/misc/gift_controller.dart';
import '../../model/gift_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../settings_menu/coin_packages_widget.dart';

class GiftsPageView extends StatefulWidget {
  final Function(GiftModel) giftSelectedCompletion;

  const GiftsPageView({Key? key, required this.giftSelectedCompletion})
      : super(key: key);

  @override
  State<GiftsPageView> createState() => _GiftsPageViewState();
}

class _GiftsPageViewState extends State<GiftsPageView> {
  final UserProfileManager _userProfileManager = Get.find();

  int currentView = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      GiftsListing(giftSelectedCompletion: widget.giftSelectedCompletion,showCoinsView: (){
        setState(() {
          currentView = 1;
        });
      },),
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
            color: AppColorConstants.themeColor.darken(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BodyLargeText(
                      '${availableCoinsString.tr} : ',
                      weight: TextWeight.medium,
                      color: Colors.white,
                    ),
                    const ThemeIconWidget(
                      ThemeIcon.diamond,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    BodyLargeText(
                      _userProfileManager.user.value!.coins.toString(),
                      color: Colors.white,
                    ),
                  ],
                ),
                currentView == 0
                    ? Container(
                            color: AppColorConstants.themeColor,
                            child: BodyLargeText(coinsString.tr,
                                    weight: TextWeight.semiBold)
                                .setPadding(
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
                        color: Colors.white,
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
  final Function(GiftModel) giftSelectedCompletion;
  final VoidCallback showCoinsView;

  const GiftsListing(
      {Key? key,
      required this.giftSelectedCompletion,
      required this.showCoinsView})
      : super(key: key);

  @override
  State<GiftsListing> createState() => _GiftsListingState();
}

class _GiftsListingState extends State<GiftsListing> {
  final GiftController _giftController = GiftController();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    _giftController.loadGiftCategories();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor.darken(),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Obx(() => HorizontalSegmentBar(
                onSegmentChange: (segment) {
                  _giftController.segmentChanged(segment);
                },
                adjustInMinimumWidth: true,
                hideHighlightIndicator: false,
                segments: _giftController.giftsCategories
                    .map((element) => element.name)
                    .toList(),
              )),
          Obx(() => Expanded(
                child: GridView.builder(
                    padding: const EdgeInsets.only(top: 20, bottom: 25),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1,
                            crossAxisCount: 4),
                    itemCount: _giftController.gifts.length,
                    itemBuilder: (context, index) {
                      GiftModel gift = _giftController.gifts[index];
                      return giftBox(gift).ripple(() {
                        if (_userProfileManager.user.value!.coins >=
                            gift.coins) {
                          widget.giftSelectedCompletion(gift);
                        } else {
                          widget.showCoinsView();
                        }
                      });
                    }),
              )),
        ],
      ),
    );
  }

  Widget giftBox(GiftModel gift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          gift.logo,
          height: 60,
          width: 60,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThemeIconWidget(
              ThemeIcon.diamond,
              size: 20,
              color: AppColorConstants.themeColor,
            ),
            const SizedBox(
              width: 5,
            ),
            BodyMediumText(gift.coins.toString()),
          ],
        )
      ],
    ).round(10);
  }
}

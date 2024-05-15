import 'dart:ui';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../components/timer_view.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../controllers/misc/gift_controller.dart';
import '../../controllers/misc/subscription_packages_controller.dart';
import '../../model/gift_model.dart';
import 'gift_sender_list.dart';
import 'gifts_list.dart';
import 'live_joined_users.dart';
import 'messages_in_live.dart';
import 'package:foap/helper/imports/common_import.dart';

class LiveBroadcastScreen extends StatefulWidget {
  // final Live live;

  const LiveBroadcastScreen({Key? key}) : super(key: key);

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen>
    with SingleTickerProviderStateMixin {
  final AgoraLiveController _agoraLiveController = Get.find();
  final GiftController _giftController = Get.find();
  final SubscriptionPackageController packageController = Get.find();

  // animation
  late AnimationController _controller;
  late Animation<double> _leftContainerAnimation;
  late Animation<double> _rightContainerAnimation;

  @override
  void initState() {
    super.initState();
    prepareAnimationController();
    packageController.initiate();
    // _giftController.loadMostUsedGifts();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    super.dispose();
    _agoraLiveController.clear();
  }

  prepareAnimationController() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _leftContainerAnimation =
        Tween<double>(begin: -Get.width / 2, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5),
    ));

    _rightContainerAnimation =
        Tween<double>(begin: Get.width, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5),
    ));

    _controller.forward();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Obx(
                  () => _agoraLiveController.liveEnd.value == false
                      ? onLiveWidget()
                      : liveEndWidget(),
                ),
              ),
              Obx(() {
                return _agoraLiveController.populateGift.value == null
                    ? Container()
                    : Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: Pulse(
                          duration: const Duration(milliseconds: 500),
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: _agoraLiveController
                                  .populateGift.value!.giftDetail.logo,
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ));
              }),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Obx(() => _agoraLiveController
                                      .live.value?.battleDetail?.battleStatus ==
                                  BattleStatus.completed &&
                              _agoraLiveController.liveEnd.value == false
                          ? battleResultView()
                          : Container()),
                    ],
                  ))
            ],
          )),
    );
  }

  Widget askLiveEndConfirmation() {
    return Container(
      width: Get.width,
      height: Get.height,
      color: AppColorConstants.backgroundColor.withOpacity(0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Column(
          children: [
            const SizedBox(
              height: 400,
            ),
            Heading3Text(
              _agoraLiveController.live.value!.battleStatus ==
                      BattleStatus.started
                  ? endLiveBattleConfirmationString.tr
                  : endLiveCallConfirmationString.tr,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.4,
                  child: AppThemeButton(
                    text: yesString.tr,
                    onPress: () {
                      if (_agoraLiveController.live.value!.battleStatus ==
                          BattleStatus.started) {
                        _agoraLiveController.liveBattleCompleted();
                      } else {
                        _agoraLiveController.onCallEnd(isHost: true);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.4,
                  child: AppThemeButton(
                    // backgroundColor: Colors.red,
                    text: noString.tr,
                    onPress: () {
                      if (_agoraLiveController.live.value!.battleStatus ==
                          BattleStatus.started) {
                        _agoraLiveController.dontEndLiveBattle();
                      } else {
                        _agoraLiveController.dontEndLiveCall();
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  Widget onLiveWidget() {
    return Stack(
      children: [
        Obx(
          () {
            return (_agoraLiveController
                            .live.value?.battleDetail?.battleStatus ==
                        BattleStatus.started ||
                    _agoraLiveController
                            .live.value?.battleDetail?.battleStatus ==
                        BattleStatus.accepted ||
                    (_agoraLiveController
                                    .live.value?.battleDetail?.battleUsers ??
                                [])
                            .isNotEmpty &&
                        _agoraLiveController
                                .live.value?.battleDetail?.battleStatus !=
                            BattleStatus.completed)
                ? Column(
                    children: [battleView(), bottomSectionView()],
                  )
                : Stack(
                    children: [
                      singleUserLiveView(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: bottomSectionView(),
                      )
                    ],
                  );
          },
        ),
        Obx(() => _agoraLiveController.liveEnd.value ? Container() : topBar()),

        _agoraLiveController.askLiveEndConformation.value == true ||
                _agoraLiveController.askBattleEndConformation.value == true
            ? Positioned(
                left: 0, right: 0, bottom: 0, child: askLiveEndConfirmation())
            : Container()
      ],
    );
  }

  Widget singleUserLiveView() {
    return Obx(() => _agoraLiveController.live.value == null
        ? Container()
        : _agoraLiveController.live.value?.amIMainHostInLive == true
            ? SizedBox(height: Get.height, child: _renderLocalPreview())
            : _renderRemoteVideo(LiveCallHostUser(
                userDetail: _agoraLiveController.live.value!.mainHostUserDetail,
                isMainHost: true,
                // battleId: 0,
                totalCoins: 0,
                totalGifts: 0)));
  }

  Widget battleView() {
    return SizedBox(
      height: Get.height * 0.6,
      // color: Colors.red,
      child: Column(
        children: [
          const SizedBox(
            height: 150,
          ),
          Row(
            children: [
              UserAvatarView(
                  size: 25,
                  hideLiveIndicator: true,
                  hideOnlineIndicator: true,
                  user: _agoraLiveController
                      .live.value!.battleDetail!.mainHost.userDetail),
              const SizedBox(
                width: 9,
              ),
              Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                        minWidth: 70, maxWidth: (Get.width - 170)),
                    width: (Get.width - 100) *
                        _agoraLiveController.live.value!.battleDetail!
                            .percentageOfCoinsFor(_agoraLiveController
                                .live.value!.battleDetail!.mainHost),
                    color: AppColorConstants.themeColor,
                    height: 25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const ThemeIconWidget(
                          ThemeIcon.diamond,
                          size: 15,
                          color: Colors.white,
                        ),
                        Obx(() => BodySmallText(
                            _agoraLiveController
                                .live.value!.battleDetail!.mainHost.totalCoins
                                .toString(),
                            color: Colors.white))
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        minWidth: 100, maxWidth: (Get.width - 200)),
                    width: (Get.width - 100) *
                        _agoraLiveController.live.value!.battleDetail!
                            .percentageOfCoinsFor(_agoraLiveController
                                .live.value!.battleDetail!.opponentHost),
                    color: AppColorConstants.red,
                    height: 25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const ThemeIconWidget(ThemeIcon.diamond,
                            size: 15, color: Colors.white),
                        Obx(() => BodySmallText(
                            _agoraLiveController.live.value!.battleDetail!
                                .opponentHost.totalCoins
                                .toString(),
                            color: Colors.white)),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ).round(20),
              const SizedBox(
                width: 9,
              ),
              UserAvatarView(
                  hideLiveIndicator: true,
                  hideOnlineIndicator: true,
                  size: 25,
                  user: _agoraLiveController
                      .live.value!.battleDetail!.opponentHost.userDetail),
            ],
          ).hp(DesignConstants.horizontalPadding),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Stack(
              children: [
                AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Row(
                        children: [
                          SizedBox(
                              width: Get.width / 2,
                              height: double.infinity,
                              child: Transform.translate(
                                  offset:
                                      Offset(_leftContainerAnimation.value, 0),
                                  child: mainHostView())),
                          SizedBox(
                              width: Get.width / 2,
                              height: double.infinity,
                              child: Transform.translate(
                                  offset:
                                      Offset(_rightContainerAnimation.value, 0),
                                  child: battleOpponentView()))
                        ],
                      );
                    }),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 30,
                      width: 100,
                      color: AppColorConstants.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ThemeIconWidget(
                            ThemeIcon.clock,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Center(
                              child: UnlockTimerView(
                            unlockTime: _agoraLiveController.live.value!
                                .battleDetail!.timeRemainingInBattle,
                            completionHandler: () {
                              _agoraLiveController.liveBattleCompleted();
                            },
                          )),
                        ],
                      ).hP4,
                    ).topRounded(10),
                  ),
                ),
                Obx(() => _agoraLiveController
                            .live.value?.battleDetail?.battleStatus ==
                        BattleStatus.accepted
                    ? Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 120,
                                  color: AppColorConstants.cardColor,
                                  child: Row(
                                    children: [
                                      UserAvatarView(
                                        user: _agoraLiveController
                                            .live.value!.mainHostUserDetail,
                                        size: 28,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: BodySmallText(
                                          _agoraLiveController.live.value!
                                              .mainHostUserDetail.userName,
                                          maxLines: 1,
                                        ),
                                      )
                                    ],
                                  ).hP4,
                                ).round(10),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 60,
                                  width: 60,
                                  color: AppColorConstants.backgroundColor,
                                  child: const Center(
                                      child: Heading4Text(
                                    'VS',
                                  )),
                                ).borderWithRadius(
                                    value: 5,
                                    radius: 50,
                                    color: AppColorConstants.red),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 50,
                                  width: 120,
                                  color: AppColorConstants.cardColor,
                                  child: Row(
                                    children: [
                                      UserAvatarView(
                                        user: _agoraLiveController
                                            .live
                                            .value!
                                            .battleDetail!
                                            .opponentHost
                                            .userDetail,
                                        size: 28,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: BodySmallText(
                                          _agoraLiveController
                                              .live
                                              .value!
                                              .battleDetail!
                                              .opponentHost
                                              .userDetail
                                              .userName,
                                          maxLines: 1,
                                        ),
                                      )
                                    ],
                                  ).hP4,
                                ).round(10)
                              ],
                            ),
                            Lottie.asset(
                              'assets/lottie/live_battle.json',
                              height: 150,
                              // width: 200,
                            )
                          ],
                        ),
                      )
                    : Container())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mainHostView() {
    if (_agoraLiveController.live.value!.amIMainHostInLive) {
      return _renderLocalPreview();
    } else {
      return _renderRemoteVideo(
          _agoraLiveController.live.value!.battleDetail!.mainHost);
    }
  }

  Widget battleOpponentView() {
    if (_agoraLiveController.live.value!.amIMainHostInLive) {
      return _renderRemoteVideo(
          _agoraLiveController.live.value!.battleDetail!.opponentHost);
    } else {
      if (_agoraLiveController.live.value!.amIHostInLive) {
        return _renderLocalPreview();
      }
      return _renderRemoteVideo(
          _agoraLiveController.live.value!.battleDetail!.opponentHost);
    }
  }

  Widget battleResultView() {
    return Stack(
      children: [
        Container(
          height: _agoraLiveController.live.value!.amIHostInLive
              ? Get.height * 0.7
              : Get.height * 0.4,
          width: Get.width,
          color: AppColorConstants.cardColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Positioned(
              //   left: 0,
              //   top: 0,
              //   bottom: 150,
              //   right: 0,
              //   child: Lottie.asset(
              //     'assets/lottie/confetti.json',
              //     height: 150,
              //     // width: 200,
              //   ),
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _agoraLiveController.live.value!.battleDetail!.resultType ==
                          LiveBattleResultType.winner
                      ? winnerDetail()
                      : drawViewDetail(),
                  const SizedBox(
                    height: 40,
                  ),
                  if (_agoraLiveController.live.value!.amIHostInLive)
                    Expanded(
                        child: GiftSenders(
                      liveId: _agoraLiveController.live.value!.id,
                      battleId:
                          _agoraLiveController.live.value!.battleDetail?.id,
                    ))
                ],
              ).p16,
            ],
          ),
        ),
        Positioned(
            right: 20,
            top: 20,
            child: Container(
              color: AppColorConstants.themeColor,
              height: 28,
              width: 28,
              child: const ThemeIconWidget(
                ThemeIcon.close,
                color: Colors.white,
              ),
            ).circular.ripple(() {
              _agoraLiveController.closeWinnerInfo();
            }))
      ],
    ).round(20);
  }

  Widget winnerDetail() {
    return Column(
      children: [
        Heading4Text(
          winnerString,
          weight: TextWeight.bold,
          color: AppColorConstants.themeColor,
        ),
        const SizedBox(
          height: 20,
        ),
        Image.asset(
          'assets/crown.png',
          width: 60,
        ),
        UserAvatarView(
          user: _agoraLiveController
              .live.value!.battleDetail!.winnerHost.userDetail,
          size: 80,
          hideOnlineIndicator: true,
          hideLiveIndicator: true,
        ),
        const SizedBox(
          height: 10,
        ),
        BodyLargeText(
          _agoraLiveController
              .live.value!.battleDetail!.winnerHost.userDetail.userName,
          weight: TextWeight.semiBold,
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          height: 25,
          width: 80,
          color: AppColorConstants.themeColor,
          child: Center(
            child: BodyLargeText(
              _agoraLiveController
                  .live.value!.battleDetail!.winnerHost.totalCoins
                  .toString(),
              color: Colors.white,
            ),
          ),
        ).round(5),
      ],
    );
  }

  Widget drawViewDetail() {
    return Column(
      children: [
        Heading4Text(
          battleDrawString,
          weight: TextWeight.bold,
          color: AppColorConstants.themeColor,
        ),
        const SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
                width: Get.width * 0.3,
                child: hostDetail(
                    _agoraLiveController.live.value!.battleDetail!.mainHost)),
            Container(
              height: 40,
              width: 40,
              color: AppColorConstants.backgroundColor,
              child: const Center(
                  child: Heading6Text(
                'VS',
              )),
            )
                .borderWithRadius(
                    value: 5, radius: 50, color: AppColorConstants.red)
                .bp(70),
            SizedBox(
                width: Get.width * 0.3,
                child: hostDetail(_agoraLiveController
                    .live.value!.battleDetail!.opponentHost))
          ],
        ),
      ],
    );
  }

  Widget hostDetail(LiveCallHostUser host) {
    return Column(
      children: [
        UserAvatarView(
          user: host.userDetail,
          size: 70,
          hideOnlineIndicator: true,
          hideLiveIndicator: true,
        ),
        const SizedBox(
          height: 10,
        ),
        BodyLargeText(
          host.userDetail.userName,
          weight: TextWeight.semiBold,
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          height: 25,
          width: 80,
          color: AppColorConstants.themeColor,
          child: Center(
            child: BodyLargeText(
              host.totalCoins.toString(),
              color: Colors.white,
            ),
          ),
        ).round(5),
      ],
    );
  }

  Widget contributor(UserModel user) {
    return Column(
      children: [
        UserAvatarView(
          user: user,
          size: 40,
          hideOnlineIndicator: true,
          hideLiveIndicator: true,
        ),
        const SizedBox(
          height: 10,
        ),
        BodySmallText(
          user.userName,
          weight: TextWeight.regular,
          maxLines: 1,
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          height: 25,
          width: 80,
          color: AppColorConstants.themeColor,
          child: const Center(
            child: BodyLargeText(
              '20',
              color: Colors.white,
            ),
          ),
        ).round(5),
      ],
    );
  }

  Widget liveEndWidget() {
    return _agoraLiveController.live.value != null
        ? _agoraLiveController.live.value!.amIHostInLive
            ? liveEndWidgetForHosts()
            : liveEndWidgetForViewers()
        : Container();
  }

  Widget liveEndWidgetForViewers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          children: [
            const ThemeIconWidget(
              ThemeIcon.close,
              size: 25,
              // color: Colors.white,
            ).ripple(() {
              Get.back();
              _agoraLiveController.clear();
            }),
            const Spacer()
          ],
        ),
        // if (_agoraLiveController.live.value!.battleUsers.length == 1)
        hostUserInfo(),
      ],
    ).hP25;
  }

  Widget liveEndWidgetForHosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          children: [
            const ThemeIconWidget(
              ThemeIcon.close,
              size: 25,
            ).ripple(() {
              _agoraLiveController.closeLive();
            }),
            const Spacer()
          ],
        ).hP25,
        const SizedBox(
          height: 20,
        ),
        Heading4Text(
          liveEndString.tr,
          weight: TextWeight.medium,
        ),
        Container(
          height: 5,
          width: 100,
          color: AppColorConstants.themeColor,
        ).round(10).tP8,
        const SizedBox(
          height: 40,
        ),
        liveStatisticsInfo().hp(DesignConstants.horizontalPadding),
        const SizedBox(
          height: 50,
        ),
        Expanded(
            child: GiftSenders(
          liveId: _agoraLiveController.live.value!.id,
        ))
      ],
    );
  }

  Widget liveStatisticsInfo() {
    return Container(
      width: Get.width / 1.4,
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text(
                            '${_agoraLiveController.allJoinedUsers.length}',
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      usersString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
              // const Spacer(),
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text(_agoraLiveController.liveDurationLength,
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      durationString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text('${_agoraLiveController.giftsReceived.length}',
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      giftsString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text(
                            _agoraLiveController.totalCoinsEarned.toString(),
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      coinsEarnedString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ).p16,
    ).round(20);
  }

  Widget hostUserInfo() {
    UserModel mainHostDetail =
        _agoraLiveController.live.value!.mainHostUserDetail;
    return Column(
      children: [
        const SizedBox(
          height: 150,
        ),
        UserAvatarView(
          user: mainHostDetail,
          hideLiveIndicator: true,
          hideOnlineIndicator: true,
          size: 100,
        ),
        const SizedBox(
          height: 10,
        ),
        Heading4Text(
          mainHostDetail.userName,
          weight: TextWeight.bold,
          color: AppColorConstants.mainTextColor,
        ),
        const SizedBox(
          height: 20,
        ),
        Heading6Text(liveEndString.tr, weight: TextWeight.medium),
      ],
    );
  }

  Widget bottomSectionView() {
    return SizedBox(
      height: Get.height * 0.4,
      // color: Colors.yellow,
      child: Column(
        children: [
          !(_agoraLiveController.live.value?.amIHostInLive == true)
              ? Column(
                  children: [
                    SizedBox(
                        height: (Get.height * 0.4) - 70,
                        child: MessagesInLive()),
                    // topGiftsView(),
                  ],
                )
              : SizedBox(
                  height: (Get.height * 0.4) - 70, child: MessagesInLive()),
          messageComposerView()
        ],
      ),
    );
  }

  Widget messageComposerView() {
    return Container(
      color: Colors.black,
      height: 70,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  color: AppColorConstants.themeColor.withOpacity(0.5),
                  child: Obx(() => Focus(
                        onFocusChange: (status) {
                          _agoraLiveController.messageTextFocusToggle();
                        },
                        child: TextField(
                          controller: _agoraLiveController.messageTf.value,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: FontSizes.b2,
                              color: AppColorConstants.mainTextColor),
                          maxLines: 50,
                          onChanged: (text) {
                            // _agoraLiveController.messageChanges();
                          },
                          decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 5),
                              labelStyle: TextStyle(fontSize: FontSizes.b2),
                              hintStyle: TextStyle(fontSize: FontSizes.b2),
                              hintText: messageString.tr),
                        ),
                      )),
                ).round(10),
              ),
              const SizedBox(
                width: 20,
              ),
              Obx(() => _agoraLiveController.messageTextFocus.value == false &&
                      _agoraLiveController.live.value?.amIHostInLive == true
                  ? Row(
                      children: [
                        const ThemeIconWidget(
                          ThemeIcon.cameraSwitch,
                          size: 30,
                          color: Colors.white,
                        ).circular.ripple(() {
                          _agoraLiveController.onToggleCamera();
                        }),
                        const SizedBox(
                          width: 20,
                        ),
                        Obx(() => ThemeIconWidget(
                              _agoraLiveController.mutedVideo.value
                                  ? ThemeIcon.videoCameraOff
                                  : ThemeIcon.videoCamera,
                              size: 30,
                              color: Colors.white,
                            )).circular.ripple(() {
                          _agoraLiveController.onToggleMuteVideo();
                        }),
                        const SizedBox(
                          width: 20,
                        ),
                        Obx(() => ThemeIconWidget(
                              _agoraLiveController.mutedAudio.value
                                  ? ThemeIcon.micOff
                                  : ThemeIcon.mic,
                              size: 30,
                              color: Colors.white,
                            )).circular.ripple(() {
                          _agoraLiveController.onToggleMuteAudio();
                        }),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    )
                  : Container()),
              const ThemeIconWidget(
                ThemeIcon.send,
                size: 25,
                color: Colors.white,
              ).ripple(() {
                sendMessage();
              }),
              if (_agoraLiveController.live.value?.amIHostInLive == false)
                const SizedBox(
                  width: 20,
                ),
              if (_agoraLiveController.live.value?.amIHostInLive == false)
                Container(
                  height: 40,
                  width: 40,
                  color: AppColorConstants.themeColor,
                  child: const ThemeIconWidget(
                    ThemeIcon.diamond,
                    color: Colors.yellow,
                    size: 25,
                  ),
                ).circular.ripple(() {
                  showModalBottomSheet<void>(
                      backgroundColor: Colors.transparent,
                      context: context,
                      enableDrag: true,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                            heightFactor: 0.8,
                            child:
                                GiftsPageView(giftSelectedCompletion: (gift) {
                              Get.back();
                              sendGift(gift);
                            }));
                      });
                }),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget topBar() {
    return _agoraLiveController.live.value != null
        ? Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 120,
                child: Row(children: [
                  Row(
                    children: [
                      UserAvatarView(
                        user:
                            _agoraLiveController.live.value!.mainHostUserDetail,
                        hideLiveIndicator: true,
                        hideOnlineIndicator: true,
                        size: 35,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      BodyLargeText(_agoraLiveController
                          .live.value!.mainHostUserDetail.userName)
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/live.png',
                    height: 30,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: const Center(
                      child: ThemeIconWidget(
                        ThemeIcon.account,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ).circular.ripple(() {
                    showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return const LiveJoinedUsers();
                        });
                  }),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 28,
                    width: 28,
                    color: AppColorConstants.themeColor.withOpacity(0.5),
                    child: const Center(
                      child: ThemeIconWidget(
                        ThemeIcon.close,
                        size: 20,
                        color: Colors.white,
                        // color: Colors.white,
                      ),
                    ),
                  ).circular.ripple(() {
                    if (_agoraLiveController.live.value!.battleStatus ==
                        BattleStatus.started) {
                      _agoraLiveController.askConfirmationForEndBattle();
                    } else if (_agoraLiveController.live.value!.amIHostInLive) {
                      _agoraLiveController.askConfirmationForEndCall();
                    } else {
                      _agoraLiveController.onCallEnd(isHost: false);
                    }
                  }),
                ]),
              ).hp(DesignConstants.horizontalPadding),
            ],
          )
        : Container();
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    return GetBuilder<AgoraLiveController>(
        init: _agoraLiveController,
        builder: (ctx) {
          return _agoraLiveController.mutedVideo.value
              ? Container(
                  color: AppColorConstants.red,
                  child: Center(
                      child: Heading6Text(
                    videoPausedString.tr,
                    color: AppColorConstants.subHeadingTextColor,
                  )))
              : _agoraLiveController.engine != null
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _agoraLiveController.engine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : Container();
        });
  }

  // Generate remote preview
  Widget _renderRemoteVideo(LiveCallHostUser host) {
    return GetBuilder<AgoraLiveController>(
        init: _agoraLiveController,
        builder: (ctx) {
          return _agoraLiveController.remoteJoinedUsers
                      .contains(host.userDetail.id) ==
                  false
              ? Container(
                  color: AppColorConstants.backgroundColor,
                  // child: Center(
                  //     child: Heading6Text(
                  //   reConnectingString.tr,
                  //   // color: AppColorConstants.mainTextColor,
                  // ))
                )
              : _agoraLiveController.videoPausedUsers
                          .contains(host.userDetail.id) ==
                      true
                  ? Container(
                      color: AppColorConstants.themeColor,
                      child: Center(
                          child: Heading6Text(
                        videoPausedString.tr,
                        color: AppColorConstants.subHeadingTextColor,
                      )))
                  : _agoraLiveController.engine != null
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _agoraLiveController.engine!,
                            canvas: VideoCanvas(uid: host.userDetail.id),
                            connection: RtcConnection(
                                channelId: _agoraLiveController
                                    .live.value!.channelName),
                          ),
                        )
                      : Container(
                          color: Colors.brown,
                        );
        });
  }

  Widget topGiftsView() {
    return SizedBox(
      height: 60,
      child: Obx(() => ListView.separated(
          padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
          scrollDirection: Axis.horizontal,
          itemCount: _giftController.topGifts.length,
          itemBuilder: (ctx, index) {
            return giftBox(_giftController.topGifts[index]).ripple(() {
              sendGift(_giftController.topGifts[index]);
            });
          },
          separatorBuilder: (ctx, index) {
            return const SizedBox(
              width: 15,
            );
          })),
    );
  }

  Widget giftBox(GiftModel gift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          gift.logo,
          height: 30,
          width: 30,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThemeIconWidget(
              ThemeIcon.diamond,
              size: 18,
              color: AppColorConstants.themeColor,
            ),
            const SizedBox(
              width: 5,
            ),
            BodySmallText(
              gift.coins.toString(),
            ),
          ],
        )
      ],
    ).round(10);
  }

  Widget selectHostForGift(Function(LiveCallHostUser) userSelectedCallback) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Heading4Text(sendGiftToString, weight: TextWeight.bold),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserAvatarView(
                      user: _agoraLiveController.live.value!.battleDetail!
                          .battleUsers.first.userDetail,
                      hideLiveIndicator: true,
                      hideOnlineIndicator: true,
                      size: 80,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Heading5Text(
                        _agoraLiveController.live.value!.battleDetail!
                            .battleUsers.first.userDetail.userName,
                        weight: TextWeight.bold),
                    const SizedBox(
                      height: 40,
                    ),
                    AppThemeButton(
                        height: 40,
                        width: 100,
                        text: sendString,
                        onPress: () {
                          userSelectedCallback(_agoraLiveController
                              .live.value!.battleDetail!.battleUsers.first);
                        })
                  ],
                ),
                Container(
                  width: 1,
                  height: 150,
                  color: AppColorConstants.dividerColor,
                ).p25,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserAvatarView(
                        user: _agoraLiveController.live.value!.battleDetail!
                            .battleUsers.last.userDetail,
                        size: 80,
                        hideLiveIndicator: true,
                        hideOnlineIndicator: true),
                    const SizedBox(
                      height: 10,
                    ),
                    Heading5Text(
                      _agoraLiveController.live.value!.battleDetail!.battleUsers
                          .last.userDetail.userName,
                      weight: TextWeight.bold,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    AppThemeButton(
                        height: 40,
                        width: 100,
                        text: sendString,
                        onPress: () {
                          userSelectedCallback(_agoraLiveController
                              .live.value!.battleDetail!.battleUsers.last);
                        })
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ).topRounded(40);
  }

  sendGift(GiftModel gift) {
    if ((_agoraLiveController.live.value!.battleDetail?.battleUsers ?? [])
        .isEmpty) {
      _agoraLiveController.sendGift(gift: gift);
    } else {
      showModalBottomSheet<void>(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isDismissible: true,
          builder: (BuildContext context) {
            return FractionallySizedBox(
                heightFactor: 0.65,
                child: selectHostForGift((user) {
                  Navigator.of(context).pop();
                  _agoraLiveController.sendGift(gift: gift, host: user);
                }));
          });
    }
  }

  sendMessage() {
    if (_agoraLiveController.messageTf.value.text.removeAllWhitespace
        .trim()
        .isNotEmpty) {
      _agoraLiveController
          .sendTextMessage(_agoraLiveController.messageTf.value.text);
    }
  }
}

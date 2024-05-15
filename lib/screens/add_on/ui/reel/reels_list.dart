import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';

class ReelsList extends StatefulWidget {
  final int? audioId;
  final int index;
  final String? hashTag;
  final int? userId;
  final int? locationId;
  final List<PostModel>? reels;
  final PostSource? source;
  final int? page;
  final int? totalPages;

  const ReelsList({
    Key? key,
    this.audioId,
    required this.index,
    this.page,
    this.totalPages,
    this.hashTag,
    this.userId,
    this.locationId,
    this.reels,
    this.source,
  }) : super(key: key);

  @override
  State<ReelsList> createState() => _ReelsListState();
}

class _ReelsListState extends State<ReelsList> {
  final ReelsController _reelsController = Get.find();

  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reelsController.addReels(widget.reels ?? [], widget.page);

      controller.jumpToPage(widget.index);
      loadData();
    });
  }

  void loadData() {
    if (widget.userId != null) {
      PostSearchQuery query = PostSearchQuery();
      query.userId = widget.userId!;
      _reelsController.setReelsSearchQuery(query);
    }
    if (widget.hashTag != null) {
      PostSearchQuery query = PostSearchQuery();
      query.hashTag = widget.hashTag!;
      _reelsController.setReelsSearchQuery(query);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GetBuilder<ReelsController>(
                      init: _reelsController,
                      builder: (ctx) {
                        return PageView(
                            controller: controller,
                            scrollDirection: Axis.vertical,
                            allowImplicitScrolling: true,
                            onPageChanged: (index) {
                              _reelsController.currentPageChanged(index,
                                  _reelsController.filteredReels[index]);
                              if (index ==
                                  _reelsController.filteredReels.length - 2) {
                                _reelsController.getReels();
                              }
                            },
                            children: [
                              for (int i = 0;
                                  i < _reelsController.filteredReels.length;
                                  i++)
                                SizedBox(
                                  height: Get.height,
                                  width: Get.width,
                                  // color: Colors.brown,
                                  child: ReelVideoPlayer(
                                    reel: _reelsController.filteredReels[i],
                                    // play: false,
                                  ),
                                )
                            ]);
                      }),
                  // Positioned(
                  //     left: 0,
                  //     right: 0,
                  //     top: 0,
                  //     child: backNavigationBar(
                  //          title: reelsString.tr))
                ],
              ),
            ),
            // Container(
            //   height: 90,
            //   color: AppColorConstants.backgroundColor,
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: SizedBox(
            //       height: 50,
            //       child: Text(addCommentString.tr),
            //     ).hp(DesignConstants.horizontalPadding),
            //   ),
            // ).ripple(() {})
          ],
        ));
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/tv_imports.dart';
import 'package:foap/model/live_tv_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/category_model.dart';

class TvListByCategory extends StatefulWidget {
  final TvCategoryModel category;

  const TvListByCategory({Key? key, required this.category}) : super(key: key);

  @override
  State<TvListByCategory> createState() => _TvListByCategoryState();
}

class _TvListByCategoryState extends State<TvListByCategory> {
  final TvStreamingController _tvStreamingController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
    super.initState();
  }

  loadData() {
    _tvStreamingController.getTvs(
        categoryId: widget.category.id,
        callback: () {
          _refreshController.loadComplete();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.category.coverImage,
                    fit: BoxFit.cover,
                    height: 250,
                    width: 180,
                  ).overlay(Colors.black26),
                  Positioned(
                    bottom: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    child: Heading4Text(
                      widget.category.name,
                      weight: TextWeight.bold,
                    ),
                  ),
                  Positioned(
                      top: 50,
                      left: DesignConstants.horizontalPadding,
                      child: ThemeIconWidget(
                        ThemeIcon.backArrow,
                        size: 18,
                        color: AppColorConstants.iconColor,
                      ).ripple(() {
                        Get.back();
                      }))
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: tvList())
          ],
        ));
  }

  Widget tvList() {
    return GetBuilder<TvStreamingController>(
        init: _tvStreamingController,
        builder: (ctx) {
          return _tvStreamingController.tvs.isEmpty
              ? SizedBox(
                  height: (Get.height / 1.5),
                  width: (Get.width),
                  child: const Center(child: CircularProgressIndicator()))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    mainAxisExtent: 140,
                  ),
                  itemCount: _tvStreamingController.tvs.length,
                  itemBuilder: (BuildContext context, int index) {
                    TvModel tvModel = _tvStreamingController.tvs[index];
                    return Card(
                        margin: const EdgeInsets.all(1),
                        child: CachedNetworkImage(
                          imageUrl: tvModel.image,
                          fit: BoxFit.fitHeight,
                          height: 230,
                        ).round(10).ripple(() {
                          Get.to(() => TVChannelDetail(
                                tvModel: tvModel,
                              ));
                        })).round(5);
                  },
                ).addPullToRefresh(
                  refreshController: _refreshController,
                  onRefresh: () {},
                  onLoading: () {
                    loadData();
                  },
                  enablePullUp: true,
                  enablePullDown: false);
        });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/empty_states.dart';
import '../../components/hashtag_tile.dart';
import '../../components/shimmer_widgets.dart';
import '../../controllers/misc/misc_controller.dart';
import '../../helper/localization_strings.dart';
import '../../util/app_config_constants.dart';
import '../dashboard/posts.dart';

class HashTagsList extends StatelessWidget {
  final MiscController _miscController = Get.find();

  HashTagsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return hashTagView();
  }

  Widget hashTagView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!_miscController.hashtagsIsLoading) {
          _miscController.loadHashTags();
        }
      }
    });

    return Obx(() => _miscController.hashtagsIsLoading
        ? const ShimmerHashtag()
        : _miscController.hashTags.isNotEmpty
            ? ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.only(
                    top: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding),
                itemCount: _miscController.hashTags.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return HashTagTile(
                    hashtag: _miscController.hashTags[index],
                    onItemCallback: () {
                      Get.to(() => Posts(
                            hashTag: _miscController.hashTags[index].name,
                          ));
                    },
                  );
                },
              )
            : SizedBox(
                height: Get.size.height * 0.5,
                child: emptyData(title: noHashtagFoundString.tr, subTitle: ''),
              ));
  }
}
